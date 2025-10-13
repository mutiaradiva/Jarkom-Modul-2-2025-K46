# tirion
root@Valmar:~# nano /etc/bind/named.conf.local
#edit jadi
zone "K46.com" {
    type master;
    file "/etc/bind/zones/db.K46.com";
    allow-transfer { 192.234.3.4; };     // IP Valmar
    notify yes;
    also-notify { 192.234.3.3; };
};

mkdir -p /etc/bind/zones
nano /etc/bind/zones/db.K46.com
cat /etc/bind/zones/db.K46.com #lihat no serial
service bind9 restart

#valmar
nano /etc/bind/named.conf.local
#edit jadi
zone "K46.com" {
    type slave;
    masters { 192.234.3.3; };   # IP Tirion (ns1)
    file "/var/lib/bind/db.K46.com";
};

service bind9 restart
ls -l /var/lib/bind/

#tirion
dig @192.234.3.3 K46.com SOA #cek serial sama dengan valmar

#valmar
dig @192.234.3.4 K46.com SOA #cek serial sama dengan tirion