# Old school SQL performance tuning, for your old school city database

Training presented at NYC Analytics Exchange, 2025.

## Set up the sample database with Docker

The sample SQL and exercises in this database are run against a version of [New York City Open Data For Hire Vehicles (FHV) - Active](https://data.cityofnewyork.us/Transportation/For-Hire-Vehicles-FHV-Active/8wbx-tsch/about_data) with some additional made up random data about fake rides in each of the vehicles.

To run the samples, you'll need to download this github repository, and install [Docker Desktop](https://www.docker.com/products/docker-desktop/). Once you have started up docker desktop, at the command line from the same directory where you have saved this README file, type the following commands.

- To start up the database and load sample data: `docker-compose up`

- To access the database with a simple command line sql runner (`psql`): `docker run -it --rm --network analytics-exchange-sql-tuning_default postgres psql -h analytics-exchange-sql-tuning-database-1 -U training`

## And on to the training!

Link to full presentation coming soon, and there is lots of content in the practice sql files:

- [Less is More](samples/less_is_more.sql)
- [Once and Done](samples/once_and_done.sql)
- [Simple is Best](samples/simple_is_best.sql)
