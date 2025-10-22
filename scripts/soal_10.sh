# Di Vingilot
apt-get update
apt-get install nginx php8.4-fpm -y

service php8.4-fpm status

mkdir -p /var/www/app.K46.com

nano /var/www/app.K46.com/index.php

<!DOCTYPE html>
<html>
<head>
    <title>Vingilot - Home</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        h1 { color: #2c3e50; }
        .content { margin-top: 20px; }
    </style>
</head>
<body>
    <h1>Welcome to Vingilot</h1>
    <div class="content">
        <p>This is the dynamic web application running on PHP-FPM.</p>
        <p>Server time: <?php echo date('Y-m-d H:i:s'); ?></p>
        <p><a href="/about">About Us</a></p>
    </div>
</body>
</html>

nano /var/www/app.K46.com/about.php

<!DOCTYPE html>
<html>
<head>
    <title>Vingilot - About</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        h1 { color: #2c3e50; }
        .content { margin-top: 20px; }
    </style>
</head>
<body>
    <h1>About Vingilot</h1>
    <div class="content">
        <p>Vingilot is the ship of Earendil, sailing through the dynamic seas of PHP.</p>
        <p>PHP Version: <?php echo phpversion(); ?></p>
        <p><a href="/">Back to Home</a></p>
    </div>
</body>
</html>

nano /etc/nginx/sites-available/app.K46.com

server {
    listen 80;
    server_name app.K46.com;

    root /var/www/app.K46.com;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location = /about {
        rewrite ^ /about.php last;
    }

    location ~ /\.ht {
        deny all;
    }
}

ln -s /etc/nginx/sites-available/app.K46.com /etc/nginx/sites-enabled/

nginx -t

service php8.4-fpm restart
service nginx restart

lynx http://app.K46.com/
lynx http://app.K46.com/about 