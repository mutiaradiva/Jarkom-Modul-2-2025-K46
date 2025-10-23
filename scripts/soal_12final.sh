#!/bin/bash
set -euo pipefail

echo "== soal_12_final: Konfigurasi DNS Master ns1 (Tirion) =="

DOMAIN="K46.com"
REV="3.234.192.in-addr.arpa"
ZONEDIR="/etc/bind/zones"
LOGDIR="/var/log/bind"

# 1. Instal paket dan siapkan direktori
echo "-- memastikan bind9 dan utilitas tersedia"
apt update -y >/dev/null 2>&1 || true
apt install -y bind9 dnsutils procps >/dev/null 2>&1

echo "-- membuat direktori zona dan log"
mkdir -p "$ZONEDIR"
mkdir -p "$LOGDIR"
chown -R bind:bind "$LOGDIR"

# 2. Konfigurasi utama BIND
echo "-- menulis /etc/bind/named.conf.local"
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "$ZONEDIR/db.$DOMAIN";
    allow-transfer { 192.234.3.4; };   // Valmar (slave)
    also-notify { 192.234.3.4; };
};

zone "$REV" {
    type master;
    file "$ZONEDIR/db.$REV";
    allow-transfer { 192.234.3.4; };
    also-notify { 192.234.3.4; };
};
EOF

# 3. File zona untuk DOMAIN
echo "-- menulis file zona forward ($DOMAIN)"
cat > "$ZONEDIR/db.$DOMAIN" <<EOF
\$TTL 30
@   IN  SOA ns1.$DOMAIN. root.$DOMAIN. (
        $(date +%Y%m%d)01 ; Serial
        604800 ; Refresh
        86400  ; Retry
        2419200 ; Expire
        30 ) ; Negative Cache TTL
;
@       IN  NS      ns1.$DOMAIN.
@       IN  NS      ns2.$DOMAIN.
ns1     IN  A       192.234.3.3
ns2     IN  A       192.234.3.4
sirion  IN  A       192.234.3.2
lindon  IN  A       192.234.3.5
vingilot IN  A      192.234.3.6
earendil IN  A      192.234.1.2
www     IN  CNAME   sirion.$DOMAIN.
static  IN  CNAME   lindon.$DOMAIN.
app     IN  CNAME   earendil.$DOMAIN.
EOF

# 4. File zona untuk REVERSE
echo "-- menulis file zona reverse ($REV)"
cat > "$ZONEDIR/db.$REV" <<EOF
\$TTL 30
@   IN  SOA ns1.$DOMAIN. root.$DOMAIN. (
        $(date +%Y%m%d)01 ; Serial
        604800 ; Refresh
        86400  ; Retry
        2419200 ; Expire
        30 ) ; Negative Cache TTL
;
@       IN  NS      ns1.$DOMAIN.
@       IN  NS      ns2.$DOMAIN.
3       IN  PTR     ns1.$DOMAIN.
4       IN  PTR     ns2.$DOMAIN.
2       IN  PTR     sirion.$DOMAIN.
5       IN  PTR     lindon.$DOMAIN.
6       IN  PTR     vingilot.$DOMAIN.
EOF

# 5. Validasi konfigurasi
echo "-- memeriksa konfigurasi dan zona"
named-checkconf
named-checkzone "$DOMAIN" "$ZONEDIR/db.$DOMAIN"
named-checkzone "$REV" "$ZONEDIR/db.$REV"

# 6. Jalankan service secara manual jika systemd tidak ada
echo "-- menjalankan service bind9"
if command -v systemctl >/dev/null 2>&1; then
    systemctl enable bind9 >/dev/null 2>&1 || true
    systemctl restart bind9
else
    pkill named 2>/dev/null || true
    setsid /usr/sbin/named -u bind -c /etc/bind/named.conf -g > "$LOGDIR/named.out" 2>&1 &
fi

sleep 3

# 7. Autostart (rc.local fallback)
if [ ! -f /etc/rc.local ]; then
cat > /etc/rc.local <<'RC'
#!/bin/sh -e
pgrep named >/dev/null || setsid /usr/sbin/named -u bind -c /etc/bind/named.conf -g > /var/log/bind/named.out 2>&1 &
exit 0
RC
chmod +x /etc/rc.local
fi

# 8. Verifikasi proses dan respons DNS
echo "-- verifikasi proses dan query DNS"
ps -ef | grep named | grep -v grep || echo "named belum aktif"
echo "SOA:"
dig @127.0.0.1 $DOMAIN SOA +short
echo "A record:"
dig @127.0.0.1 www.$DOMAIN A +short
echo "Reverse PTR:"
dig @127.0.0.1 -x 192.234.3.5 +short

echo "== Selesai: DNS Master ns1 ($DOMAIN) aktif dan autostart =="
# dig @127.0.0.1 K46.com SOA +short Untuk uji DNS Resolution
# dig @127.0.0.1 sirion.K46.com A +short
# dig @127.0.0.1 www.K46.com CNAME +short
# dig @127.0.0.1 -x 192.234.3.2 +short