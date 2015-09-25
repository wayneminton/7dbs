select
    to_char(date_trunc('week', m.day), 'YYYY-MM-DD') as week_of,
    to_char(m.day, 'Dy') as dow,
    e.count as num_events
from (
    select ends, count(*)
    from events
    where ends >= '2012-2-1' and ends < '2012-3-1'
    group by ends
    order by ends
) as e
right join (
    select * from generate_series('2012-2-1'::timestamp, '2012-3-1', '1 Day')
    as day
    where day >= '2012-2-1' and day < '2012-3-1'
) as m
on m.day = e.ends
order by day;

