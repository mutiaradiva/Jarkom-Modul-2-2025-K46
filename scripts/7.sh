#tirion
nano /etc/bind/zones/db.K46.com
#edit jadi
$TTL    604800
@       IN      SOA     ns1.K46.com. root.K46.com. (
                        2025101101      ; Serial (YYYYMMDDnn)
                        604800          ; Refresh
                        86400           ; Retry
                        2419200         ; Expire
                        604800 )        ; Negative Cache TTL
;
; Name servers
@       IN      NS      ns1.K46.com.
@       IN      NS      ns2.K46.com.

; A records
ns1     IN      A       192.234.3.3
ns2     IN      A       192.234.3.4
sirion  IN      A       192.234.3.2
lindon  IN      A       192.234.3.5
vingilot IN     A       192.234.3.6

; CNAMEs
www     IN      CNAME   sirion.K46.com.
static  IN      CNAME   lindon.K46.com.
app     IN      CNAME   vingilot.K46.com.

service bind9 restart
ping -c 3 www.K46.com
ping -c 3 static.K46.com
ping -c 3 app.K46.com