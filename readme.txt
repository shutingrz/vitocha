# Poor Memo for VITOCHA 

# install
portsnap fetch && portsnap extract && portsnap update 
portsnap fetch && portsnap update 
install /usr/ports/sysutils/ezjail
vi /usr/local/etc/ezjail.conf
  ezjail_jaildir=/jails  (ex. alias of /usr/local/jails)
mv bin data *.conf.tar /jails
pkg_add -r python perl py27-nwdiag py27-blockdiagcontrib-cisco
pkg_add -r gawk libtool libsigsegv gmake autoconf net-snmp
cd /usr/ports/net/quagga ; make ; make install
cd /usr/ports/dns/nsd ; make ; make install
cd /usr/ports/dns/unbound ; make ; make install
cd /jails
tar xvf nsd-and-unbound.conf.tar
tar xvf quaggaconf.tar

# You must learn how to use ezjail-admin
ex.  ezjail-admin update -b
    (or ezjail-admin update -i /* if already 'make world' is done */)

# get pkgs from ftp server
ex. ftp ftp://ftp.jp.freebsd.org/pub/FreeBSD/ports/i386/packages-9-stable/Latest/ja-ng.tbz

# ready pkgs in flavours/router/pkg
ex.
ja-ng.tbz	quagga.tbz

# ready pkgs in flavours/server/pkg
ex.
bind98-9.8.1.1.tbz	djbdns-tools-1.05.tbz	ldns-1.6.11.tbz		unbound-1.4.13.tbz
daemontools-0.76_16.tbz	expat-2.0.1_2.tbz	nsd-3.2.9.tbz
djbdns-1.05_13.tbz	ja-ng-1.5.b1.tbz	quagga.tbz

# make jail file system
mkservers [servername]
mkrouters [servername]

# to delege jail file system
# chflags -R noschg router1
# ezjail-admin delete -fw router1

