# Forgejo Stack

To configure a runner for CI/CD actions, you must:
1. Create an administrator account.
2. Go to `Site administration`.
3. Click `Actions` on the sidebar and select `Runners`.
4. Click `Create new runner` and copy the `registration token`.
5. Fill in the `token` environment variable with the `registration token`.
6. Redeploy the stack.

From here you can now configure the runner container with labels to enable the runner
to work for particular workloads.

The forgejo documentation uses the `docker` label, but gitea and github seem to prefer 
ubuntu labels such as `ubuntu-latest` or a particular version like `ubuntu-22.04`.

