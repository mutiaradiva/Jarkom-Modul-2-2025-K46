#vingilot
apt update
apt install nginx php-fpm -y
mkdir -p /var/www/app.K46.com
cd /var/www/app.K46.com
echo "<?php phpinfo(); ?>" > index.php
echo "<h1>About Vingilot</h1>" > about.php
nano /etc/nginx/sites-available/app.K46.com
#edit jadi
server {
    listen 80;
    server_name app.K46.com;

    root /var/www/app.K46.com;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location /about {
        rewrite ^/about$ /about.php last;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php7.X-fpm.sock;  # ganti sesuai versi php-fpm
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    access_log /var/log/nginx/app_access.log;
    error_log /var/log/nginx/app_error.log;
}

ln -s /etc/nginx/sites-available/app.K46.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
service nginx restart

#node lain bebas
lynx 
