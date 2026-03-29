# Zerobyte

This project provides a nice webui for a restic based backup solution.

## Setup

The `app_secret` environment variable must be populated with a secure value. 
You may generate one with `openssl rand -hex 32`.

The `backup` environment variable should contain the path you wish to backup.

## Rclone
This app can integrate with rclone for backups.
This requires some additional setup.

A folder named `rclone` must be present in the same directory as the rest of the app's data.
This folder should contain an `rclone.conf` file that contains a valid remote.

Your directory structure should look like this:
```
${data}
├── app
│       ├── data
│       └── restic
└── rclone
          └── rclone.conf
```