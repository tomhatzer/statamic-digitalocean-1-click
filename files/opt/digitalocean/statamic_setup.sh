#!/bin/bash
#
# Statamic activation script
#
# This script will configure Nginx with the domain
# provided by the user and offer the option to set up
# LetsEncrypt as well.

# Setup Statamic on firstlogin
echo "--------------------------------------------------"
echo "This setup requires a domain name.  If you do not have one yet, you may"
echo "cancel this setup, press Ctrl+C.  This script will run again on your next login"
echo "--------------------------------------------------"
echo "Enter the domain name for your new Statamic site."
echo "(ex. example.org or test.example.org) do not include www or http/s"
echo "--------------------------------------------------"

a=0
while [ $a -eq 0 ]
do
 read -p "Domain/Subdomain name: " dom
 if [ -z "$dom" ]
 then
  a=0
  echo "Please provide a valid domain or subdomain name to continue to press Ctrl+C to cancel"
 else
  a=1
fi
done

sed -i "s/DOMAIN/$dom/g"  /etc/nginx/sites-enabled/statamic

systemctl restart nginx

echo "Generating new Statamic App Key"
cd /var/www/statamic/ && php artisan key:generate
sed -i 's/APP_ENV=local/APP_ENV=production/g' /var/www/statamic/.env
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/g' /var/www/statamic/.env

# Set default PHP version
update-alternatives --set php /usr/bin/php8.1

echo -en "\n\n\n"
echo "Next, you have the option of configuring LetsEncrypt to secure your new site.  Before doing this, be sure that you have pointed your doma
in or subdomain to this server's IP address.  You can also run LetsEncrypt certbot later with the command 'certbot --nginx'"
echo -en "\n\n\n"
read -p "Would you like to use LetsEncrypt (certbot) to configure SSL(https) for your new site? (y/n): " yn
    case $yn in
        [Yy]* ) certbot --nginx; echo "Statamic has been enabled at https://$dom"
            ;;
        [Nn]* ) echo "Skipping LetsEncrypt certificate generation"
            ;;
        * ) echo "Please answer y or n."
            ;;
    esac

echo "Installation completed"
cp /etc/skel/.bashrc /root