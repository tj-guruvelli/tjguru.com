@echo off
echo Starting Simple Jekyll in Docker...
docker run -it --rm ^
  -e JEKYLL_ENV=production ^
  --volume="%cd%:/srv/jekyll" ^
  -p 4000:4000 jekyll/minimal:latest ^
  jekyll serve --host 0.0.0.0
