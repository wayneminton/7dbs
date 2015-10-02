--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: weekdays; Type: TYPE; Schema: public; Owner: -
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


--
-- Name: add_event(text, timestamp without time zone, timestamp without time zone, text, character varying, character); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: find_movies_like(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION find_movies_like(text) RETURNS TABLE(title text)
    LANGUAGE sql
    AS $_$
    select m.title
    from movies m, (SELECT genre, title from movies where lower(title) = lower($1)) s
    where cube_enlarge(s.genre, 5, 18) @> s.genre and lower($1) <> lower(m.title)
    order by cube_distance(m.genre, s.genre)
    limit 10;
$_$;


--
-- Name: is_actor(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION is_actor(text) RETURNS boolean
    LANGUAGE plpgsql
    AS $_$
declare
    result int;
begin

    select actor_id into result from actors
    where lower(name) = lower($1) limit 1;

    return found;
end;
$_$;


--
-- Name: log_event(); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: movies_from_actor(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION movies_from_actor(text) RETURNS TABLE(title text)
    LANGUAGE sql
    AS $_$
    select m.title
    from movies_actors ma
    inner join (select actor_id from actors where lower(name) = lower($1) limit 1) as a
    on ma.actor_id = a.actor_id
    inner join movies as m
    on ma.movie_id = m.movie_id
    order by m.movie_id
    limit 5;
$_$;


--
-- Name: search_movies(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION search_movies(text) RETURNS TABLE(title text)
    LANGUAGE plpgsql
    AS $_$
begin
    if is_actor($1) then
        return query select movies_from_actor($1);
    end if;
    return query select find_movies_like($1);
end;
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: actors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE actors (
    actor_id integer NOT NULL,
    name text
);


--
-- Name: actors_actor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE actors_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actors_actor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE actors_actor_id_seq OWNED BY actors.actor_id;


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    name text NOT NULL,
    postal_code character varying(9) NOT NULL,
    country_code character(2) NOT NULL,
    CONSTRAINT cities_postal_code_check CHECK (((postal_code)::text <> ''::text))
);


--
-- Name: countries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    country_code character(2) NOT NULL,
    country_name text
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE events (
    event_id integer NOT NULL,
    title character varying(255),
    starts timestamp without time zone,
    ends timestamp without time zone,
    venue_id integer,
    colors text[]
);


--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_event_id_seq OWNED BY events.event_id;


--
-- Name: genres; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genres (
    name text,
    "position" integer
);


--
-- Name: holidays; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW holidays AS
 SELECT events.event_id AS holiday_id,
    events.title AS name,
    events.ends AS date,
    events.colors
   FROM events
  WHERE (((events.title)::text ~~ '%Day%'::text) AND (events.venue_id IS NULL));


--
-- Name: logs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE logs (
    event_id integer,
    old_title character varying(255),
    old_starts timestamp without time zone,
    old_ends timestamp without time zone,
    logged_at timestamp without time zone DEFAULT now()
);


--
-- Name: movies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE movies (
    movie_id integer NOT NULL,
    title text,
    genre ext.cube
);


--
-- Name: movies_actors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE movies_actors (
    movie_id integer NOT NULL,
    actor_id integer NOT NULL
);


--
-- Name: movies_movie_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE movies_movie_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: movies_movie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE movies_movie_id_seq OWNED BY movies.movie_id;


--
-- Name: venues; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: venues_venue_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE venues_venue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: venues_venue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE venues_venue_id_seq OWNED BY venues.venue_id;


--
-- Name: actor_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY actors ALTER COLUMN actor_id SET DEFAULT nextval('actors_actor_id_seq'::regclass);


--
-- Name: event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN event_id SET DEFAULT nextval('events_event_id_seq'::regclass);


--
-- Name: movie_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY movies ALTER COLUMN movie_id SET DEFAULT nextval('movies_movie_id_seq'::regclass);


--
-- Name: venue_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues ALTER COLUMN venue_id SET DEFAULT nextval('venues_venue_id_seq'::regclass);


--
-- Name: actors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY actors
    ADD CONSTRAINT actors_pkey PRIMARY KEY (actor_id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (country_code, postal_code);


--
-- Name: countries_country_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_country_name_key UNIQUE (country_name);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_code);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: genres_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genres
    ADD CONSTRAINT genres_name_key UNIQUE (name);


--
-- Name: movies_actors_movie_id_actor_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY movies_actors
    ADD CONSTRAINT movies_actors_movie_id_actor_id_key UNIQUE (movie_id, actor_id);


--
-- Name: movies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (movie_id);


--
-- Name: venues_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (venue_id);


--
-- Name: events_starts; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_starts ON events USING btree (starts);


--
-- Name: events_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX events_title ON events USING hash (title);


--
-- Name: movies_actors_actor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX movies_actors_actor_id ON movies_actors USING btree (actor_id);


--
-- Name: movies_actors_movie_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX movies_actors_movie_id ON movies_actors USING btree (movie_id);


--
-- Name: movies_genres_cube; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX movies_genres_cube ON movies USING gist (genre);


--
-- Name: deactive_venue; Type: RULE; Schema: public; Owner: -
--

CREATE RULE deactive_venue AS
    ON DELETE TO venues DO INSTEAD  UPDATE venues SET active = false
  WHERE ((venues.name)::text = (old.name)::text);


--
-- Name: update_holidays; Type: RULE; Schema: public; Owner: -
--

CREATE RULE update_holidays AS
    ON UPDATE TO holidays DO INSTEAD  UPDATE events SET title = new.name, starts = new.date, colors = new.colors
  WHERE ((events.title)::text = (old.name)::text);


--
-- Name: log_events; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER log_events AFTER UPDATE ON events FOR EACH ROW EXECUTE PROCEDURE log_event();


--
-- Name: cities_country_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_country_code_fkey FOREIGN KEY (country_code) REFERENCES countries(country_code);


--
-- Name: events_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES venues(venue_id);


--
-- Name: movies_actors_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY movies_actors
    ADD CONSTRAINT movies_actors_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES actors(actor_id);


--
-- Name: movies_actors_movie_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY movies_actors
    ADD CONSTRAINT movies_actors_movie_id_fkey FOREIGN KEY (movie_id) REFERENCES movies(movie_id);


--
-- Name: venues_country_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY venues
    ADD CONSTRAINT venues_country_code_fkey FOREIGN KEY (country_code, postal_code) REFERENCES cities(country_code, postal_code) MATCH FULL;


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;

ALTER DATABASE book SET search_path TO public, ext, pg_catalog;

--
-- PostgreSQL database dump complete
--

