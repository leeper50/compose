# N8N

The stack requires that bind mount folders have belong to an owner and group with id
1000.

Run this command in your `data` path to ensure this is the case.
`sudo chown -R 1000:1000 n8n/{config,files}`
