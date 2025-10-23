#!/bin/bash
set -euo pipefail

# soal_13.sh - konfigurasi dan start BIND sebagai slave (Valmar / ns2)
MASTER="192.234.3.3"
DOMAIN="K46.com"
LOGDIR="/var/log/bind"
NAMED_BIN="/usr/sbin/named"
NAMED_CONF="/etc/bind/named.conf"

# Paksa resolver sementara agar apt/dig ke master berhasil
echo "nameserver ${MASTER}" > /etc/resolv.conf

# Pastikan direktori log ada
mkdir -p "${LOGDIR}"
chown bind:bind "${LOGDIR}" 2>/dev/null || true
chmod 750 "${LOGDIR}" 2>/dev/null || true

# Tulis named.conf.local sebagai slave (overwrite agar konsisten)
cat > /etc/bind/named.conf.local <<EOF
zone "${DOMAIN}" {
  type slave;
  masters { ${MASTER}; };
  file "/var/lib/bind/db.${DOMAIN}";
  allow-notify { ${MASTER}; };
};

zone "3.234.192.in-addr.arpa" {
  type slave;
  masters { ${MASTER}; };
  file "/var/lib/bind/db.192.234.3";
  allow-notify { ${MASTER}; };
};
EOF

# Pastikan direktori var lib bind ada
mkdir -p /var/lib/bind
chown bind:bind /var/lib/bind 2>/dev/null || true

# Coba start service bind9 (jika environment mendukung)
if command -v service >/dev/null 2>&1; then
  service bind9 start || true
fi

# Jika named belum berjalan, jalankan manual (foreground -> log)
if ! pidof named >/dev/null 2>&1; then
  setsid "${NAMED_BIN}" -u bind -c "${NAMED_CONF}" -g > "${LOGDIR}/named.out" 2>&1 &
  sleep 2
fi

echo
echo "=== tail ${LOGDIR}/named.out (jika ada) ==="
tail -n 60 "${LOGDIR}/named.out" 2>/dev/null || true

echo
echo "=== Verifikasi dari master ==="
dig @"${MASTER}" ${DOMAIN} SOA +short || true

echo
echo "=== Verifikasi lokal (Valmar) ==="
dig @127.0.0.1 ${DOMAIN} SOA +short || true
dig @127.0.0.1 ${DOMAIN} AXFR +short || true

echo
echo "Selesai. Jika AXFR belum terlihat, tunggu 5–10 detik lalu ulangi: dig @127.0.0.1 ${DOMAIN} AXFR +short"
# dig @192.234.3.3 K46.com SOA +short    # master
# dig @127.0.0.1 K46.com SOA +short      # slave
# Diatas untuk membandingkan serial master dengan slave
# dig @127.0.0.1 sirion.K46.com A +short untuk test query ke slave