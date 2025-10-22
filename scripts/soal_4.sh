# Tirion
apt update
apt install bind9 -y
nano /etc/bind/named.conf.local
#edit jadi
zone "K46.com" {
    type master;
    file "/etc/bind/zones/db.K46.com";
    allow-transfer { 192.234.3.3; };     // IP Valmar
    notify yes;
    also-notify { 192.234.3.3; };
};

mkdir -p /etc/bind/zones
nano /etc/bind/zones/db.K46.com
#edit jadi
$TTL 604800
@   IN  SOA ns1.K46.com. root.K46.com. (
        2025101101; Serial
        604800    ; Refresh
        86400     ; Retry
        2419200   ; Expire
        604800 )  ; Negative Cache TTL
;
; Name Server Information
@       IN  NS      ns1.K46.com.
@       IN  NS      ns2.K46.com.

; Name Server A Record
ns1     IN  A       192.234.3.2
ns2     IN  A       192.234.3.3

; Apex (root domain)
@       IN  A       192.234.3.2

nano /etc/bind/named.conf.options
#edit jadi
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    recursion yes;
    auth-nxdomain no;
    listen-on { any; };
};

ln -s /etc/init.d/named /etc/init.d/bind9
service bind9 start

#Valmar
nano /etc/bind/named.conf.local
#edit jadi
zone "K46.com" {
    type slave;
    masters { 192.234.3.3; };   // IP ns1 Tirion
    file "/var/lib/bind/db.K46.com";
};

#Valmar
samakan dengan langkah di Tirion

service bind9 restart

ping K46.com


