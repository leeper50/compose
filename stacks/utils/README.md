# Utils

This project provides a few file and text sharing utilities.

For slink and privatebin to work properly, the folders must be created and owned by the user and group
specified with the `uid` and `gid` variables.

After creating an account in slink, you must approve it in the docker container.
Use either of these commands: 
`docker exec -it slink slink user:activate --email=<user-email>`
`docker exec -it slink slink user:activate --uuid=<user-id>`
