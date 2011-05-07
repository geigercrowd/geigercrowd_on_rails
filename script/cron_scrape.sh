#!/bin/bash
. /usr/local/rvm/scripts/rvm
rvm 1.9.2@geigercrowd
cd /srv/www/geigercrowd/current
RAILS_ENV=production rake utilities:scrape

