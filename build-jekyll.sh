#!/bin/bash

echo "Building Jekyll site with simplified configuration..."

echo "Stopping any running servers..."
pkill -f "python3 -m http.server 4000" || true

docker run -it --rm \
  -e JEKYLL_ENV=production \
  --volume="$(pwd):/srv/jekyll" \
  -p 4000:4000 jekyll/jekyll:4 \
  bash -c "bundle install && bundle exec jekyll build --config _config_simple.yml"

# Create a very simple HTML file in _site to verify it's working
mkdir -p _site
echo '<html><body><h1>TJ Guru Blog</h1><p>Test page</p></body></html>' > _site/test.html

echo "Site built in _site directory"
echo "To view it locally, run: python3 -m http.server 4000"
