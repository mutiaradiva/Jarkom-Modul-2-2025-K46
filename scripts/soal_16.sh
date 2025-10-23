echo "== soal_16: konfigurasi Reverse Proxy di Sirion =="

NGINX_CONF="/etc/nginx/sites-available/www.K46.com"
NGINX_ENABLED="/etc/nginx/sites-enabled/www.K46.com"

# 1. Pastikan nginx sudah terpasang
echo "-- memastikan nginx terpasang"
apt update -y >/dev/null 2>&1 || true
apt install -y nginx >/dev/null 2>&1

# 2. Backup konfigurasi lama (jika ada)
if [ -f "$NGINX_CONF" ]; then
    cp "$NGINX_CONF" "${NGINX_CONF}.bak_$(date +%s)"
    echo "-- backup konfigurasi lama di ${NGINX_CONF}.bak_$(date +%s)"
fi

# 3. Tulis konfigurasi baru untuk reverse proxy
echo "-- menulis konfigurasi reverse proxy baru"
cat > "$NGINX_CONF" <<'EOF'
server {
    listen 80;
    server_name www.K46.com;

    # Root frontpage
    root /var/www/www.K46.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Static route -> Lindon
    location /static/ {
        proxy_pass http://192.234.3.5/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # App route -> Earendil
    location /app/ {
        proxy_pass http://192.234.1.2/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    error_page 404 /404.html;
}
EOF

# 4. Pastikan symlink aktif
ln -sf "$NGINX_CONF" "$NGINX_ENABLED"

# 5. Uji sintaks Nginx
echo "-- menguji konfigurasi nginx"
nginx -t

# 6. Restart nginx (gunakan service, bukan systemctl)
echo "-- me-restart nginx"
service nginx restart

# 7. Cek status proses
echo "-- memeriksa proses nginx"
ps aux | grep nginx | grep -v grep || echo "nginx belum jalan"

# 8. Uji koneksi lokal
echo "-- uji akses lokal (frontpage, /static, /app)"
echo "-> Frontpage:"
curl -I http://localhost/ | head -n 1
echo "-> Static (proxy ke Lindon):"
curl -I http://localhost/static/ | head -n 1
echo "-> App (proxy ke Earendil):"
curl -I http://localhost/app/ | head -n 1

echo
echo "Selesai: Reverse Proxy Sirion aktif!"
echo "Route: / -> local, /static -> Lindon (192.234.3.5), /app -> Earendil (192.234.1.2)"
# dig @192.234.3.3 K46.com SOA +short Cek serial
# dig @192.234.3.4 K46.com SOA +short
# dig @127.0.0.1 lindon.K46.com A verifikasi TTL
