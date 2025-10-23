#!/bin/bash
set -euo pipefail
HOST=$(hostname)
echo "== soal_17: Autostart dan Verifikasi (Host: $HOST) =="

# Tambah PATH untuk jaga-jaga
export PATH=$PATH:/bin:/usr/bin:/usr/sbin

# Fungsi autostart & restart service
SERVICE() {
    local svc=$1
    if command -v systemctl >/dev/null 2>&1; then
        systemctl enable "$svc" >/dev/null 2>&1 || true
        systemctl restart "$svc" >/dev/null 2>&1 || true
    elif [ -x "/etc/init.d/$svc" ]; then
        update-rc.d "$svc" defaults >/dev/null 2>&1 || true
        /etc/init.d/$svc restart >/dev/null 2>&1 || true
    else
        echo "Service $svc tidak ditemukan."
    fi
}

# Fungsi cek proses
CHECKPROC() {
    local p=$1
    if command -v ps >/dev/null 2>&1; then
        if ps -ef | grep -v grep | grep -q "$p"; then
            echo "$p aktif"
        else
            echo "$p tidak aktif"
        fi
    else
        echo "ps tidak tersedia, lewati pemeriksaan proses."
    fi
}

# Cek port (opsional, untuk verifikasi tambahan)
CHECKPORT() {
    local port=$1
    if command -v netstat >/dev/null 2>&1; then
        netstat -tuln | grep ":$port" >/dev/null 2>&1 && echo "Port $port terbuka" || echo "Port $port tertutup"
    elif command -v ss >/dev/null 2>&1; then
        ss -tuln | grep ":$port" >/dev/null 2>&1 && echo "Port $port terbuka" || echo "Port $port tertutup"
    fi
}

# Jalankan sesuai hostname
case "$HOST" in
Tirion|tirion)
    echo "-- DNS Master (Bind9)"
    [ -x /usr/sbin/named ] && ln -sf /usr/sbin/named /usr/sbin/bind9 || true
    SERVICE bind9
    CHECKPROC named
    dig @127.0.0.1 K46.com SOA +short
    ;;
Valmar|valmar)
    echo "-- DNS Slave (Bind9)"
    [ -x /usr/sbin/named ] && ln -sf /usr/sbin/named /usr/sbin/bind9 || true
    SERVICE bind9
    CHECKPROC named
    dig @127.0.0.1 K46.com SOA +short
    ;;
Sirion|sirion)
    echo "-- Reverse Proxy (Nginx)"
    SERVICE nginx
    CHECKPROC nginx
    CHECKPORT 80
    echo "Tes akses:"
    curl -I http://localhost/static/ | head -n1
    curl -I http://localhost/app/ | head -n1
    ;;
Lindon|lindon)
    echo "-- Web Statis (Nginx)"
    SERVICE nginx
    CHECKPROC nginx
    CHECKPORT 80
    curl -I http://localhost/static/ | head -n1
    ;;
Vingilot|vingilot)
    echo "-- Web Dinamis (PHP-FPM + Nginx)"
    apt-get update -y >/dev/null 2>&1 || true
    apt-get install -y nginx php8.4-fpm >/dev/null 2>&1 || true
    SERVICE php8.4-fpm
    SERVICE nginx
    mkdir -p /var/www/html
    echo "<?php echo 'Vingilot OK - PHP '.phpversion(); ?>" > /var/www/html/index.php
    CHECKPROC php-fpm
    CHECKPROC nginx
    CHECKPORT 80
    curl -s http://localhost/ | grep "Vingilot" && echo "PHP-FPM merespons"
    ;;
*)
    echo "Hostname tidak dikenali. Jalankan di node Tirion, Valmar, Sirion, Lindon, atau Vingilot."
    ;;
esac

echo "== Selesai untuk $HOST =="