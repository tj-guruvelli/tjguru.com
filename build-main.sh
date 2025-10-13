#!/bin/bash

echo "Building the main Jekyll site..."

# Stop any running servers
pkill -f "python3 -m http.server 4000" || true

# Run Jekyll with a different approach
docker run -it --rm \
  -e JEKYLL_ENV=production \
  -e DISABLE_SPRING=true \
  --volume="$(pwd):/srv/jekyll" \
  -p 4000:4000 jekyll/jekyll:latest \
  bash -c "apk add --no-cache graphviz && bundle install && bundle exec jekyll build --trace"

echo "Site built in _site directory"
echo "To view it locally, run: python3 -m http.server 4000"
