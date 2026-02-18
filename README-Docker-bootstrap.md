# Astra Rails — Bootstrap Guide

## Prerequisites
- Docker Desktop installed and running
- Nothing running on ports `3000`, `5432`, or `6379`

---

## First-Time Setup (No app yet)

### 1. Build the initial image
```bash
docker compose build
```

### 2. Generate the Rails app
```bash
docker compose run --no-deps --rm web rails new . --database=postgresql --force
```

> `--no-deps` skips starting db/redis for this step.  
> `--force` overwrites placeholder files like this README.

### 3. Install gems
The `rails new` command attempts `bundle install` internally but may fail due to the entrypoint running before gems are ready. Run it manually, bypassing the entrypoint:

```bash
docker compose run --no-deps --rm --entrypoint bash web -c "bundle install"
```

### 4. Update `config/database.yml`
Rails generates a `database.yml` that may conflict with the `DATABASE_URL` env var. Remove the `url` line from the `default` block so Rails picks up `DATABASE_URL` automatically from the environment. Your `default` block should look like this:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  max_connections: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

Leave `development`, `test`, and `production` sections as-is.

### 5. Rebuild the image (now with your app code and Gemfile)
```bash
docker compose build
```

### 6. Start everything
```bash
docker compose up
```

The entrypoint will automatically run `db:prepare` on first boot, creating and migrating the database.

Visit: http://localhost:3000

---

## Known Issues During Bootstrap

**`yaml.h not found` / psych build error**
Already handled in the Dockerfile via `libyaml-dev`. If you see this error, make sure you ran `docker compose build` before attempting `bundle install`.

**`Could not find gem X in locally installed gems`**
This happens when the entrypoint fires before gems are installed. Always use the `--entrypoint bash` bypass for one-off commands during bootstrap (step 3 above).

**`database "astra" does not exist` in db logs**
This is a harmless healthcheck artifact and does not affect the app. Rails connects correctly via `DATABASE_URL`.

---

## Daily Use

```bash
# Start
docker compose up

# Start in background
docker compose up -d

# Stop
docker compose down

# Rails console
docker compose exec web rails console

# Run migrations manually (if you commented out db:prepare in entrypoint.sh)
docker compose exec web rails db:migrate

# Install a new gem (after adding to Gemfile)
docker compose exec web bundle install

# View logs
docker compose logs -f web
```

---

## Environment Variables

| Variable | Value | Notes |
|---|---|---|
| `DATABASE_URL` | `postgres://astra:astra_password@db:5432/astra_rails_development` | Set in docker-compose.yml |
| `REDIS_URL` | `redis://redis:6379/0` | Set in docker-compose.yml |
| `RAILS_ENV` | `development` | Set in docker-compose.yml |

For secrets and additional env vars, create a `.env` file in the project root (already excluded via `.dockerignore`).