#!/usr/local/bin/ruby
#
# nwdiag2jail (experimental)
# $Id: nwdiag2jail.rb,v 1.5 2013/01/20 08:36:22 tss Exp $
# T.Suzuki
#
def address(n)
  [(n >> 24) & 0xff,(n >> 16) & 0xff,(n >>  8) & 0xff,(n >>  0) & 0xff].map {|i| i.to_s }.join('.')
end

def calc_ip(ip,prefixlen)
  ips = ip.split(/\./).inject(0) {|r, n| r * 256 + n.to_i }
  netmask = (0 ... prefixlen).inject(0) {|r, n| (1 << 31) | (r >> 1) }
  prefix   = ips & netmask
  [address(ips), address(netmask), address(prefix)]
end


f=open("/jails/data/net.diag","r")
newline=f.read.map{|line| line.chomp!}.to_s.scan(/(network.*?\})/)
f.close

data=[]
newline.each{|network|
	prefix=network.to_s.scan(/{\s*address.*?\"(.*)\//).to_s
	prefixlen=network.to_s.scan(/{\s*address.*\/([0-9]+)/).to_s.to_i
	netmask=calc_ip(prefix,prefixlen)[1]
	bridge=network.to_s.scan(/(bridge[0-9]+)/).to_s
	equipment=network.to_s.scan(/(router[0-9]+|server[0-9]+)/).map{|item| item=item.to_s}
	data<<[bridge,equipment,prefix,prefixlen,netmask]
}

data.each{|net|
  bridge,equipment,prefix,prefixlen,netmask = net
  n=0
  if bridge !="" then
	equipment.each{|equipment|
		puts "n=tomocha.createpair"
                n=n+1
		puts "tomocha.connect(#{bridge}"+",epair#{n}a)"
		puts "tomocha.connect(#{equipment}"+",epair#{n}b)"
		puts "tomocha.assignip(epair#{n}b,"+prefixlen.to_s+","+netmask+")"
	}
  else
	equipment1,equipment2 = net
	puts "n=tomocha.createpair"
        n=n+1
	puts "tomocha.connect(#{equipment1}"+",epair#{n}a)"
	puts "tomocha.connect(#{equipment2}"+",epair#{n}b)"
  end
  puts "---------------"
}

