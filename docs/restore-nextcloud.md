# Restoring Nextcloud From Backup

Install the `litestream` package.

```
nix-shell --run fish -p litestream
```

Set the S3 credentials:

```
set -x AWS_ACCESS_KEY_ID (read)
set -x AWS_SECRET_ACCESS_KEY (read)
```

Restore from S3:

```
litestream restore -o nextcloud.db s3://noahmasur-backup.s3.us-west-002.backblazeb2.com/nextcloud
```

Install Nextcloud. Then copy DB:

```
sudo rm /var/lib/nextcloud/data/nextcloud.db*
sudo mv nextcloud.db /var/lib/nextcloud/data/
sudo chown nextcloud:nextcloud /var/lib/nextcloud/data/nextcloud.db
sudo chmod 770 /var/lib/nextcloud/data/nextcloud.db
```

Restart Nextcloud:

```
sudo systemctl restart phpfpm-nextcloud.service
```

Adjust Permissions and Directories:

```
sudo mkdir /var/lib/nextcloud/data/noah/files
sudo chown nextcloud:nextcloud /var/lib/nextcloud/data/noah/files
```

