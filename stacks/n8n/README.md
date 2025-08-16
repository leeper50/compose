# N8N Stack

The stack requires that bind mount folders have belong to an owner and group with id
1000. I am not sure if this can be configured another way, but as it stands, you must
ensure the `config` and `files` folders are own by uid 1000 and gid 1000.

Run this command in your `data` path to ensure this is the case.
`sudo chown -R 1000:1000 n8n/{config,files}`
