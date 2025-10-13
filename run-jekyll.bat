@echo off
echo Starting Jekyll in Docker...
docker run -it --rm ^
  -e JEKYLL_ENV=production ^
  -e DISABLE_SPRING=true ^
  --volume="%cd%:/srv/jekyll" ^
  -p 4000:4000 jekyll/jekyll:4 ^
  bash -c "bundle install && bundle exec jekyll serve --safe --host 0.0.0.0"
