/*
Once and done

- using indexes (so that sorting/sifting through things can be done once, but think 
about would you save time go to the index or not, explain plan devils in the details.)
- avoid correlated subqueries
- CTEs and logical vs materialized views
*/

\timing on

/***************************************************************************************
Indexing to make it easier to find things
***************************************************************************************/

-- way less then half of the records, but more than half the time to just count
-- the whole table. why? 
select count(*) from fake_rides where departure_time >= '2025-09-01';
--   count  
-- ---------
--  5452720
-- (1 row)

-- Time: 26447.360 ms (00:26.447)

-- Finalize Aggregate  (cost=2583271.57..2583271.58 rows=1 width=8)
--    ->  Gather  (cost=2583271.35..2583271.56 rows=2 width=8)
--          Workers Planned: 2
--          ->  Partial Aggregate  (cost=2582271.35..2582271.36 rows=1 width=8)
--                ->  Parallel Seq Scan on fake_rides  (cost=0.00..2576201.67 rows=2427874 width=0)
--                      Filter: (departure_time >= '2025-09-01 00:00:00'::timestamp without time zone)

create index ind_departure_time on fake_rides (departure_time);
-- CREATE INDEX
-- Time: 108513.257 ms (01:48.513) -- now, we get the same answer in less than a second, rather than more than 20 seconds.
select count(*) from fake_rides where departure_time >= '2025-09-01';
--   count  
-- ---------
--  5452720
-- (1 row)

-- Time: 992.404 ms

--  Finalize Aggregate  (cost=138958.92..138958.93 rows=1 width=8)
--    ->  Gather  (cost=138958.71..138958.92 rows=2 width=8)
--          Workers Planned: 2
--          ->  Partial Aggregate  (cost=137958.71..137958.72 rows=1 width=8)
--                ->  Parallel Index Only Scan using ind_departure_time on fake_rides  (cost=0.57..131889.02 rows=2427873 width=0)
--                      Index Cond: (departure_time >= '2025-09-01 00:00:00'::timestamp without time zone)

/***************************************************************************************
Correlated subqueries
***************************************************************************************/

select fhv_name, vehicle_license_number, wheelchair_accessible_desc
from for_hire_vehicles
    join wheelchair_access using (wheelchair_accessible_key)
where base_key in (
    select base_key
    from bases 
    where bases.base_type = 'BLACK-CAR' 
        and for_hire_vehicles.fhv_name = bases.base_name
)
order by fhv_name;
-- Time: 5468.146 ms (00:05.468)

--                                                               QUERY PLAN                                                              
-- --------------------------------------------------------------------------------------------------------------------------------------
--  Sort  (cost=1390204.46..1390335.53 rows=52430 width=63)
--    Sort Key: for_hire_vehicles.fhv_name
--    ->  Nested Loop  (cost=0.15..1384120.44 rows=52430 width=63)
--          ->  Seq Scan on for_hire_vehicles  (cost=0.00..1375160.23 rows=52430 width=29)
--                Filter: (SubPlan 1)
--                SubPlan 1
--                  ->  Seq Scan on bases  (cost=0.00..26.18 rows=1 width=4)
--                        Filter: (((base_type)::text = 'BLACK-CAR'::text) AND ((for_hire_vehicles.fhv_name)::text = (base_name)::text))
--          ->  Index Scan using wheelchair_access_pkey on wheelchair_access  (cost=0.15..0.17 rows=1 width=42)
--                Index Cond: (wheelchair_accessible_key = for_hire_vehicles.wheelchair_accessible_key)
--  JIT:
--    Functions: 15
--    Options: Inlining true, Optimization true, Expressions true, Deforming true
-- (13 rows)

select fhv_name, vehicle_license_number, wheelchair_accessible_desc
from for_hire_vehicles
    join wheelchair_access using (wheelchair_accessible_key)
where fhv_name in (
    select DISTINCT BASE_NAME 
    from bases 
    where base_type = 'BLACK-CAR'
)
order by fhv_name;
-- Time: 31.689 ms

--                                                    QUERY PLAN                                                   
-- ----------------------------------------------------------------------------------------------------------------
--  Sort  (cost=2567.49..2570.51 rows=1209 width=63)
--    Sort Key: for_hire_vehicles.fhv_name
--    ->  Hash Join  (cost=77.53..2505.59 rows=1209 width=63)
--          Hash Cond: (for_hire_vehicles.wheelchair_accessible_key = wheelchair_access.wheelchair_accessible_key)
--          ->  Hash Join  (cost=42.77..2467.65 rows=1209 width=29)
--                Hash Cond: ((for_hire_vehicles.fhv_name)::text = (bases.base_name)::text)
--                ->  Seq Scan on for_hire_vehicles  (cost=0.00..2149.60 rows=104860 width=29)
--                ->  Hash  (cost=36.12..36.12 rows=532 width=24)
--                      ->  HashAggregate  (cost=25.48..30.80 rows=532 width=24)
--                            Group Key: bases.base_name
--                            ->  Seq Scan on bases  (cost=0.00..24.15 rows=534 width=24)
--                                  Filter: ((base_type)::text = 'BLACK-CAR'::text)
--          ->  Hash  (cost=21.00..21.00 rows=1100 width=42)
--                ->  Seq Scan on wheelchair_access  (cost=0.00..21.00 rows=1100 width=42)
-- (14 rows)

-- Time: 7.350 ms

/***************************************************************************************
CTEs and logical vs materialized views
***************************************************************************************/

with 
base_monthly as (
    select base_name, 
        date_trunc('month', departure_time)::date departure_month, 
        sum(fare) as revenue,
        count(*) as rides
    from fake_rides
        join for_hire_vehicles using (vehicle_license_number)
        join bases using (base_key)
    where departure_time between '2025-07-01' and '2025-10-01'
    group by base_name, date_trunc('month', departure_time)::date
),
total_averages as (
    select avg(revenue)::int as total_avg_revenue, avg(rides)::int as total_avg_rides
    from base_monthly
),
above_average as (
    select base_name,
        total_avg_revenue,
        sum(case when departure_month='2025-07-01' then revenue end) revenue_0725,
        sum(case when departure_month='2025-08-01' then revenue end) revenue_0825,
        sum(case when departure_month='2025-09-01' then revenue end) revenue_0925,
        total_avg_rides,
        sum(case when departure_month='2025-07-01' then rides end) rides_0725,
        sum(case when departure_month='2025-08-01' then rides end) rides_0825,
        sum(case when departure_month='2025-09-01' then rides end) rides_0925
    from base_monthly, total_averages -- join is no biggy because it's one record
    group by base_name, total_avg_revenue, total_avg_rides
    -- always above twice the overall average
    having count(case when revenue > (2 * total_avg_revenue) then 1 end) = 3
)
select b.base_name, coalesce(b.website, b.base_telephone_number) base_contact, 
    a.revenue_0925, a.revenue_0825, a.revenue_0725,
    a.total_avg_revenue
from above_average a join bases b on (a.base_name=b.base_name)
order by revenue_0925 desc, revenue_0825 desc, revenue_0725 desc
;

--              base_name             |        base_contact         | revenue_0925 | revenue_0825 | revenue_0725 | total_avg_revenue 
-- -----------------------------------+-----------------------------+--------------+--------------+--------------+-------------------
--  UBER USA, LLC                     | (646)780-0129               |    122664458 |    126691290 |    126729748 |            201520
--  SPACELINKS,LLC                    | WWW.SPACELYNKS.COM          |      1618792 |      1664320 |      1665795 |            201520
--  TRI-CITY,LLC                      | (415)475-8459               |      1571647 |      1618419 |      1624681 |            201520
--  GRAND TRANSPORTATION SERVICES INC | WWW.GRANDLIMONY.COM         |      1568014 |      1617847 |      1622358 |            201520
--  ZYNC INC                          | (718)482-1818               |      1221326 |      1270840 |      1259973 |            201520
--  NY CAR & LIMO SERVICES INC.       | WWW.NYINSURANCEB.COM        |      1125028 |      1163412 |      1171077 |            201520
--  EXIT LUXURY INC.                  | (718)472-9800               |       821095 |       844659 |       844595 |            201520
--  ADRIS TRANSPORTATION INC          | WWW.ADRISTRANSPORTATION.COM |       633601 |       658499 |       653686 |            201520
--  ZOOM TRANSIT INC                  | (718)583-9100               |       545502 |       566953 |       560482 |            201520
--  CHINA TRANSIT LLC.                | (917)553-9896               |       543277 |       565172 |       559537 |            201520
--  ALLSTATE PRIVATE CAR & LIMO,INC   | (212)741-1562               |       519348 |       533706 |       529781 |            201520
-- (11 rows)
-- Time: 11114.340 ms (00:11.114)

-- Sort  (cost=3115058.12..3115058.13 rows=1 width=156)
--    Sort Key: a.revenue_0925 DESC, a.revenue_0825 DESC, a.revenue_0725 DESC
--    CTE base_monthly
--      ->  Finalize GroupAggregate  (cost=998117.53..2281904.10 rows=9801468 width=44)
--            Group Key: bases.base_name, ((date_trunc('month'::text, fake_rides.departure_time))::date)
--            ->  Gather Merge  (cost=998117.53..2053203.18 rows=8167890 width=44)
--                  Workers Planned: 2
--                  ->  Partial GroupAggregate  (cost=997117.50..1109425.99 rows=4083945 width=44)
--                        Group Key: bases.base_name, ((date_trunc('month'::text, fake_rides.departure_time))::date)
--                        ->  Sort  (cost=997117.50..1007327.36 rows=4083945 width=32)
--                              Sort Key: bases.base_name, ((date_trunc('month'::text, fake_rides.departure_time))::date)
--                              ->  Hash Join  (cost=2521.69..353243.06 rows=4083945 width=32)
--                                    Hash Cond: (for_hire_vehicles.base_key = bases.base_key)
--                                    ->  Parallel Hash Join  (cost=2489.42..322014.76 rows=4083945 width=16)
--                                          Hash Cond: ((fake_rides.vehicle_license_number)::text = (for_hire_vehicles.vehicle_license_number)::text)
--                                          ->  Parallel Index Scan using ind_departure_time on fake_rides  (cost=0.57..308805.12 rows=4083945 width=19)
--                                                Index Cond: ((departure_time >= '2025-07-01 00:00:00'::timestamp without time zone) AND (departure_time <= '2025-10-01 00:00:00'::timestamp without time zone))
--                                          ->  Parallel Hash  (cost=1717.82..1717.82 rows=61682 width=11)
--                                                ->  Parallel Seq Scan on for_hire_vehicles  (cost=0.00..1717.82 rows=61682 width=11)
--                                    ->  Hash  (cost=22.12..22.12 rows=812 width=28)
--                                          ->  Seq Scan on bases  (cost=0.00..22.12 rows=812 width=28)
--    ->  Hash Join  (cost=833128.83..833154.01 rows=1 width=156)
--          Hash Cond: ((b.base_name)::text = (a.base_name)::text)
--          ->  Seq Scan on bases b  (cost=0.00..22.12 rows=812 width=58)
--          ->  Hash  (cost=833128.82..833128.82 rows=1 width=318)
--                ->  Subquery Scan on a  (cost=833124.81..833128.82 rows=1 width=318)
--                      ->  HashAggregate  (cost=833124.81..833128.81 rows=1 width=418)
--                            Group Key: base_monthly.base_name, ((avg(base_monthly_1.revenue))::integer), ((avg(base_monthly_1.rides))::integer)
--                            Filter: (count(CASE WHEN (base_monthly.revenue > (2 * ((avg(base_monthly_1.revenue))::integer))) THEN 1 ELSE NULL::integer END) = 3)
--                            ->  Nested Loop  (cost=245036.71..539080.77 rows=9801468 width=238)
--                                  ->  Aggregate  (cost=245036.71..245036.72 rows=1 width=8)
--                                        ->  CTE Scan on base_monthly base_monthly_1  (cost=0.00..196029.36 rows=9801468 width=16)
--                                  ->  CTE Scan on base_monthly  (cost=0.00..196029.36 rows=9801468 width=230)


