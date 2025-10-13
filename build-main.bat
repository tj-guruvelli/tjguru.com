@echo off
echo Building the main Jekyll site...

docker run -it --rm ^
  -e JEKYLL_ENV=production ^
  -e DISABLE_SPRING=true ^
  --volume="%cd%:/srv/jekyll" ^
  -p 4000:4000 jekyll/jekyll:latest ^
  bash -c "bundle install && bundle exec jekyll build --trace"

echo.
echo Site built in _site directory
echo To view it locally, run: npx serve _site
