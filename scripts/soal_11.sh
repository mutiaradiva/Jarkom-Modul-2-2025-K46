#!/bin/bash

# Instalasi Nginx
apt update
apt install nginx -y

# Konfigurasi Nginx sebagai reverse proxy
# Menggunakan 'cat <<EOF >' adalah cara scripting untuk menulis file multiline
cat <<EOF > /etc/nginx/sites-available/K46.com
server {
    listen 80;
    server_name www.K46.com sirion.K46.com;

    # Meneruskan header penting ke server backend
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    # Aturan untuk path /static
    location /static/ {
        proxy_pass http://192.234.3.5/;
    }

    # Aturan untuk path /app
    location /app/ {
        proxy_pass http://192.234.3.6/;
    }
}
EOF

# Aktifkan site dan restart Nginx
ln -sf /etc/nginx/sites-available/K46.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
service nginx restart

echo "Konfigurasi reverse proxy untuk Soal 11 selesai."