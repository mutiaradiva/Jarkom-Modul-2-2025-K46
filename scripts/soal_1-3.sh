#Eonwe
# WAN (ke NAT)
auto eth0
iface eth0 inet dhcp

# Barat
auto eth1
iface eth1 inet static
    address 192.234.1.1
    netmask 255.255.255.0

# Timur
auto eth2
iface eth2 inet static
    address 192.234.2.1
    netmask 255.255.255.0

# DMZ
auto eth3
iface eth3 inet static
    address 192.234.3.1
    netmask 255.255.255.0

up apt update
up apt install iptables
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 192.234.0.0/16

#Earendil
auto eth0
iface eth0 inet static
    address 192.234.1.2
    netmask 255.255.255.0
    gateway 192.234.1.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Elwing
auto eth0
iface eth0 inet static
    address 192.234.1.3
    netmask 255.255.255.0
    gateway 192.234.1.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Cirdan
auto eth0
iface eth0 inet static
    address 192.234.2.2
    netmask 255.255.255.0
    gateway 192.234.2.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Elrond
auto eth0
iface eth0 inet static
    address 192.234.2.3
    netmask 255.255.255.0
    gateway 192.234.2.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Maglor
auto eth0
iface eth0 inet static
    address 192.234.2.4
    netmask 255.255.255.0
    gateway 192.234.2.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Sirion
auto eth0
iface eth0 inet static
    address 192.234.3.2
    netmask 255.255.255.0
    gateway 192.234.3.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Tirion
auto eth0
iface eth0 inet static
    address 192.234.3.3
    netmask 255.255.255.0
    gateway 192.234.3.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Valmar
auto eth0
iface eth0 inet static
    address 192.234.3.4
    netmask 255.255.255.0
    gateway 192.234.3.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Lindon
auto eth0
iface eth0 inet static
    address 192.234.3.5
    netmask 255.255.255.0
    gateway 192.234.3.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf

#Vingilot
auto eth0
iface eth0 inet static
    address 192.234.3.6
    netmask 255.255.255.0
    gateway 192.234.3.1
up echo nameserver 192.168.122.1 > /etc/resolv.conf
