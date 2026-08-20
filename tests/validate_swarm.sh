#!/usr/bin/env bash
# Validate compose stacks against both the Compose schema and the Swarm schema,
# and flag keys that `docker stack deploy` silently discards.
set -uo pipefail

# Service-level keys that Swarm accepts in the file but ignores at deploy time.
SWARM_IGNORED=(
	build cgroup_parent container_name depends_on devices external_links
	links network_mode privileged restart security_opt userns_mode
)

STACK_GLOB="${STACK_GLOB:-stacks/*/}"
fail=0

have() { command -v "$1" >/dev/null 2>&1; }

if ! have docker; then
	echo "docker not found in PATH" >&2
	exit 1
fi
if ! docker stack config --help >/dev/null 2>&1; then
	echo "warning: 'docker stack config' unavailable; skipping swarm schema check" >&2
	SKIP_SWARM=1
fi
if ! have jq; then
	echo "warning: jq not found; skipping ignored-key check" >&2
	SKIP_JQ=1
fi

shopt -s nullglob
stacks=($STACK_GLOB)
if ((${#stacks[@]} == 0)); then
	echo "no stacks matched $STACK_GLOB" >&2
	exit 1
fi

for stack in "${stacks[@]}"; do
	name=${stack%/}
	name=${name##*/}
	file="${stack}compose.yaml"
	env_file="${stack}example.env"
	problems=()

	if [[ ! -f $file ]]; then
		problems+=("missing compose.yaml")
	else
		args=(--file "$file")
		[[ -f $env_file ]] && args+=(--env-file "$env_file")

		# 1. Compose schema, interpolation, and merge resolution.
		if ! out=$(docker compose "${args[@]}" config --quiet 2>&1); then
			problems+=("compose config failed:"$'\n'"$out")
		elif [[ -n $out ]]; then
			problems+=("compose warning:"$'\n'"$out")
		fi

		# 2. Swarm schema. Stricter than Compose: rejects booleans in
		#    environment, bad deploy blocks, unknown v3 keys. Run against the
		#    raw file so Compose's normalisation doesn't launder the error.
		if [[ -z ${SKIP_SWARM:-} ]]; then
			out=$(
				set -a
				[[ -f $env_file ]] && . "$env_file"
				set +a
				docker stack config --compose-file "$file" 2>&1 >/dev/null
			)
			rc=$?
			if ((rc != 0)); then
				problems+=("stack config failed:"$'\n'"$out")
			elif [[ -n $out ]]; then
				problems+=("stack warning:"$'\n'"$out")
			fi
		fi

		# 3. Keys Swarm throws away without complaint.
		if [[ -z ${SKIP_JQ:-} ]]; then
			rendered=$(docker compose "${args[@]}" config --format json 2>/dev/null)
			if [[ -n $rendered ]]; then
				for key in "${SWARM_IGNORED[@]}"; do
					hits=$(jq -r --arg k "$key" \
						'.services // {} | to_entries[] | select(.value[$k] != null) | .key' \
						<<<"$rendered" 2>/dev/null | paste -sd' ' -)
					[[ -n $hits ]] && problems+=("swarm ignores '$key' (services: $hits)")
				done

				# Traefik labels on a swarm service must live under deploy.labels;
				# top-level labels attach to the container and are never read.
				hits=$(jq -r '
                    .services // {} | to_entries[]
                    | select(.value.deploy != null)
                    | select((.value.labels // {} | tostring) | test("traefik"))
                    | .key' <<<"$rendered" 2>/dev/null | paste -sd' ' -)
				[[ -n $hits ]] && problems+=("traefik labels outside deploy.labels (services: $hits)")
			fi
		fi
	fi

	if ((${#problems[@]} == 0)); then
		printf 'ok    %s\n' "$name"
	else
		fail=1
		printf 'FAIL  %s\n' "$name"
		for p in "${problems[@]}"; do
			printf '        %s\n' "$p"
		done
	fi
done

exit "$fail"
