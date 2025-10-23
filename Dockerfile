FROM ruby:3.2-alpine

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    graphviz \
    graphviz-dev \
    ttf-dejavu \
    nodejs \
    npm \
    yaml-dev \
    zlib-dev \
    bash

# Set working directory
WORKDIR /srv/jekyll

# Copy Gemfile and install dependencies
COPY Gemfile* ./
RUN bundle install

# Copy the rest of the site
COPY . .

# Expose port 4000
EXPOSE 4000

# Set default command
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
