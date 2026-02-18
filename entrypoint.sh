#!/bin/bash
set -e

# Remove stale server.pid if it exists
# Prevents Rails from refusing to start after a crash or force-stop
rm -f /app/tmp/pids/server.pid

# Prepare the database only if the app has been generated (Gemfile exists)
# Safe to comment out if you prefer to run migrations manually:
# docker compose exec web rails db:migrate
if [ -f Gemfile ] && bundle check > /dev/null 2>&1; then
  bundle exec rails db:prepare
fi

# Run the main container command (e.g. rails server)
exec "$@"