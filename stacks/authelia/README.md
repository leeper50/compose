# Authelia & LLDAP
This stack contains an ldap server (LLDAP) that acts as a single source of truth for our authentication server, Authelia.

This stack is key to the security of the reverse proxy and the reverse proxy can not run without Authelia running. 

## Extra info
Authelia is a very configurable piece of software, and I can not offer a suitable default configuration for general use.

Please refer to the documentation for Authelia when building out your own `config/configuration.yml` file.