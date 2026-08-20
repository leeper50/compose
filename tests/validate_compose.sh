#!/usr/bin/env bash
set -uo pipefail

SWARM_IGNORED=(
	build cgroup_parent container_name depends_on devices external_links
	links network_mode privileged restart security_opt userns_mode
)

COMPOSE_IGNORED_DEPLOY=(
	placement update_config rollback_config endpoint_mode mode
)

SWARM_GLOB="${SWARM_GLOB:-swarm/*/}"
STACK_GLOB="${STACK_GLOB:-stacks/*/}"
COMPOSE_FILE_NAME="${COMPOSE_FILE_NAME:-compose.yaml}"
ENV_FILE_NAME="${ENV_FILE_NAME:-example.env}"

fail=0
have() { command -v "$1" >/dev/null 2>&1; }

have docker || {
	echo "docker not found in PATH" >&2
	exit 1
}
docker stack config --help >/dev/null 2>&1 || SKIP_SWARM=1
have jq || SKIP_JQ=1
[[ -n ${SKIP_SWARM:-} ]] && echo "warning: 'docker stack config' unavailable; skipping swarm schema check" >&2
[[ -n ${SKIP_JQ:-} ]] && echo "warning: jq not found; skipping key-placement checks" >&2

svc_hits() { jq -r "$1" 2>/dev/null <<<"$2" | paste -sd' ' -; }

validate() {
	local stack=$1 mode=$2
	local name=${stack%/}
	name=${name##*/}
	local file="${stack}${COMPOSE_FILE_NAME}"
	local env_file="${stack}${ENV_FILE_NAME}"
	local -a problems=()
	local out rc rendered hits key f line p

	if [[ ! -f $file ]]; then
		problems+=("missing ${COMPOSE_FILE_NAME}")
	else
		for f in "$file" "$env_file"; do
			[[ -f $f ]] && grep -qU $'\r' "$f" && problems+=("CRLF line endings in ${f##*/}")
		done

		local -a args=(--file "$file")
		[[ -f $env_file ]] && args+=(--env-file "$env_file")

		if ! out=$(docker compose "${args[@]}" config --quiet 2>&1); then
			problems+=("compose config failed:"$'\n'"$out")
		elif [[ -n $out ]]; then
			problems+=("compose warning:"$'\n'"$out")
		fi

		if [[ $mode == swarm && -z ${SKIP_SWARM:-} ]]; then
			out=$(
				if [[ -f $env_file ]]; then
					while IFS= read -r line || [[ -n $line ]]; do
						line=${line%$'\r'}
						[[ $line =~ ^[[:space:]]*# ]] && continue
						[[ -z ${line// /} ]] && continue
						export "${line?}"
					done <"$env_file"
				fi
				docker stack config --compose-file "$file" 2>&1 >/dev/null
			)
			rc=$?
			if ((rc != 0)); then
				problems+=("stack config failed:"$'\n'"$out")
			elif [[ -n $out ]]; then
				problems+=("stack warning:"$'\n'"$out")
			fi
		fi

		if [[ -z ${SKIP_JQ:-} ]]; then
			rendered=$(docker compose "${args[@]}" config --format json 2>/dev/null)
			if [[ -n $rendered ]]; then
				if [[ $mode == swarm ]]; then
					for key in "${SWARM_IGNORED[@]}"; do
						hits=$(svc_hits ".services // {} | to_entries[] | select(.value[\"$key\"] != null) | .key" "$rendered")
						[[ -n $hits ]] && problems+=("swarm ignores '$key' (services: $hits)")
					done
					hits=$(svc_hits '.services // {} | to_entries[] | select(.value.deploy == null) | .key' "$rendered")
					[[ -n $hits ]] && problems+=("no deploy block (services: $hits)")
					hits=$(svc_hits '.services // {} | to_entries[] | select((.value.labels // {} | tostring) | test("traefik")) | .key' "$rendered")
					[[ -n $hits ]] && problems+=("traefik labels must be under deploy.labels (services: $hits)")
				else
					for key in "${COMPOSE_IGNORED_DEPLOY[@]}"; do
						hits=$(svc_hits ".services // {} | to_entries[] | select(.value.deploy[\"$key\"]? != null) | .key" "$rendered")
						[[ -n $hits ]] && problems+=("compose ignores 'deploy.$key' (services: $hits)")
					done
					hits=$(svc_hits '.services // {} | to_entries[] | select((.value.deploy.labels? // {} | tostring) | test("traefik")) | .key' "$rendered")
					[[ -n $hits ]] && problems+=("traefik labels must be top-level, not deploy.labels (services: $hits)")
				fi
			fi
		fi
	fi

	if ((${#problems[@]} == 0)); then
		printf 'ok    [%s] %s\n' "$mode" "$name"
	else
		fail=1
		printf 'FAIL  [%s] %s\n' "$mode" "$name"
		for p in "${problems[@]}"; do printf '        %s\n' "$p"; done
	fi
}

shopt -s nullglob
swarm_stacks=($SWARM_GLOB)
plain_stacks=($STACK_GLOB)

if ((${#swarm_stacks[@]} + ${#plain_stacks[@]} == 0)); then
	echo "no stacks matched $SWARM_GLOB or $STACK_GLOB" >&2
	exit 1
fi

for stack in "${swarm_stacks[@]}"; do validate "$stack" swarm; done
for stack in "${plain_stacks[@]}"; do validate "$stack" compose; done

exit "$fail"
