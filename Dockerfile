# syntax=docker/dockerfile:1

# Ruby version matches the project's Gemfile.lock (ruby 2.7.8)
FROM ruby:2.7

# Install system dependencies
# - build-essential: compiling native gem extensions
# - libpq-dev: pg gem (PostgreSQL client)
# - libmagickwand-dev: RMagick gem (ImageMagick bindings)
# - imagemagick: ImageMagick binaries (used by RMagick and Paperclip)
# - nodejs: JavaScript runtime required by uglifier (asset pipeline)
# - postgresql-client: allows rake db:* commands and pg_dump inside the container
# - git: some gems may be sourced from git
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      libmagickwand-dev \
      imagemagick \
      nodejs \
      postgresql-client \
      git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install the exact bundler version used to generate Gemfile.lock
RUN gem install bundler -v 1.17.3

# Copy dependency manifests first for better layer caching.
# Bundle install only re-runs when Gemfile or Gemfile.lock changes.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs "$(nproc)" --retry 3

# Copy the rest of the application source
COPY . .

# Ensure gitbranch file exists (used by config/initializers/git.rb).
# When building outside a git repo (e.g. CI) the file is created as a fallback.
RUN git rev-parse --abbrev-ref HEAD > gitbranch 2>/dev/null || echo "docker" > gitbranch

# Precompile assets at build time for production.
# Comment this out if you prefer to precompile at runtime or run in development mode.
# RUN RAILS_ENV=production SECRET_KEY_BASE=placeholder bundle exec rake assets:precompile

# Expose the Rails default port
EXPOSE 3000

# Remove any stale server PID that might survive from a previous run
ENTRYPOINT ["/bin/sh", "-c", "rm -f tmp/pids/server.pid && exec \"$@\"", "--"]

# Start the Rails server bound to all interfaces
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
