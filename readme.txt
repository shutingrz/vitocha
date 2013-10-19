# Poor Memo for VITOCHA 

# install
portsnap fetch && portsnap extract && portsnap update 
portsnap fetch && portsnap update 
install /usr/ports/sysutils/ezjail
vi /usr/local/etc/ezjail.conf
  ezjail_jaildir=/jails  (ex. alias of /usr/local/jails)
pkg_add -r python perl py-nwdiag py-blockdiagcontrib-cisco
pkg_add -r gawk libtool libsigsegv gettext gmake autoconf268 netsnmp
cd /usr/ports/net/quagga ; make ; make install
cd /usr/ports/dns/nsd ; make ; make install
cd /usr/ports/dns/unbound ; make ; make install

# You must learn how to use ezjail-admin
ex.  ezjail-admin update -b
    (or ezjail-admin update -i /* if already 'make world' is done */)

# make flavours
cp -pR jails/flavours/example jails/flavours/router
cp -pR jails/flavours/example jails/flavours/server

# get pkgs from ftp server
ex. ftp ftp.jp.freebsd.org:/pub/FreeBSD/ports/amd64/packages-9-stable/Latest/bind98.tbz 

# ready pkgs in flavours/router/pkg
ex.
ja-ng.tbz	quagga.tbz

# ready pkgs in flavours/server/pkg
ex.
1-pkgconf.tbz	2-libiconv.tbz	2-libxml2.tbz (change filename for dependency)
bind98.tbz	djbdns-tools.tbz	ldns.tbz		unbound.tbz
daemontools.tbz	expat.tbz	nsd.tbz	openssl.tbz
djbdns.tbz	ja-ng.tbz	quagga.tbz

# make jail file system
cd /jails
mv bin data *.conf.tar /jails
mkservers [servername]
mkrouters [servername]
tar xvf nsd-and-unbound.conf.tar
tar xvf quaggaconf.tar

# to delege jail file system
# chflags -R noschg router1
# ezjail-admin delete -fw router1

