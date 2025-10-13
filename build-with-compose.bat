@echo off
echo Building Jekyll site using Docker Compose...

docker-compose up

echo.
echo Site built in _site directory
echo To view it locally, run: npx serve _site
