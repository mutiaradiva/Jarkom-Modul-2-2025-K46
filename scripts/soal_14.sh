#!/bin/bash
set -euo pipefail

echo "== soal_14: konfigurasi web statis di Lindon =="

DOMAIN="K46.com"
WEBROOT="/var/www/www.${DOMAIN}/static"
LOGDIR="/var/log/nginx"
INDEXFILE="${WEBROOT}/index.html"

# 1. Update repositori & install nginx
echo "-- memastikan nginx terpasang"
apt update -y >/dev/null 2>&1 || true
apt install -y nginx >/dev/null 2>&1

# 2. Buat direktori web
echo "-- membuat direktori web di ${WEBROOT}"
mkdir -p "${WEBROOT}"
chown -R www-data:www-data /var/www/www.${DOMAIN}
chmod -R 755 /var/www/www.${DOMAIN}

# 3. Buat halaman index sederhana
echo "-- menulis halaman index"
cat > "${INDEXFILE}" <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>Static Page - K46</title>
  <style>
    body { font-family: Arial, sans-serif; background: #eef2f3; color: #333; text-align: center; margin-top: 10%%; }
    h1 { color: #0055a5; }
  </style>
</head>
<body>
  <h1>Welcome to Lindon Static Web Server</h1>
  <p>Server: Lindon (192.234.3.5)</p>
  <p>This is the static page for <b>www.K46.com/static</b>.</p>
</body>
</html>
EOF

# 4. Buat konfigurasi virtual host
echo "-- menulis konfigurasi virtual host Nginx"
cat > /etc/nginx/sites-available/www.${DOMAIN} <<EOF
server {
    listen 80;
    server_name www.${DOMAIN};

    access_log ${LOGDIR}/www.${DOMAIN}.access.log;
    error_log ${LOGDIR}/www.${DOMAIN}.error.log;

    location /static {
        root /var/www/www.${DOMAIN};
        index index.html;
    }
}
EOF

# 5. Aktifkan konfigurasi
ln -sf /etc/nginx/sites-available/www.${DOMAIN} /etc/nginx/sites-enabled/www.${DOMAIN}
rm -f /etc/nginx/sites-enabled/default

# 6. Uji konfigurasi dan restart nginx
echo "-- menguji konfigurasi Nginx"
nginx -t
systemctl restart nginx || service nginx restart

# 7. Tampilkan status dan uji curl
echo "-- status nginx"
ps aux | grep nginx | grep -v grep || echo "nginx belum jalan"
echo "-- uji akses lokal"
curl -I http://localhost/static || true

echo
echo "Selesai: Web statis www.${DOMAIN}/static sudah diatur di Lindon (192.234.3.5)."
# curl -I http://localhost/static/ Uji akses lokal
# curl -I http://www.K46.com/static/ Ujikan itu dari sirion