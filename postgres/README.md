# TODO

- [x] Setup more modern version of Postgres in playbook
- [x] Establish Vagrant networking to enable pgadmin from host system
- [x] Set database encoding to UTF-8, not SQL ASCII
- [x] Setup adminpack into maintenance DB for pgadmin enhancement
- [x] Demonstrate flyway usage
- [ ] Demonstrate use of pgcrypt extension

# Database book setup

Once ansible script completes.  
```
cd flyway
./flyway migrate
```

Login to vagrant box; As the vagrant user

```
psql book
\i /vagrant/book_data.sql
```

Test that stuff is OK with

```
\i crosstab.sql
select from search_movies('unforgiven');
insert into actors(name) values ('Pee Wee Herman');
insert into movies (title, genre)
    values ('Birdman', '(5,0,0,0,0,0,0,0,0,0,7,7,0,0,7,0,0,0)');
```

The following were used to create V1__Base_version.sql and book_data.sql
scripts:

```
pg_dump --schema-only --schema=public --no-owner book >V1__Base_version.sql
pg_dump --data-only --schema=public --no-owner book >book_data.sql
```

The book_data.sql script had a couple of flaws:

1.  The seq generator for the actors and movies table was set to 1.
2.  The search_path was hosed unless you want to qualilfy everything with it's
    schema prefix.

# pgcrypt

* Once setup, what does a pgdump result in?  How are keys managed?


