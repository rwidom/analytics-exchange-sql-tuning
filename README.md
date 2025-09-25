# Old school SQL performance tuning, for your old school city database

Training presented at NYC Analytics Exchange, 2025.

## Set up the sample database with Docker

The sample SQL and exercises in this database are run against a version of [New York City Open Data For Hire Vehicles (FHV) - Active](https://data.cityofnewyork.us/Transportation/For-Hire-Vehicles-FHV-Active/8wbx-tsch/about_data).

To run the samples, you'll need to download this github repository, and install [Docker Desktop](https://www.docker.com/products/docker-desktop/). Then, at the command line from the same directory where you have saved this README file, type the following commands.

- To download the docker image with the database software: `docker pull postgres:16-alpine3.22`

- To start up the database and load sample data: `docker-compose up`

- To access the database with a simple command line sql runner (`psql`): `docker run -it --rm --network analytics-exchange-sql-tuning_default postgres psql -h analytics-exchange-sql-tuning-database-1 -U training`

## And on to the training!

### Less is more.

- Order of execution
- Filter as early in the process as possible

### Once and done.

- CTEs
- avoid correlated subqueries
- avoid filtering on calculations

### Keep it simple.

- Explain plans
- Table statistics
- Indices / partitions
- Hints
