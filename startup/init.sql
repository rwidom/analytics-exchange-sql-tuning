GRANT ALL PRIVILEGES ON DATABASE training TO training;

CREATE TABLE wheelchair_access
(
    wheelchair_accessible_key int primary key,
    wheelchair_accessible_desc varchar(10),
    total_records int
);
COPY wheelchair_access FROM '/var/lib/postgresql/imports/wheelchair_access.csv' CSV HEADER;

CREATE TABLE bases
(
    base_key int primary key,
    base_number varchar(10),
    base_name varchar(100),
    base_type varchar(10),
    base_telephone_number varchar(20),
    website varchar(100),
    base_address varchar(100)
);
COPY bases FROM '/var/lib/postgresql/imports/bases.csv' CSV HEADER;

CREATE TABLE for_hire_vehicles
(
    vehicle_license_number varchar(20) primary key,
    base_key int references bases(base_key),
    wheelchair_accessible_key int references wheelchair_access(wheelchair_accessible_key),
    fhv_name varchar(100),
    expiration_date date,
    permit_license_number varchar(20),
    dmv_license_plate_number varchar(20),
    vehicle_year int
);
COPY for_hire_vehicles FROM '/var/lib/postgresql/imports/for_hire_vehicles.csv' CSV HEADER;

/* using unlogged, because we don't actually care about the data in this table and there
are big space constraints when using docker */
create UNLOGGED table FAKE_RIDES as ( 
SELECT 
    cars.vehicle_license_number,
    (s1.ride_date + (random() * interval '1 day'))::timestamp as departure_time,
    ceil(random() * 100.0)::int AS fare,
    ceil(random() * 20.0)::int AS distance
FROM generate_series('2020-01-01'::date, '2025-10-22'::date, interval '1 day') AS s1(ride_date) 
CROSS JOIN for_hire_vehicles cars 
);

/* for actual execution times */
CREATE OR REPLACE FUNCTION "get_sql_runtime"(
    PAR_sql TEXT,
    OUT sql_runtime REAL
)
AS $$
DECLARE
    run_time_start TIMESTAMP WITH TIME ZONE;
    run_time_end TIMESTAMP WITH TIME ZONE;
BEGIN
    SELECT clock_timestamp() INTO run_time_start;
    EXECUTE PAR_sql;
    SELECT clock_timestamp() INTO run_time_end;
    SELECT EXTRACT(EPOCH FROM (run_time_end - run_time_start)) INTO sql_runtime;
END; $$
LANGUAGE plpgsql
VOLATILE;
