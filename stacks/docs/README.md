# Docs

This project provides a monitoring and alerting services.

For prometheus to work properly, the data folder must be created and owned by the `nobody` user.
Ntfy also requires its folders to be created and owned by the user and group defined by `uid` and `gid`.

## Autokuma configuration
Autokuma is a supplementary service to uptimekuma that allows declarative configuration of uptimekuma using docker labels.

An uptimekuma account must be created and the username and password supplied for autokuma to connect to uptimekuma.
The account is created by simply going through the first time setup of uptimekuma.
The username and password should populate the `kuma_user` and `kuma_pass` environment variables.

Integration with NTFY requires the creation of an access token and should use the `ntfy_token` environment variable.
This can be created by making a user, navigating to the account option on the left sidebar, and creating an access token.
