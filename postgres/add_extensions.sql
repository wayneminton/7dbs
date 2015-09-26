\connect book

create schema if not exists ext;
GRANT ALL ON SCHEMA ext TO PUBLIC;

create extension if not exists tablefunc schema ext;
create extension if not exists dict_xsyn schema ext;
create extension if not exists fuzzystrmatch schema ext;
create extension if not exists pg_trgm schema ext;
create extension if not exists cube schema ext;

alter database book set search_path='"$user", public, ext';


