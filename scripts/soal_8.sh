#tirion
nano /etc/bind/named.conf.local
#edit jadi
zone "K46.com" {
    type master;
    file "/etc/bind/zones/db.K46.com";
    allow-transfer { 192.234.3.4; };
    also-notify { 192.234.3.4; };
};

zone "3.234.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.K46.com";
    allow-transfer { 192.234.3.4; };
    also-notify { 192.234.3.4; };
};

nano /etc/bind/zones/db.K46.com
#edit jadi
$TTL    604800
@       IN      SOA     ns1.K46.com. root.K46.com. (
                        2025101201      ; Serial
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;

; === Nameservers ===
@       IN      NS      ns1.K46.com.
@       IN      NS      ns2.K46.com.

; === Host Records ===
ns1     IN      A       192.234.3.3
ns2     IN      A       192.234.3.4
sirion  IN      A       192.234.3.2
lindon  IN      A       192.234.3.5
vingilot IN     A       192.234.3.6

; === CNAME ===
www     IN      CNAME   sirion.K46.com.
static  IN      CNAME   lindon.K46.com.
app     IN      CNAME   vingilot.K46.com.

; === Reverse PTR ===
2       IN      PTR     sirion.K46.com.
5       IN      PTR     lindon.K46.com.
6       IN      PTR     vingilot.K46.com.

service bind9 restart

#valmar
nano /etc/bind/named.conf.local
#edit jadi
zone "K46.com" {
    type slave;
    masters { 192.234.3.3; };   // IP Tirion (ns1)
    file "/var/lib/bind/db.K46.com";
};

zone "3.234.192.in-addr.arpa" {
    type slave;
    masters { 192.234.3.3; };
    file "/var/lib/bind/db.192.234.3";
};

service bind9 restart

#uji
dig -x 192.234.3.2 @192.234.3.4
dig -x 192.234.3.5 @192.234.3.4
dig -x 192.234.3.6 @192.234.3.4