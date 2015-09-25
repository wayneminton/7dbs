--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: cube; Type: SHELL TYPE; Schema: public; Owner: postgres
--

CREATE TYPE cube;


--
-- Name: cube_in(cstring); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_in(cstring) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_in';


ALTER FUNCTION public.cube_in(cstring) OWNER TO postgres;

--
-- Name: cube_out(cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_out(cube) RETURNS cstring
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_out';


ALTER FUNCTION public.cube_out(cube) OWNER TO postgres;

--
-- Name: cube; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE cube (
    INTERNALLENGTH = variable,
    INPUT = cube_in,
    OUTPUT = cube_out,
    ALIGNMENT = double,
    STORAGE = plain
);


ALTER TYPE public.cube OWNER TO postgres;

--
-- Name: TYPE cube; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TYPE cube IS 'multi-dimensional cube ''(FLOAT-1, FLOAT-2, ..., FLOAT-N), (FLOAT-1, FLOAT-2, ..., FLOAT-N)''';


--
-- Name: gtrgm; Type: SHELL TYPE; Schema: public; Owner: postgres
--

CREATE TYPE gtrgm;


--
-- Name: gtrgm_in(cstring); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_in(cstring) RETURNS gtrgm
    LANGUAGE c STRICT
    AS '$libdir/pg_trgm', 'gtrgm_in';


ALTER FUNCTION public.gtrgm_in(cstring) OWNER TO postgres;

--
-- Name: gtrgm_out(gtrgm); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_out(gtrgm) RETURNS cstring
    LANGUAGE c STRICT
    AS '$libdir/pg_trgm', 'gtrgm_out';


ALTER FUNCTION public.gtrgm_out(gtrgm) OWNER TO postgres;

--
-- Name: gtrgm; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE gtrgm (
    INTERNALLENGTH = variable,
    INPUT = gtrgm_in,
    OUTPUT = gtrgm_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


ALTER TYPE public.gtrgm OWNER TO postgres;

--
-- Name: tablefunc_crosstab_2; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE tablefunc_crosstab_2 AS (
	row_name text,
	category_1 text,
	category_2 text
);


ALTER TYPE public.tablefunc_crosstab_2 OWNER TO postgres;

--
-- Name: tablefunc_crosstab_3; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE tablefunc_crosstab_3 AS (
	row_name text,
	category_1 text,
	category_2 text,
	category_3 text
);


ALTER TYPE public.tablefunc_crosstab_3 OWNER TO postgres;

--
-- Name: tablefunc_crosstab_4; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE tablefunc_crosstab_4 AS (
	row_name text,
	category_1 text,
	category_2 text,
	category_3 text,
	category_4 text
);


ALTER TYPE public.tablefunc_crosstab_4 OWNER TO postgres;

--
-- Name: weekdays; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE weekdays AS ENUM (
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
);


ALTER TYPE public.weekdays OWNER TO postgres;

--
-- Name: add_event(text, timestamp without time zone, timestamp without time zone, text, character varying, character); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION add_event(v_title text, v_starts timestamp without time zone, v_ends timestamp without time zone, venue text, postal character varying, country character) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  did_insert boolean := false;
  found_count integer;
  the_venue_id integer;
BEGIN
  SELECT venue_id INTO the_venue_id
  FROM venues v
  WHERE v.postal_code=postal AND v.country_code=country AND v.name ILIKE venue
  LIMIT 1;
  
  IF the_venue_id IS NULL THEN
    INSERT INTO venues (name, postal_code, country_code)
    VALUES (venue, postal, country)
    RETURNING venue_id INTO the_venue_id;
    
    did_insert := true;
  END IF;
	
  -- Note: not an “error”, as in some programming languages
  RAISE NOTICE 'Venue found %', the_venue_id;

  INSERT INTO events (title, starts, ends, venue_id)
  VALUES (v_title, v_starts, v_ends, the_venue_id);

  RETURN did_insert;
END;
$$;


ALTER FUNCTION public.add_event(v_title text, v_starts timestamp without time zone, v_ends timestamp without time zone, venue text, postal character varying, country character) OWNER TO postgres;

--
-- Name: connectby(text, text, text, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION connectby(text, text, text, text, integer, text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text';


ALTER FUNCTION public.connectby(text, text, text, text, integer, text) OWNER TO postgres;

--
-- Name: connectby(text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION connectby(text, text, text, text, integer) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text';


ALTER FUNCTION public.connectby(text, text, text, text, integer) OWNER TO postgres;

--
-- Name: connectby(text, text, text, text, text, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION connectby(text, text, text, text, text, integer, text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text_serial';


ALTER FUNCTION public.connectby(text, text, text, text, text, integer, text) OWNER TO postgres;

--
-- Name: connectby(text, text, text, text, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION connectby(text, text, text, text, text, integer) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'connectby_text_serial';


ALTER FUNCTION public.connectby(text, text, text, text, text, integer) OWNER TO postgres;

--
-- Name: crosstab(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosstab(text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


ALTER FUNCTION public.crosstab(text) OWNER TO postgres;

--
-- Name: crosstab(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosstab(text, integer) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


ALTER FUNCTION public.crosstab(text, integer) OWNER TO postgres;

--
-- Name: crosstab(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosstab(text, text) RETURNS SETOF record
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab_hash';


ALTER FUNCTION public.crosstab(text, text) OWNER TO postgres;

--
-- Name: crosstab2(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosstab2(text) RETURNS SETOF tablefunc_crosstab_2
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


ALTER FUNCTION public.crosstab2(text) OWNER TO postgres;

--
-- Name: crosstab3(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosstab3(text) RETURNS SETOF tablefunc_crosstab_3
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


ALTER FUNCTION public.crosstab3(text) OWNER TO postgres;

--
-- Name: crosstab4(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION crosstab4(text) RETURNS SETOF tablefunc_crosstab_4
    LANGUAGE c STABLE STRICT
    AS '$libdir/tablefunc', 'crosstab';


ALTER FUNCTION public.crosstab4(text) OWNER TO postgres;

--
-- Name: cube(double precision[], double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube(double precision[], double precision[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_a_f8_f8';


ALTER FUNCTION public.cube(double precision[], double precision[]) OWNER TO postgres;

--
-- Name: cube(double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube(double precision[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_a_f8';


ALTER FUNCTION public.cube(double precision[]) OWNER TO postgres;

--
-- Name: cube(double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube(double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_f8';


ALTER FUNCTION public.cube(double precision) OWNER TO postgres;

--
-- Name: cube(double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube(double precision, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_f8_f8';


ALTER FUNCTION public.cube(double precision, double precision) OWNER TO postgres;

--
-- Name: cube(cube, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube(cube, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_c_f8';


ALTER FUNCTION public.cube(cube, double precision) OWNER TO postgres;

--
-- Name: cube(cube, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube(cube, double precision, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_c_f8_f8';


ALTER FUNCTION public.cube(cube, double precision, double precision) OWNER TO postgres;

--
-- Name: cube_cmp(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_cmp(cube, cube) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_cmp';


ALTER FUNCTION public.cube_cmp(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_cmp(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_cmp(cube, cube) IS 'btree comparison function';


--
-- Name: cube_contained(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_contained(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_contained';


ALTER FUNCTION public.cube_contained(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_contained(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_contained(cube, cube) IS 'contained in';


--
-- Name: cube_contains(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_contains(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_contains';


ALTER FUNCTION public.cube_contains(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_contains(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_contains(cube, cube) IS 'contains';


--
-- Name: cube_dim(cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_dim(cube) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_dim';


ALTER FUNCTION public.cube_dim(cube) OWNER TO postgres;

--
-- Name: cube_distance(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_distance(cube, cube) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_distance';


ALTER FUNCTION public.cube_distance(cube, cube) OWNER TO postgres;

--
-- Name: cube_enlarge(cube, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_enlarge(cube, double precision, integer) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_enlarge';


ALTER FUNCTION public.cube_enlarge(cube, double precision, integer) OWNER TO postgres;

--
-- Name: cube_eq(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_eq(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_eq';


ALTER FUNCTION public.cube_eq(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_eq(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_eq(cube, cube) IS 'same as';


--
-- Name: cube_ge(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_ge(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ge';


ALTER FUNCTION public.cube_ge(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_ge(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_ge(cube, cube) IS 'greater than or equal to';


--
-- Name: cube_gt(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_gt(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_gt';


ALTER FUNCTION public.cube_gt(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_gt(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_gt(cube, cube) IS 'greater than';


--
-- Name: cube_inter(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_inter(cube, cube) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_inter';


ALTER FUNCTION public.cube_inter(cube, cube) OWNER TO postgres;

--
-- Name: cube_is_point(cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_is_point(cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_is_point';


ALTER FUNCTION public.cube_is_point(cube) OWNER TO postgres;

--
-- Name: cube_le(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_le(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_le';


ALTER FUNCTION public.cube_le(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_le(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_le(cube, cube) IS 'lower than or equal to';


--
-- Name: cube_ll_coord(cube, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_ll_coord(cube, integer) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ll_coord';


ALTER FUNCTION public.cube_ll_coord(cube, integer) OWNER TO postgres;

--
-- Name: cube_lt(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_lt(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_lt';


ALTER FUNCTION public.cube_lt(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_lt(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_lt(cube, cube) IS 'lower than';


--
-- Name: cube_ne(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_ne(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ne';


ALTER FUNCTION public.cube_ne(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_ne(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_ne(cube, cube) IS 'different';


--
-- Name: cube_overlap(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_overlap(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_overlap';


ALTER FUNCTION public.cube_overlap(cube, cube) OWNER TO postgres;

--
-- Name: FUNCTION cube_overlap(cube, cube); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION cube_overlap(cube, cube) IS 'overlaps';


--
-- Name: cube_size(cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_size(cube) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_size';


ALTER FUNCTION public.cube_size(cube) OWNER TO postgres;

--
-- Name: cube_subset(cube, integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_subset(cube, integer[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_subset';


ALTER FUNCTION public.cube_subset(cube, integer[]) OWNER TO postgres;

--
-- Name: cube_union(cube, cube); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_union(cube, cube) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_union';


ALTER FUNCTION public.cube_union(cube, cube) OWNER TO postgres;

--
-- Name: cube_ur_coord(cube, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION cube_ur_coord(cube, integer) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ur_coord';


ALTER FUNCTION public.cube_ur_coord(cube, integer) OWNER TO postgres;

--
-- Name: difference(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION difference(text, text) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'difference';


ALTER FUNCTION public.difference(text, text) OWNER TO postgres;

--
-- Name: dmetaphone(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dmetaphone(text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'dmetaphone';


ALTER FUNCTION public.dmetaphone(text) OWNER TO postgres;

--
-- Name: dmetaphone_alt(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dmetaphone_alt(text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'dmetaphone_alt';


ALTER FUNCTION public.dmetaphone_alt(text) OWNER TO postgres;

--
-- Name: dxsyn_init(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dxsyn_init(internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/dict_xsyn', 'dxsyn_init';


ALTER FUNCTION public.dxsyn_init(internal) OWNER TO postgres;

--
-- Name: dxsyn_lexize(internal, internal, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION dxsyn_lexize(internal, internal, internal, internal) RETURNS internal
    LANGUAGE c STRICT
    AS '$libdir/dict_xsyn', 'dxsyn_lexize';


ALTER FUNCTION public.dxsyn_lexize(internal, internal, internal, internal) OWNER TO postgres;

--
-- Name: g_cube_compress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_compress';


ALTER FUNCTION public.g_cube_compress(internal) OWNER TO postgres;

--
-- Name: g_cube_consistent(internal, cube, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_consistent(internal, cube, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_consistent';


ALTER FUNCTION public.g_cube_consistent(internal, cube, integer, oid, internal) OWNER TO postgres;

--
-- Name: g_cube_decompress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_decompress';


ALTER FUNCTION public.g_cube_decompress(internal) OWNER TO postgres;

--
-- Name: g_cube_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_penalty';


ALTER FUNCTION public.g_cube_penalty(internal, internal, internal) OWNER TO postgres;

--
-- Name: g_cube_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_picksplit';


ALTER FUNCTION public.g_cube_picksplit(internal, internal) OWNER TO postgres;

--
-- Name: g_cube_same(cube, cube, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_same(cube, cube, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_same';


ALTER FUNCTION public.g_cube_same(cube, cube, internal) OWNER TO postgres;

--
-- Name: g_cube_union(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION g_cube_union(internal, internal) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_union';


ALTER FUNCTION public.g_cube_union(internal, internal) OWNER TO postgres;

--
-- Name: gin_extract_trgm(text, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gin_extract_trgm(text, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gin_extract_trgm';


ALTER FUNCTION public.gin_extract_trgm(text, internal) OWNER TO postgres;

--
-- Name: gin_extract_trgm(text, internal, smallint, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gin_extract_trgm(text, internal, smallint, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gin_extract_trgm';


ALTER FUNCTION public.gin_extract_trgm(text, internal, smallint, internal, internal) OWNER TO postgres;

--
-- Name: gin_trgm_consistent(internal, smallint, text, integer, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gin_trgm_consistent(internal, smallint, text, integer, internal, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gin_trgm_consistent';


ALTER FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal) OWNER TO postgres;

--
-- Name: gtrgm_compress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_compress';


ALTER FUNCTION public.gtrgm_compress(internal) OWNER TO postgres;

--
-- Name: gtrgm_consistent(internal, text, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_consistent(internal, text, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_consistent';


ALTER FUNCTION public.gtrgm_consistent(internal, text, integer, oid, internal) OWNER TO postgres;

--
-- Name: gtrgm_decompress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_decompress';


ALTER FUNCTION public.gtrgm_decompress(internal) OWNER TO postgres;

--
-- Name: gtrgm_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_penalty';


ALTER FUNCTION public.gtrgm_penalty(internal, internal, internal) OWNER TO postgres;

--
-- Name: gtrgm_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_picksplit';


ALTER FUNCTION public.gtrgm_picksplit(internal, internal) OWNER TO postgres;

--
-- Name: gtrgm_same(gtrgm, gtrgm, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_same(gtrgm, gtrgm, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_same';


ALTER FUNCTION public.gtrgm_same(gtrgm, gtrgm, internal) OWNER TO postgres;

--
-- Name: gtrgm_union(bytea, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION gtrgm_union(bytea, internal) RETURNS integer[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_union';


ALTER FUNCTION public.gtrgm_union(bytea, internal) OWNER TO postgres;

--
-- Name: levenshtein(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION levenshtein(text, text) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'levenshtein';


ALTER FUNCTION public.levenshtein(text, text) OWNER TO postgres;

--
-- Name: levenshtein(text, text, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION levenshtein(text, text, integer, integer, integer) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'levenshtein_with_costs';


ALTER FUNCTION public.levenshtein(text, text, integer, integer, integer) OWNER TO postgres;

--
-- Name: log_event(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION log_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
  INSERT INTO logs (event_id, old_title, old_starts, old_ends)
  VALUES (OLD.event_id, OLD.title, OLD.starts, OLD.ends);
  RAISE NOTICE 'Someone just changed event #%', OLD.event_id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.log_event() OWNER TO postgres;

--
-- Name: metaphone(text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION metaphone(text, integer) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'metaphone';


ALTER FUNCTION public.metaphone(text, integer) OWNER TO postgres;

--
-- Name: normal_rand(integer, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION normal_rand(integer, double precision, double precision) RETURNS SETOF double precision
    LANGUAGE c STRICT
    AS '$libdir/tablefunc', 'normal_rand';


ALTER FUNCTION public.normal_rand(integer, double precision, double precision) OWNER TO postgres;

--
-- Name: set_limit(real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION set_limit(real) RETURNS real
    LANGUAGE c STRICT
    AS '$libdir/pg_trgm', 'set_limit';


ALTER FUNCTION public.set_limit(real) OWNER TO postgres;

--
-- Name: show_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION show_limit() RETURNS real
    LANGUAGE c STABLE STRICT
    AS '$libdir/pg_trgm', 'show_limit';


ALTER FUNCTION public.show_limit() OWNER TO postgres;

--
-- Name: show_trgm(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION show_trgm(text) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'show_trgm';


ALTER FUNCTION public.show_trgm(text) OWNER TO postgres;

--
-- Name: similarity(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION similarity(text, text) RETURNS real
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'similarity';


ALTER FUNCTION public.similarity(text, text) OWNER TO postgres;

--
-- Name: similarity_op(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION similarity_op(text, text) RETURNS boolean
    LANGUAGE c STABLE STRICT
    AS '$libdir/pg_trgm', 'similarity_op';


ALTER FUNCTION public.similarity_op(text, text) OWNER TO postgres;

--
-- Name: soundex(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION soundex(text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'soundex';


ALTER FUNCTION public.soundex(text) OWNER TO postgres;

--
-- Name: text_soundex(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION text_soundex(text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/fuzzystrmatch', 'soundex';


ALTER FUNCTION public.text_soundex(text) OWNER TO postgres;

--
-- Name: %; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR % (
    PROCEDURE = similarity_op,
    LEFTARG = text,
    RIGHTARG = text,
    COMMUTATOR = %,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.% (text, text) OWNER TO postgres;

--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR && (
    PROCEDURE = cube_overlap,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = &&,
    RESTRICT = areasel,
    JOIN = areajoinsel
);


ALTER OPERATOR public.&& (cube, cube) OWNER TO postgres;

--
-- Name: <; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR < (
    PROCEDURE = cube_lt,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


ALTER OPERATOR public.< (cube, cube) OWNER TO postgres;

--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR <= (
    PROCEDURE = cube_le,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


ALTER OPERATOR public.<= (cube, cube) OWNER TO postgres;

--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR <> (
    PROCEDURE = cube_ne,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


ALTER OPERATOR public.<> (cube, cube) OWNER TO postgres;

--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR <@ (
    PROCEDURE = cube_contained,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = @>,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.<@ (cube, cube) OWNER TO postgres;

--
-- Name: =; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR = (
    PROCEDURE = cube_eq,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = =,
    NEGATOR = <>,
    MERGES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


ALTER OPERATOR public.= (cube, cube) OWNER TO postgres;

--
-- Name: >; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR > (
    PROCEDURE = cube_gt,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


ALTER OPERATOR public.> (cube, cube) OWNER TO postgres;

--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR >= (
    PROCEDURE = cube_ge,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


ALTER OPERATOR public.>= (cube, cube) OWNER TO postgres;

--
-- Name: @; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR @ (
    PROCEDURE = cube_contains,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = ~,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.@ (cube, cube) OWNER TO postgres;

--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR @> (
    PROCEDURE = cube_contains,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.@> (cube, cube) OWNER TO postgres;

--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR ~ (
    PROCEDURE = cube_contained,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = @,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.~ (cube, cube) OWNER TO postgres;

--
-- Name: cube_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS cube_ops
    DEFAULT FOR TYPE cube USING btree AS
    OPERATOR 1 <(cube,cube) ,
    OPERATOR 2 <=(cube,cube) ,
    OPERATOR 3 =(cube,cube) ,
    OPERATOR 4 >=(cube,cube) ,
    OPERATOR 5 >(cube,cube) ,
    FUNCTION 1 cube_cmp(cube,cube);


ALTER OPERATOR CLASS public.cube_ops USING btree OWNER TO postgres;

--
-- Name: gin_trgm_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS gin_trgm_ops
    FOR TYPE text USING gin AS
    STORAGE integer ,
    OPERATOR 1 %(text,text) ,
    FUNCTION 1 btint4cmp(integer,integer) ,
    FUNCTION 2 gin_extract_trgm(text,internal) ,
    FUNCTION 3 gin_extract_trgm(text,internal,smallint,internal,internal) ,
    FUNCTION 4 gin_trgm_consistent(internal,smallint,text,integer,internal,internal);


ALTER OPERATOR CLASS public.gin_trgm_ops USING gin OWNER TO postgres;

--
-- Name: gist_cube_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS gist_cube_ops
    DEFAULT FOR TYPE cube USING gist AS
    OPERATOR 3 &&(cube,cube) ,
    OPERATOR 6 =(cube,cube) ,
    OPERATOR 7 @>(cube,cube) ,
    OPERATOR 8 <@(cube,cube) ,
    OPERATOR 13 @(cube,cube) ,
    OPERATOR 14 ~(cube,cube) ,
    FUNCTION 1 g_cube_consistent(internal,cube,integer,oid,internal) ,
    FUNCTION 2 g_cube_union(internal,internal) ,
    FUNCTION 3 g_cube_compress(internal) ,
    FUNCTION 4 g_cube_decompress(internal) ,
    FUNCTION 5 g_cube_penalty(internal,internal,internal) ,
    FUNCTION 6 g_cube_picksplit(internal,internal) ,
    FUNCTION 7 g_cube_same(cube,cube,internal);


ALTER OPERATOR CLASS public.gist_cube_ops USING gist OWNER TO postgres;

--
-- Name: gist_trgm_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS gist_trgm_ops
    FOR TYPE text USING gist AS
    STORAGE gtrgm ,
    OPERATOR 1 %(text,text) ,
    FUNCTION 1 gtrgm_consistent(internal,text,integer,oid,internal) ,
    FUNCTION 2 gtrgm_union(bytea,internal) ,
    FUNCTION 3 gtrgm_compress(internal) ,
    FUNCTION 4 gtrgm_decompress(internal) ,
    FUNCTION 5 gtrgm_penalty(internal,internal,internal) ,
    FUNCTION 6 gtrgm_picksplit(internal,internal) ,
    FUNCTION 7 gtrgm_same(gtrgm,gtrgm,internal);


ALTER OPERATOR CLASS public.gist_trgm_ops USING gist OWNER TO postgres;

--
-- Name: xsyn_template; Type: TEXT SEARCH TEMPLATE; Schema: public; Owner: 
--

CREATE TEXT SEARCH TEMPLATE xsyn_template (
    INIT = dxsyn_init,
    LEXIZE = dxsyn_lexize );


--
-- Name: xsyn; Type: TEXT SEARCH DICTIONARY; Schema: public; Owner: postgres
--

CREATE TEXT SEARCH DICTIONARY xsyn (
    TEMPLATE = xsyn_template );


ALTER TEXT SEARCH DICTIONARY public.xsyn OWNER TO postgres;

--
-- Name: TEXT SEARCH DICTIONARY xsyn; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON TEXT SEARCH DICTIONARY xsyn IS 'eXtended synonym dictionary';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE cities (
    name text NOT NULL,
    postal_code character varying(9) NOT NULL,
    country_code character(2) NOT NULL,
    CONSTRAINT cities_postal_code_check CHECK (((postal_code)::text <> ''::text))
);


ALTER TABLE public.cities OWNER TO postgres;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE countries (
    country_code character(2) NOT NULL,
    country_name text
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE events (
    event_id integer NOT NULL,
    title character varying(255),
    starts timestamp without time zone,
    ends timestamp without time zone,
    venue_id integer,
    colors text[]
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.events_event_id_seq OWNER TO postgres;

--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE events_event_id_seq OWNED BY events.event_id;


--
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('events_event_id_seq', 16, true);


--
-- Name: holidays; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW holidays AS
    SELECT events.event_id AS holiday_id, events.title AS name, events.ends AS date, events.colors FROM events WHERE (((events.title)::text ~~ '%Day%'::text) AND (events.venue_id IS NULL));


ALTER TABLE public.holidays OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE logs (
    event_id integer,
    old_title character varying(255),
    old_starts timestamp without time zone,
    old_ends timestamp without time zone,
    logged_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: venues; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE venues (
    venue_id integer NOT NULL,
    name character varying(255),
    street_address text,
    type character(7) DEFAULT 'public'::bpchar,
    postal_code character varying(9),
    country_code character(2),
    active boolean DEFAULT true,
    CONSTRAINT venues_type_check CHECK ((type = ANY (ARRAY['public'::bpchar, 'private'::bpchar])))
);


ALTER TABLE public.venues OWNER TO postgres;

--
-- Name: venues_venue_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE venues_venue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.venues_venue_id_seq OWNER TO postgres;

--
-- Name: venues_venue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE venues_venue_id_seq OWNED BY venues.venue_id;


--
-- Name: venues_venue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('venues_venue_id_seq', 4, true);


--
-- Name: event_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY events ALTER COLUMN event_id SET DEFAULT nextval('events_event_id_seq'::regclass);


--
-- Name: venue_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY venues ALTER COLUMN venue_id SET DEFAULT nextval('venues_venue_id_seq'::regclass);


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY cities (name, postal_code, country_code) FROM stdin;
Portland	97205	us
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY countries (country_code, country_name) FROM stdin;
us	United States
mx	Mexico
au	Australia
gb	United Kingdom
de	Germany
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY events (event_id, title, starts, ends, venue_id, colors) FROM stdin;
2	Stomp the Giants	2012-10-31 00:00:00	2012-10-31 00:00:00	1	\N
3	Ed Birthday	2012-10-31 00:00:00	2012-10-31 00:00:00	1	\N
4	Goofing Around	2014-01-12 00:00:00	2014-01-12 00:00:00	2	\N
5	Minecraft Rally	2014-08-03 00:00:00	2014-08-03 00:00:00	\N	\N
8	Minecraft Rally II	2012-02-12 00:00:00	2012-02-12 00:00:00	2	\N
9	Queen of the Demonweb Pits	2012-03-12 00:00:00	2012-03-12 00:00:00	3	\N
11	Secret of the Slaver's Stockade	2012-10-12 00:00:00	2012-10-12 00:00:00	2	\N
12	House Party	2012-05-03 23:00:00	2012-05-04 01:00:00	4	\N
14	April Fool's Day	2012-01-12 00:00:00	2012-04-01 00:00:00	\N	\N
15	Guy Faulk's Day	2012-02-12 00:00:00	2012-11-05 00:00:00	\N	\N
13	Valentine's Day	2012-02-14 00:00:00	2012-02-14 00:00:00	\N	{red}
16	President's Day	2012-02-20 00:00:00	2012-02-20 00:00:00	\N	{red,white,blue}
6	Moby	2012-01-12 00:00:00	2012-02-14 00:00:00	2	\N
7	Led Zeppelin	2012-01-12 00:00:00	2012-02-11 00:00:00	2	\N
10	Stars without Number	2012-01-12 00:00:00	2012-02-11 00:00:00	3	\N
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY logs (event_id, old_title, old_starts, old_ends, logged_at) FROM stdin;
12	House Party	2012-05-03 23:00:00	2012-05-04 02:00:00	2015-09-19 13:53:51.389917
13	Valentine's Day	2012-01-12 00:00:00	2012-02-14 00:00:00	2015-09-19 23:30:22.466922
16	President's Day	2012-03-12 00:00:00	2012-02-20 00:00:00	2015-09-19 23:30:49.907094
6	Moby	2012-01-12 00:00:00	2012-01-12 00:00:00	2015-09-20 16:15:39.187009
7	Led Zeppelin	2012-01-12 00:00:00	2012-01-12 00:00:00	2015-09-20 16:16:19.562018
10	Stars without Number	2012-01-12 00:00:00	2012-01-12 00:00:00	2015-09-20 16:16:37.608997
\.


--
-- Data for Name: venues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY venues (venue_id, name, street_address, type, postal_code, country_code, active) FROM stdin;
1	Crystal Ballroom	\N	public 	97205	us	t
3	Happy Gillmore	\N	public 	97205	us	t
4	Run's House	\N	public 	97205	us	t
2	Voodoo Donuts	\N	public 	97205	us	f
\.


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (country_code, postal_code);


--
-- Name: countries_country_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_country_name_key UNIQUE (country_name);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_code);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: venues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (venue_id);


--
-- Name: events_starts; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX events_starts ON events USING btree (starts);


--
-- Name: events_title; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX events_title ON events USING hash (title);


--
-- Name: deactive_venue; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE deactive_venue AS ON DELETE TO venues DO INSTEAD UPDATE venues SET active = false WHERE ((venues.name)::text = (old.name)::text);


--
-- Name: update_holidays; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE update_holidays AS ON UPDATE TO holidays DO INSTEAD UPDATE events SET title = new.name, starts = new.date, colors = new.colors WHERE ((events.title)::text = (old.name)::text);


--
-- Name: log_events; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER log_events
    AFTER UPDATE ON events
    FOR EACH ROW
    EXECUTE PROCEDURE log_event();


--
-- Name: cities_country_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_country_code_fkey FOREIGN KEY (country_code) REFERENCES countries(country_code);


--
-- Name: events_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES venues(venue_id);


--
-- Name: venues_country_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_country_code_fkey FOREIGN KEY (country_code, postal_code) REFERENCES cities(country_code, postal_code) MATCH FULL;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: cities; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE cities FROM PUBLIC;
REVOKE ALL ON TABLE cities FROM postgres;
GRANT ALL ON TABLE cities TO postgres;
GRANT ALL ON TABLE cities TO vagrant;


--
-- Name: events; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE events FROM PUBLIC;
REVOKE ALL ON TABLE events FROM postgres;
GRANT ALL ON TABLE events TO postgres;
GRANT ALL ON TABLE events TO vagrant;


--
-- PostgreSQL database dump complete
--

