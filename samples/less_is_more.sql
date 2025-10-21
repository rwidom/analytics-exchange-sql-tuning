/***************************************************************************************

LESS IS MORE
- or at least less is faster
- order of execution
- filtering early and often

***************************************************************************************/

\timing on

/***************************************************************************************
Compare timing for counts and sample rows across tables of different sizes
***************************************************************************************/

select * from wheelchair_access limit 10;
--  wheelchair_accessible_key | wheelchair_accessible_desc | total_vehicles 
-- ---------------------------+----------------------------+----------------
--                          0 | Missing                    |          96951
--                          1 | WAV                        |           7432
--                          2 | PILOT                      |            477
-- (3 rows)

-- Time: 3.325 ms

select count(*) from wheelchair_access;
--  count 
-- -------
--      3
-- (1 row)

-- Time: 13.802 ms

SELECT octet_length(t.*::text) sample_text_length
FROM wheelchair_access AS t 
limit 1;
--  text_length 
-- -------------
--           17
-- (1 row)

-- Time: 26.976 ms

select * from bases limit 10;
-- base_key | base_number |             base_name             | base_type | base_telephone_number |          website           |                  base_address                  
-- ----------+-------------+-----------------------------------+-----------+-----------------------+----------------------------+------------------------------------------------
--      3152 | B03152      | EXIT LUXURY INC.                  | BLACK-CAR | (718)472-9800         |                            | 29 - 10   36 AVENUE LONGISLAND CITY NY 11106
--      3036 | B03036      | ZYNC INC                          | BLACK-CAR | (718)482-1818         |                            | 12-04   44 AVENUE LIC NY 11101
--       171 | B00171      | CURB TRANSPORTATION SERVICES LLC. | LIVERY    | (718)222-0600         | WWW.CURBTRANSPORTATION.COM | 11 - 11   34 AVENUE ASTORIA NY 11106
--      1899 | B01899      | ALLSTATE PRIVATE CAR & LIMO,INC   | BLACK-CAR | (212)741-1562         |                            | 241   37 STREET STE#1-4-B443 BROOKLYN NY 11232
--      3038 | B03038      | SOUTH BRONX TRANSPORTATION,INC.   | BLACK-CAR | (347)590-7005         | WWW.SOUTHBRONXTRANS.COM    | 250 BROOK AVENUE BRONX NY 10454
--      3407 | B03407      | ZOOM TRANSIT INC                  | BLACK-CAR | (718)583-9100         |                            | 2078 CROSS BRONX EXPRESSWAY BRONX NY 10472
--      2932 | B02932      | GRAND TRANSPORTATION SERVICES INC | BLACK-CAR | (718)433-4255         | WWW.GRANDLIMONY.COM        | 36-13   32 STREET LIC NY 11106
--      2902 | B02902      | NY CAR & LIMO SERVICES INC.       | BLACK-CAR | (718)255-1798         | WWW.NYINSURANCEB.COM       | 71-16   35 AVENUE JACKSON HEIGHTS NY 11372
--      3494 | B03494      | NYC WHEELS CAR SERVICE INC.       | BLACK-CAR | (718)621-4888         |                            | 653 EAST    5 STREET BROOKLYN NY 11218
--      3703 | B03703      | ABDEL TRANSPORTATION INC.         | BLACK-CAR | (347)638-5737         | ABDELTRANSPORTATIONBK.COM  | 97 GRAHAM AVENUE BROOKLYN NY 11206
-- (10 rows)

-- Time: 16.465 ms

select count(*) from bases;
--  count 
-- -------
--    812
-- (1 row)

-- Time: 20.614 ms

SELECT octet_length(t.*::text) sample_text_length
FROM bases AS t 
limit 1;
--  sample_text_length 
-- --------------------
--                 106
-- (1 row)

-- Time: 16.961 ms

select * from for_hire_vehicles limit 10;
--  vehicle_license_number | base_key | wheelchair_accessible_key |      fhv_name      | expiration_date | permit_license_number | dmv_license_plate_number | vehicle_year 
-- ------------------------+----------+---------------------------+--------------------+-----------------+-----------------------+--------------------------+--------------
--  6032728                |     3152 |                         2 | UPPAL, ARSHDEEP    | 2026-06-30      | AA005                 | T117661C                 |         2022
--  5953896                |     3036 |                         0 | ELIHORI,ASIM,SALIH | 2025-11-07      | AA006                 | T790912C                 |         2015
--  5729129                |      171 |                         0 | LORENZO,MARTIN     | 2026-10-12      | AA010                 | T708186C                 |         2023
--  6035913                |     1899 |                         2 | GULYAMOV,,AMINJON  | 2026-06-30      | AA013                 | T118710C                 |         2013
--  6033635                |     3038 |                         2 | KHAN,DEWAN,M       | 2026-06-30      | AA017                 | T143875C                 |         2016
--  6044966                |     3407 |                         0 | KARIM,KAZI,R       | 2027-10-10      | AA020                 | T114974C                 |         2016
--  6039929                |     2932 |                         0 | HOSSAIN,MD,ALAMGIR | 2027-08-21      | AA021                 | T114853C                 |         2023
--  5964337                |     3407 |                         0 | FRIAS,RAFAEL,A     | 2026-08-21      | AA022                 | T806493C                 |         2023
--  6036626                |     2902 |                         0 | AHMED,IQBAL        | 2027-07-21      | AA023                 | T114786C                 |         2012
--  6043991                |     3494 |                         2 | ABSALOMOV, ILKHOM  | 2026-06-30      | AA025                 | T142329C                 |         2014
-- (10 rows)

-- Time: 6.299 ms

select count(*) from for_hire_vehicles;
--  count  
-- --------
--  104860
-- (1 row)

-- Time: 142.584 ms

SELECT octet_length(t.*::text) sample_text_length
FROM for_hire_vehicles AS t 
limit 1;
--  sample_text_length 
-- --------------------
--                  65
-- (1 row)

-- Time: 8.860 ms

select * from fake_rides limit 10;
--  vehicle_license_number |       departure_time       | fare | distance 
-- ------------------------+----------------------------+------+----------
--  5807501                | 2020-01-11 03:42:39.326252 |   92 |       12
--  5799617                | 2020-01-11 15:52:51.192193 |    7 |       16
--  5888602                | 2020-01-11 07:46:19.273584 |   78 |        2
--  5693337                | 2020-01-11 05:22:18.280402 |   76 |        9
--  5580046                | 2020-01-11 06:44:06.542563 |   80 |        5
--  5490380                | 2020-01-11 01:39:34.375921 |   54 |        1
--  5834925                | 2020-01-11 17:20:50.311893 |   80 |       18
--  5727299                | 2020-01-11 17:06:42.553144 |   77 |       14
--  5834998                | 2020-01-11 14:00:39.314206 |   58 |        4
--  5070991                | 2020-01-11 01:25:46.073507 |    9 |        2
-- (10 rows)

-- Time: 17.404 ms

select count(*) from fake_rides;
--    count   
-- -----------
--  222512920
-- (1 row)

-- Time: 27021.725 ms (00:27.022)

SELECT octet_length(t.*::text) sample_text_length
FROM fake_rides AS t 
limit 1;
--  sample_text_length 
-- --------------------
--                  44
-- (1 row)

-- Time: 15.383 ms

explain (select count(*) from fake_rides);

explain (select * from fake_rides limit 10);

/***************************************************************************************
Logical Order of Execution
***************************************************************************************/

select 
    -- 6. DISTINCT
    distinct
    -- 5. SELECT
    wheelchair_accessible_key, wheelchair_accessible_desc, count(*) records
-- 1. FROM / JOIN
from for_hire_vehicles
    join bases using (base_key)
    join wheelchair_access using (wheelchair_accessible_key)
-- 2. WHERE (including for example `WHERE rownum<=10` in Oracle)
where bases.base_type = 'BLACK-CAR' -- (rownum<=x in Oracle, executed in this order)
-- 3. GROUP BY
group by wheelchair_accessible_key, wheelchair_accessible_desc
-- 4. HAVING
having count(*)>100
-- 7. ORDER BY
order by wheelchair_accessible_key
-- 8. LIMIT / OFFSET / TOP / FETCH (top x, in mssql executed in this order)
limit 10;

-- Moving the filter to the subquery here does not change the optimizer plan, because
-- they are logically the same.
select 
    distinct
    wheelchair_accessible_key, wheelchair_accessible_desc,
    count(*) records
from for_hire_vehicles
    join (select * from bases where base_type = 'BLACK-CAR') bases 
        using (base_key)
    join wheelchair_access using (wheelchair_accessible_key)
group by wheelchair_accessible_key, wheelchair_accessible_desc
having count(*)>100
order by wheelchair_accessible_key
limit 10;

/***************************************************************************************
filtering early and often
***************************************************************************************/

-- Because we are filtering across tables and using something other than =, the
-- query optimizer has to wait until it has merged the tables to apply the filter.
select wheelchair_accessible_key, wheelchair_accessible_desc, count(*) pilot_ride_count
from fake_rides
    join for_hire_vehicles using (vehicle_license_number)
    join wheelchair_access using (wheelchair_accessible_key)
where wheelchair_accessible_desc='PILOT' and fare<wheelchair_accessible_key
group by wheelchair_accessible_key, wheelchair_accessible_desc;
--  wheelchair_accessible_key | wheelchair_accessible_desc | pilot_ride_count 
-- ---------------------------+----------------------------+------------------
--                          2 | PILOT                      |            10167
-- (1 row)

-- Time: 36302.501 ms (00:36.303)
--                                                               QUERY PLAN                                                                 
-- -------------------------------------------------------------------------------------------------------------------------------------------
--  Finalize GroupAggregate  (cost=2692194.56..2693878.91 rows=18 width=50)
--    Group Key: for_hire_vehicles.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--    ->  Gather Merge  (cost=2692194.56..2693878.46 rows=36 width=50)
--          Workers Planned: 2
--          ->  Partial GroupAggregate  (cost=2691194.54..2692874.29 rows=18 width=50)
--                Group Key: for_hire_vehicles.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--                ->  Sort  (cost=2691194.54..2691614.43 rows=167957 width=42)
--                      Sort Key: for_hire_vehicles.wheelchair_accessible_key
--                      ->  Hash Join  (cost=2512.67..2671448.27 rows=167957 width=42)
--                            Hash Cond: (for_hire_vehicles.wheelchair_accessible_key = wheelchair_access.wheelchair_accessible_key)
--                            ->  Parallel Hash Join  (cost=2488.85..2590283.74 rows=30792110 width=4)
--                                  Hash Cond: ((fake_rides.vehicle_license_number)::text = (for_hire_vehicles.vehicle_license_number)::text)
--                                  Join Filter: (fake_rides.fare < for_hire_vehicles.wheelchair_accessible_key)
--                                  ->  Parallel Seq Scan on fake_rides  (cost=0.00..2344417.33 rows=92713733 width=11)
--                                  ->  Parallel Hash  (cost=1717.82..1717.82 rows=61682 width=11)
--                                        ->  Parallel Seq Scan on for_hire_vehicles  (cost=0.00..1717.82 rows=61682 width=11)
--                            ->  Hash  (cost=23.75..23.75 rows=6 width=42)
--                                  ->  Seq Scan on wheelchair_access  (cost=0.00..23.75 rows=6 width=42)
--                                        Filter: ((wheelchair_accessible_desc)::text = 'PILOT'::text)
-- JIT:
--    Functions: 30
--    Options: Inlining true, Optimization true, Expressions true, Deforming true
-- (22 rows)


-- If everyone knows that wheelchair_accessible_key is 2, and we don't expect that to
-- change, we can save a bunch (~ 1/3) of time by just giving the database the number.
select wheelchair_accessible_key, wheelchair_accessible_desc, count(*) pilot_ride_count
from fake_rides
    join for_hire_vehicles using (vehicle_license_number)
    join wheelchair_access using (wheelchair_accessible_key)
where wheelchair_accessible_desc='PILOT' and fare<2
group by wheelchair_accessible_key, wheelchair_accessible_desc;
--  wheelchair_accessible_key | wheelchair_accessible_desc | pilot_ride_count 
-- ---------------------------+----------------------------+------------------
--                          2 | PILOT                      |            10167
-- (1 row)

-- Time: 26505.659 ms (00:26.506)
--                                                                   QUERY PLAN                                                                  
-- ----------------------------------------------------------------------------------------------------------------------------------------------
--  Finalize GroupAggregate  (cost=2582964.82..2583020.49 rows=18 width=50)
--    Group Key: for_hire_vehicles.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--    ->  Gather Merge  (cost=2582964.82..2583020.04 rows=36 width=50)
--          Workers Planned: 2
--          ->  Partial GroupAggregate  (cost=2581964.80..2582015.87 rows=18 width=50)
--                Group Key: for_hire_vehicles.wheelchair_accessible_key, wheelchair_access.wheelchair_accessible_desc
--                ->  Sort  (cost=2581964.80..2581977.52 rows=5089 width=42)
--                      Sort Key: for_hire_vehicles.wheelchair_accessible_key
--                      ->  Parallel Hash Join  (cost=1908.39..2581651.49 rows=5089 width=42)
--                            Hash Cond: ((fake_rides.vehicle_license_number)::text = (for_hire_vehicles.vehicle_license_number)::text)
--                            ->  Parallel Seq Scan on fake_rides  (cost=0.00..2576201.67 rows=936409 width=7)
--                                  Filter: (fare < 2)
--                            ->  Parallel Hash  (cost=1904.19..1904.19 rows=336 width=49)
--                                  ->  Hash Join  (cost=23.82..1904.19 rows=336 width=49)
--                                        Hash Cond: (for_hire_vehicles.wheelchair_accessible_key = wheelchair_access.wheelchair_accessible_key)
--                                        ->  Parallel Seq Scan on for_hire_vehicles  (cost=0.00..1717.82 rows=61682 width=11)
--                                        ->  Hash  (cost=23.75..23.75 rows=6 width=42)
--                                              ->  Seq Scan on wheelchair_access  (cost=0.00..23.75 rows=6 width=42)
--                                                    Filter: ((wheelchair_accessible_desc)::text = 'PILOT'::text)
--  JIT:
--    Functions: 30
--    Options: Inlining true, Optimization true, Expressions true, Deforming true
-- (22 rows)

-- fares are randomly generated, so your results will vary, but just confirming that
-- <2 is about 1% of the records in this table as defined in `init.sql`.
select (case when fare<2 then 'include' else 'exclude' end) fare_filter,
    count(*) fake_ride_records, max(fare) max_fare
from fake_rides
group by (case when fare<2 then 'include' else 'exclude' end) 
order by 2;
--  fare_filter | fake_ride_records | max_fare 
-- -------------+-------------------+----------
--  include     |           2226108 |        1
--  exclude     |         220286812 |      100
-- (2 rows)

-- Time: 29627.440 ms (00:29.627)
