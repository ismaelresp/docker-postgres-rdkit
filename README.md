# PostgreSQL Docker Image with RDKit Cartridge

This is a PostgreSQL Docker image with the RDKit cartridge installed.

This image inherits from the [official postgres image](https://hub.docker.com/_/postgres/), and therefore has all the same environment variables for configuration, and can be extended by adding entrypoint scripts to the `/docker-entrypoint-initdb.d` directory to be run on first launch.

## Running

Start Postgres server running in the background:

    docker run --platform linux/amd64 --name mypostgres -p 5432:5432 -e POSTGRES_PASSWORD=mypassword -d postgres16-rdkit2024_03_3

Or run with an application via Docker Compose:

```yaml
services:

  db:
    image: postgres16-rdkit2024_03_3
    restart: always
    environment:
      POSTGRES_PASSWORD: mypassword
    volumes:
      - /path/to/pgdata:/var/lib/postgresql/data

```

This image exposes port 5432 (the postgres port), so standard container linking will make it automatically available to the linked containers.

## Environment Variables

- `POSTGRES_PASSWORD`: Superuser password for PostgreSQL.
- `POSTGRES_USER`: Superuser username (default `postgres`).
- `POSTGRES_DB`: Default database that is created when the image is first started.
- `PGDATA`: Location for the database files (default `/var/lib/postgresql/data`).

See the [official postgres image](https://hub.docker.com/_/postgres/) for more details.

## Building
To build, run:
  docker run --network gpcrdb -d --platform linux/amd64 --name postgres16-rdkit2024_03_3 \
  -v postgres_data:/var/lib/postgresql/data \
  -e POSTGRES_USER=protwis \
  -e POSTGRES_PASSWORD=protwis \
  -p 5432:5432 \
  postgres16-rdkit2024_03_3
