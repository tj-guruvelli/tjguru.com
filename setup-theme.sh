#!/bin/bash

# Remove existing theme assets
rm -rf assets
rm -rf _data
rm -rf _includes
rm -rf _layouts
rm -rf _sass

# Copy theme files
THEME_PATH=$(bundle info --path jekyll-theme-chirpy)
cp -r $THEME_PATH/assets ./assets
cp -r $THEME_PATH/_data ./_data
cp -r $THEME_PATH/_includes ./_includes
cp -r $THEME_PATH/_layouts ./_layouts
cp -r $THEME_PATH/_sass ./_sass

# Set permissions
chmod -R 755 assets _data _includes _layouts _sass
