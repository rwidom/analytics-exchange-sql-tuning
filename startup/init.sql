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
    base_key int,
    wheelchair_accessible_key int,
    expiration_date date,
    permit_license_number varchar(20),
    dmv_license_plate_number varchar(20),
    vehicle_year int,
    CONSTRAINT fk_base
      FOREIGN KEY(base_key) 
        REFERENCES bases(base_key),
    CONSTRAINT fk_wheelchair_access
      FOREIGN KEY(wheelchair_accessible_key) 
        REFERENCES wheelchair_access(wheelchair_accessible_key)
);
COPY for_hire_vehicles FROM '/var/lib/postgresql/imports/for_hire_vehicles.csv' CSV HEADER;



