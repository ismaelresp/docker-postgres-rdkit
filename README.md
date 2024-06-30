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

```bash
  docker run --network gpcrdb -d --platform linux/amd64 --name postgres16-rdkit2024_03_3 \
  -v postgres_data:/var/lib/postgresql/data \
  -e POSTGRES_USER=protwis \
  -e POSTGRES_PASSWORD=protwis \
  -p 5432:5432 \
  postgres16-rdkit2024_03_3
```
## Performance optimization
Source: https://www.rdkit.org/docs/Cartridge.html#configuration

### For building the database
To improve performance while storing RDKIT molecule objects and fingerprints into the database, and while building the indexes, a couple of PostgreSQL configuration settings in postgresql.conf can be changed:

```
synchronous_commit = off      # immediate fsync at commit
full_page_writes = off            # recover from partial page writes
```

**synchronous_commit = off**: increases the change of losing commits to the database if a sudden postgresql server crash happens. Commits will be reported as executed even if there are not stored and flushed into a durable storage (e.g. a hard drive or SSD).

**full_page_writes = off**: speeds normal operation, but might lead to either unrecoverable data corruption, or silent data corruption, after a system failure.

### For queries (structural searches)
And to improve search performance, we can allow postgresql to use more memory than the extremely conservative default settings:

```
shared_buffers = 2048MB           # min 128kB, PostgreSQL's "dedicated" RAM
                  # (change requires restart)
work_mem = 128MB              # min 64kB, maximum amount of RAM memory to be used by a query
                              # operation before it starts to use disk memory instead.
```
These settings increase the RAM requirements for PostgreSQL to run.
