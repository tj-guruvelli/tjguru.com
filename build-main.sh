#!/bin/bash

echo "Building the main Jekyll site..."

docker run -it --rm \
  -e JEKYLL_ENV=production \
  -e DISABLE_SPRING=true \
  --platform linux/amd64 \
  --volume="$(pwd):/srv/jekyll" \
  -p 4000:4000 jekyll/jekyll:4 \
  bash -c "apk add --no-cache graphviz graphviz-dev ttf-dejavu && bundle install && bundle exec jekyll serve --safe --no-watch"

echo "Site built in _site directory"
echo "To view it locally, run: python3 -m http.server 4000"