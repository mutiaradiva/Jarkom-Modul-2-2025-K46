#!/bin/bash
set -e

# Soal 11 - Sirion (reverse proxy, canonical redirect, basic auth /admin, forward original IP)
# Jalankan di node Sirion

# update & install
apt update
apt install -y nginx apache2-utils

# set website content for Sirion (front page)
mkdir -p /var/www/www.K46.com
cat > /var/www/www.K46.com/index.html <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>War of Wrath: Lindon bertahan</title>
</head>
<body>
  <h1>War of Wrath: Lindon bertahan</h1>
  <p>Selamat datang — tautan:</p>
  <ul>
    <li><a href="/static/">Static (Lindon)</a></li>
    <li><a href="/app/">App (Vingilot)</a></li>
  </ul>
</body>
</html>
HTML

# buat halaman admin (dilindungi)
mkdir -p /var/www/www.K46.com/admin
cat > /var/www/www.K46.com/admin/index.html <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Admin</title></head>
<body>
<h1>Admin area - Sirion</h1>
<p>Area ini terlindungi Basic Auth.</p>
</body>
</html>
HTML

# buat credential basic auth
# Username: admin | Password: K46admin  (ubah bila perlu)
htpasswd_file="/etc/nginx/.htpasswd"
if [ -f "$htpasswd_file" ]; then
  htpasswd -b "$htpasswd_file" admin K46admin
else
  htpasswd -b -c "$htpasswd_file" admin K46admin
fi
chmod 640 "$htpasswd_file"
chown root:www-data "$htpasswd_file"

# Buat konfigurasi nginx untuk canonical host, redirect default, dan proxying path-based
# Server yang menerima canonical (www.K46.com) akan mem-proxy /static ke Lindon (192.234.3.5)
# dan /app ke Vingilot (192.234.3.6). /admin dilindungi Basic Auth (di Sirion, bukan di backend).

# 1) Default server -> redirect ke canonical
cat > /etc/nginx/sites-available/00_redirect_to_www <<'NGINX'
server {
    listen 80 default_server;
    server_name _;
    return 301 http://www.K46.com$request_uri;
}
NGINX

# 2) sirion.K46.com -> redirect ke canonical (301)
cat > /etc/nginx/sites-available/01_sirion_redirect <<'NGINX'
server {
    listen 80;
    server_name sirion.K46.com;
    return 301 http://www.K46.com$request_uri;
}
NGINX

# 3) canonical server: www.K46.com (melayani frontpage + proxy /static & /app)
cat > /etc/nginx/sites-available/www.K46.com <<'NGINX'
server {
    listen 80;
    server_name www.K46.com;

    access_log /var/log/nginx/www.K46.access.log;
    error_log /var/log/nginx/www.K46.error.log;

    # Front page lokal (index)
    root /var/www/www.K46.com;
    index index.html;

    # Halaman utama
    location = / {
        try_files /index.html =404;
    }

    # Basic Auth area (lokal di Sirion)
    location ^~ /admin {
        auth_basic "Admin Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
        try_files /admin/index.html =404;
    }

    # Static -> Lindon (static.K46.com) 
    # Pastikan backend menerima Host header static.K46.com agar vhost di Lindon ter-trigger
    location /static/ {
        proxy_pass         http://192.234.3.5:80/;
        proxy_set_header   Host static.K46.com;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header   Connection "";
    }

    # App -> Vingilot (app.K46.com)
    location /app/ {
        proxy_pass         http://192.234.3.6:80/;
        proxy_set_header   Host app.K46.com;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header   Connection "";
    }

    # Jika ada request langsung ke IP atau host lain, default server menangani dan redirect ke www (lihat 00_redirect_to_www)
}
NGINX

# Enable sites
ln -fs /etc/nginx/sites-available/00_redirect_to_www /etc/nginx/sites-enabled/00_redirect_to_www
ln -fs /etc/nginx/sites-available/01_sirion_redirect /etc/nginx/sites-enabled/01_sirion_redirect
ln -fs /etc/nginx/sites-available/www.K46.com /etc/nginx/sites-enabled/www.K46.com

# Remove default if exists
rm -f /etc/nginx/sites-enabled/default

# Pastikan permissions
chown -R www-data:www-data /var/www/www.K46.com

# Restart nginx (validasi konfigurasi terlebih dahulu)
nginx -t
systemctl reload nginx

echo "Soal 11 (Sirion) selesai. - frontpage, /static -> 192.234.3.5, /app -> 192.234.3.6"
echo "Admin credentials: admin / K46admin"
# curl -I http://localhost/static/ untuk uji akses lokal
# curl -I http://localhost/app/
# curl -I http://sirion.K46.com/ untuk uji redirect
# curl -I http://www.K46.com/admin/ Untuk uji basic auth
# curl -I -u admin:K46admin http://www.K46.com/admin/ untuk uji auth pake kredensial