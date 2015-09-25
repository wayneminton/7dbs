create or replace function find_events(int)
returns table(
    id int,
    title text
)
as $$
    SELECT event_id, title FROM events WHERE venue_id = $1;
$$ language 'sql';
