#lindon
apt update
apt install nginx -y

mkdir -p /var/www/html/annals
echo "<h1>Welcome to Static Web at Lindon</h1>" > /var/www/html/info.txt
echo "This is a record inside annals folder" > /var/www/html/annals/info.txt

#lindon & node lain bebas
nano /etc/resolv.conf
#ganti jadi
nameserver 192.234.3.3
nameserver 192.234.3.4
nameserver 192.168.122.1

nano /etc/nginx/sites-available/static.K46.com
#edit jadi
server {
    listen 80;
    server_name static.K46.com;

    root /var/www/html;
    index index.html;

    access_log /var/log/nginx/static_access.log;
    error_log /var/log/nginx/static_error.log;

    location / {
        try_files $uri $uri/ =404;
    }
    location /annals/ {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
}
ln -s /etc/nginx/sites-available/static.K46.com /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t
service nginx restart

#node lain bebas
apt update
apt install lynx
lynx static.K46.com/annals