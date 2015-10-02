create or replace function find_movies_like(text)
    returns table (title text) as
$$
    select m.title
    from movies m, (SELECT genre, title from movies where lower(title) = lower($1)) s
    where cube_enlarge(s.genre, 5, 18) @> s.genre and lower($1) <> lower(m.title)
    order by cube_distance(m.genre, s.genre)
    limit 10;
$$ language 'sql';

create or replace function is_actor(text)
    returns boolean as
$$
declare
    result int;
begin

    select actor_id into result from actors
    where lower(name) = lower($1) limit 1;

    return found;
end;
$$
language 'plpgsql';

create or replace function movies_from_actor(text)
    returns table(title text) as
$$
    select m.title
    from movies_actors ma
    inner join (select actor_id from actors where lower(name) = lower($1) limit 1) as a
    on ma.actor_id = a.actor_id
    inner join movies as m
    on ma.movie_id = m.movie_id
    order by m.movie_id
    limit 5;
$$
language 'sql';

create or replace function search_movies(text)
    returns table(title text) as
$$
begin
    if is_actor($1) then
        return query select movies_from_actor($1);
    end if;
    return query select find_movies_like($1);
end;
$$
language 'plpgsql';

