#!/bin/bash

# DigitalOcean Marketplace Image Validation Tool
# © 2021 DigitalOcean LLC.
# This code is licensed under Apache 2.0 license (see LICENSE.md for details)

rm -rvf /etc/nginx/sites-enabled/default

# Install LaraSail: https://github.com/thedevdojo/larasail
curl -sL https://github.com/thedevdojo/larasail/archive/master.tar.gz | tar xz && source larasail-master/install

# Run the LaraSail setup script
sh /etc/.larasail/larasail setup php81

# Install statamic cli
COMPOSER_ALLOW_SUPERUSER=1; composer global require statamic/cli

# Create a new Laravel project
cd /var/www && export COMPOSER_ALLOW_SUPERUSER=1; $HOME/.config/composer/vendor/bin/statamic new statamic

ln -s /etc/nginx/sites-available/statamic \
      /etc/nginx/sites-enabled/statamic

chown -R larasail: /var/www/statamic
chown -R larasail:www-data /var/www/statamic/storage
chmod -R 775 /var/www/statamic/storage
chown -R larasail:www-data /var/www/statamic/bootstrap/cache
chmod -R 775 /var/www/statamic/bootstrap/cache

# Lock larasail user
passwd -ld larasail