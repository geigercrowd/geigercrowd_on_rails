#!/bin/bash
cd /srv/www/geigercrowd/current
RAILS_ENV=production /usr/local/rvm/bin/geigercrowd_rake utilities:scrape

