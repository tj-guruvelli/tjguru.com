@echo off
echo Building Jekyll site...
docker run -it --rm ^
  -e JEKYLL_ENV=production ^
  --volume="%cd%:/srv/jekyll" ^
  -p 4000:4000 jekyll/jekyll:4 ^
  bash -c "bundle install && bundle exec jekyll build"

echo.
echo Site built in _site directory. To view it locally, run:
echo npx serve _site
