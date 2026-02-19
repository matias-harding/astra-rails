# Astra Rails

A personal calendar application built with Rails 8. Each user manages their own calendar of events, with plans to grow toward shared calendars.

## Tech Stack

- **Ruby** 3.3.10 / **Rails** 8.1.2
- **PostgreSQL** 16
- **Hotwire** — Turbo + Stimulus via importmap (no npm/webpack)
- **FullCalendar** 6.1.15 via CDN script tag
- **Propshaft** asset pipeline
- **Docker** — development and production (no local Ruby required)

## Features

- Multi-user authentication (Rails 8 built-in)
- Personal calendar per user — events are fully scoped to the logged-in user
- FullCalendar UI with month, week, and day views
- Click a date to create a new event (modal form, pre-filled with the selected date)
- Click an existing event to view, edit, or delete it
- Drag and drop events to reschedule
- Resize events to adjust end time
- All-day event support

## Running the App

Requires [Docker Desktop](https://www.docker.com/products/docker-desktop/).

```bash
# Start the app (first run builds the image and sets up the database)
docker compose up

# Visit http://localhost:3000
```

## Creating Your First User

There is no public sign-up page. Create users via the Rails console:

```bash
docker compose run --rm web ./bin/rails console
```

```ruby
User.create!(
  email_address: "you@example.com",
  password: "yourpassword",
  password_confirmation: "yourpassword"
)
```

## Common Commands

```bash
# Start the app
docker compose up

# Stop the app
docker compose down

# Rails console
docker compose run --rm web ./bin/rails console

# Run a migration
docker compose run --rm web ./bin/rails db:migrate

# View logs
docker compose logs -f web

# Adding a new gem (Docker-only workflow):
# 1. Add it to Gemfile
# 2. Update Gemfile.lock via throwaway container:
docker run --rm -v "$(pwd)":/rails -w /rails ruby:3.3.10-slim \
  bash -c "apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev libyaml-dev && bundle install"
# 3. Rebuild the image:
docker compose build web
```

## Event Fields

| Field | Type | Notes |
|-------|------|-------|
| `title` | string | Required |
| `start_datetime` | datetime | Required |
| `end_datetime` | datetime | Optional |
| `description` | text | Optional |
| `all_day` | boolean | Defaults to false |

## Project Structure Notes

- Authentication: `app/controllers/concerns/authentication.rb` — defines `current_user` (`Current.session&.user`) and `authenticated?`
- Calendar UI: `app/javascript/controllers/calendar_controller.js` — Stimulus controller wrapping FullCalendar; mounted on `<body>` so modal close actions work across Turbo Frame boundaries
- FullCalendar is loaded via a `<script>` tag (not importmap) to ensure `window.FullCalendar` is available as a global before Stimulus controllers initialize
- Event JSON feed for FullCalendar: `GET /events/feed.json?start=...&end=...`
