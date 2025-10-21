/*
Simple is best

- Don't count distinct if you don't have to
- Table statistics / analyze
- Beware of Hints / Trust the Optimizer
*/

/***************************************************************************************
Don't count distinct if you don't have to.
***************************************************************************************/

select wheelchair_accessible_key, wheelchair_accessible_desc, count(distinct vehicle_license_number) total_vehicles_slow
from fake_rides 
    join for_hire_vehicles using (vehicle_license_number)
    join wheelchair_access using (wheelchair_accessible_key)
group by wheelchair_accessible_key, wheelchair_accessible_desc;
--  wheelchair_accessible_key | wheelchair_accessible_desc | total_vehicles_slow 
-- ---------------------------+----------------------------+---------------------
--                          0 | Missing                    |               96951
--                          1 | WAV                        |                7432
--                          2 | PILOT                      |                 477
-- (3 rows)
-- Time: 561538.682 ms (09:21.539)

--  GroupAggregate  (cost=24611357.51..52195511.73 rows=600 width=50)
--    Group Key: for_hire_vehicles.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--    ->  Gather Merge  (cost=24611357.51..50526658.53 rows=222512960 width=49)
--          Workers Planned: 2
--          ->  Sort  (cost=24610357.49..24842141.82 rows=92713733 width=49)
--                Sort Key: for_hire_vehicles.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--                ->  Hash Join  (cost=2523.60..2834635.54 rows=92713733 width=49)
--                      Hash Cond: (for_hire_vehicles.wheelchair_accessible_key = wheelchair_access.wheelchair_accessible_key)
--                      ->  Parallel Hash Join  (cost=2488.85..2590289.57 rows=92713733 width=11)
--                            Hash Cond: ((fake_rides.vehicle_license_number)::text = (for_hire_vehicles.vehicle_license_number)::text)
--                            ->  Parallel Seq Scan on fake_rides  (cost=0.00..2344417.33 rows=92713733 width=7)
--                            ->  Parallel Hash  (cost=1717.82..1717.82 rows=61682 width=11)
--                                  ->  Parallel Seq Scan on for_hire_vehicles  (cost=0.00..1717.82 rows=61682 width=11)
--                      ->  Hash  (cost=21.00..21.00 rows=1100 width=42)
--                            ->  Seq Scan on wheelchair_access  (cost=0.00..21.00 rows=1100 width=42)

select wheelchair_accessible_key, wheelchair_accessible_desc, count(*) total_vehicles_med
from for_hire_vehicles v
    join wheelchair_access using (wheelchair_accessible_key)
where exists(select 1 from fake_rides r where r.vehicle_license_number = v.vehicle_license_number)
group by wheelchair_accessible_key, wheelchair_accessible_desc;
--  wheelchair_accessible_key | wheelchair_accessible_desc | total_vehicles_med 
-- ---------------------------+----------------------------+--------------------
--                          0 | Missing                    |              96951
--                          1 | WAV                        |               7432
--                          2 | PILOT                      |                477
-- (3 rows)
-- Time: 96182.129 ms (01:36.182)

--  Finalize GroupAggregate  (cost=4244463.49..4245160.18 rows=600 width=50)
--    Group Key: v.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--    ->  Gather Merge  (cost=4244463.49..4245149.68 rows=600 width=50)
--          Workers Planned: 1
--          ->  Partial GroupAggregate  (cost=4243463.48..4244082.17 rows=600 width=50)
--                Group Key: v.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--                ->  Sort  (cost=4243463.48..4243616.66 rows=61269 width=42)
--                      Sort Key: v.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--                      ->  Merge Join  (cost=4235780.68..4236705.22 rows=61269 width=42)
--                            Merge Cond: (v.wheelchair_accessible_key = wheelchair_access.wheelchair_accessible_key)
--                            ->  Sort  (cost=4235704.12..4235857.29 rows=61269 width=4)
--                                  Sort Key: v.wheelchair_accessible_key
--                                  ->  Parallel Hash Semi Join  (cost=3865503.00..4230832.35 rows=61269 width=4)
--                                        Hash Cond: ((v.vehicle_license_number)::text = (r.vehicle_license_number)::text)
--                                        ->  Parallel Seq Scan on for_hire_vehicles v  (cost=0.00..1717.82 rows=61682 width=11)
--                                        ->  Parallel Hash  (cost=2344417.33..2344417.33 rows=92713733 width=7)
--                                              ->  Parallel Seq Scan on fake_rides r  (cost=0.00..2344417.33 rows=92713733 width=7)
--                            ->  Sort  (cost=76.57..79.32 rows=1100 width=42)
--                                  Sort Key: wheelchair_access.wheelchair_accessible_key
--                                  ->  Seq Scan on wheelchair_access  (cost=0.00..21.00 rows=1100 width=42)

select * from wheelchair_access;
--  wheelchair_accessible_key | wheelchair_accessible_desc | total_vehicles 
-- ---------------------------+----------------------------+----------------
--                          0 | Missing                    |          96951
--                          1 | WAV                        |           7432
--                          2 | PILOT                      |            477
-- (3 rows)
-- Time: 14.905 ms

/***************************************************************************************
What does the query planner know about your tables?
***************************************************************************************/

