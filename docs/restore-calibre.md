# Restoring Calibre From Backup

The `metadata.db` holds the library and `app.db` and `gdrive.db` contain the
web/account information.

Place books directories in `/data/books/`.

Place `metadata.db` in `/var/lib/calibre-web-db/`.

Symlink `metadata.db` to the library:

```
sudo ln -s /var/lib/calibre-web-db/metadata.db /data/books/metadata.db
```

Place `app.db` and `gdrive.db` in `/var/lib/calibre-web/`.

Restart Calibre:

```
sudo systemctl restart calibre-web.service
```

