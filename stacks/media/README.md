# Media Stack

## Jellyfin
This stack assumes that you have an intel gpu that is available to the container for transcoding media.

If you do not, remove the `DOCKER_MODS` environment variable and the `devices` property in the `jellyfin` container.

If you have a different gpu (amd, nvidia, apple, or arm) that you want to use for transcoding,
please review jellyfin's documentation for [Hardware Encoding](https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/) for your specific use case.

## Seerr
The folder under `${data:-.}/seerr` must be owned by a user with with id 1000 and group id 1000.

Run `chown -R 1000:1000 <your_path_here>/seerr` to ensure that this is true.
