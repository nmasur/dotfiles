# Repairing Nextcloud

You can run the maintenance commands like this:

```
sudo -u nextcloud nextcloud-occ maintenance:mode --on
sudo -u nextcloud nextcloud-occ maintenance:repair
sudo -u nextcloud nextcloud-occ maintenance:mode --off
```

## Rescan Files

```
sudo -u nextcloud nextcloud-occ files:scan --all
```

## Converting from SQLite to MySQL (mariadb)

First: keep Nextcloud set to SQLite as its dbtype, and separately launch MySQL
as a service by copying the configuration found
[here](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/web-apps/nextcloud.nix).

No password is necessary, since the user-based auth works with UNIX sockets.

You can connect to the MySQL instance like this:

```
sudo -u nextcloud mysql -S /run/mysqld/mysqld.sock
```

Create a blank database for Nextcloud:

```sql
create database nextcloud;
```

Now setup the [conversion](https://docs.nextcloud.com/server/17/admin_manual/configuration_database/db_conversion.html):

```
sudo -u nextcloud nextcloud-occ db:convert-type mysql nextcloud localhost nextcloud
```

Ignore the password prompt. Proceed with the conversion.

Now `config.php` will be updated but the override config from NixOS will not
be. Now update your NixOS configuration:

- Remove the `mysql` service you created.
- Set `dbtype` to `mysql`.
- Set `database.createLocally` to `true`.

Rebuild your configuration.

Now, make sure to enable [4-byte
support](https://docs.nextcloud.com/server/latest/admin_manual/configuration_database/mysql_4byte_support.html)
in the database.

## Backing Up MySQL Database

Use this mysqldump command:

```
sudo -u nextcloud mysqldump -S /run/mysqld/mysqld.sock --default-character-set=utf8mb4 nextcloud > backup.sql
```

## Converting to Postgres

Same as MySQL, but run this command instead:

```
sudo -u nextcloud nextcloud-occ db:convert-type pgsql nextcloud /run/postgresql/ nextcloud
```

Then set the `dbtype` to `pgsql`.

## Backing Up Postgres Database

Use this pg_dump command:

```
sudo -u nextcloud pg_dump nextcloud > backup.sql
```
