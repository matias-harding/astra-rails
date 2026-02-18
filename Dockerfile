# syntax=docker/dockerfile:1

FROM ruby:3.3-slim

# System dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems (Gemfile copied first for layer caching)
COPY Gemfile Gemfile.lock ./
RUN gem install rails && bundle install

# Copy application code
COPY . .

# Add entrypoint script
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]