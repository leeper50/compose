# RustFS Configuration

This stack requires a folder with the correct permissions to exist before it runs.

The folder is defined with the `data` environment variable and the final path will be
`${data}/data`. The folder must be own by the correct uid and gid `10001`.
