# Media Stack

This stack assumes that you have an intel gpu that is available to the container for transcoding media.

If you do not, remove the `DOCKER_MODS` environment variable and the `devices` property in the `jellyfin` container.

If you have a different gpu (amd, nvidia, apple, or arm) that you want to use for transcoding,
please review jellyfin's documentation for [Hardware Encoding](https://jellyfin.org/docs/general/post-install/transcoding/hardware-acceleration/) for your specific use case.
