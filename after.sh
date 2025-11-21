#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
#
# If you have user-specific configurations you would like
# to apply, you may also create user-customizations.sh,
# which will be run after this script.


# If you're not quite ready for the latest Node.js version,
# uncomment these lines to roll back to a previous version

# Remove current Node.js version:
#sudo apt-get -y purge nodejs
#sudo rm -rf /usr/lib/node_modules/npm/lib
#sudo rm -rf //etc/apt/sources.list.d/nodesource.list

# Install Node.js Version desired (i.e. v13)
# More info: https://github.com/nodesource/distributions/blob/master/README.md#debinstall
#curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
#sudo apt-get install -y nodejs

# Настройка кэширования статических файлов для homestead.test
sudo tee /etc/nginx/sites-available/application.local <<EOF > /dev/null
server {
    listen 80;
    listen 443 ssl http2;
    server_name .application.local;
    root "/home/vagrant/code/public";

    index index.php index.html index.htm;

    charset utf-8;

    # Блок кеширования
    location ~* \.(?:jpg|jpeg|gif|png|svg|ico|css|js|swf|txt)$ {
             expires 1d;
             add_header Cache-Control "public, max-age=86400";
             access_log off;
             log_not_found off;
    }


    location / {
        try_files \$uri \$uri/ /index.php? \$query_string;

    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/application.local-error.log error;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;


        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/ssl/certs/application.local.crt;
    ssl_certificate_key /etc/ssl/certs/application.local.key;
}
EOF

sudo ln -sf /etc/nginx/sites-available/application.local /etc/nginx/sites-enabled/application.local

sudo nginx -t

sudo service nginx restart