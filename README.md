# Novellia Database

Contains the database designs and schema for Novellia

# login as user
sudo -i -u postgres

# login to psql, using ~/.pgpass for automatic authentication
```
psql -U rektangular novellia
psql -U rektangular -d postgres -h 127.0.0.1 -d cexplorer
```

# change authentication type
https://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge
- `sudo gedit  /etc/postgresql/13/main/pg_hba.conf`
or on server
- `sudo nano /etc/postgresql/12/main/pg_hba.conf`

# commands
list users
- `\du`

list databases
- `\l`

list tables
- `\dt`

exit
- `\q`

execute query
- `psql -U rektangular -d novellia -f ./database_sql/novellia_schema.sql`

# populating the database

Open `./data/novellia_data.md` and use the commands there with `psql` to populate the DB.

# backup / restore database

`pg_dump -U rektangular novellia_alpha > novellia_alpha_db_dump_June17_2021`
`psql -U rektangular -d novellia_bravo < novellia_alpha_db_dump_1`
