#!/usr/local/bin/ruby
# Mimic Internet Builder (sample script using vitocha.rb)
# T.Suzuki

# 	$Id: jail.rb,v 1.37 2013/02/16 06:39:19 tss Exp $	

# before run this script
#  make router0-9 , bridge0-3 , server1-3
#   by using mkrouter and mkserver
#   ex. mkrouter router0 ; mkrouter bridge0

require File.expand_path(File.dirname(__FILE__) + '/vitocha.rb')

# jails path
$jails="/jails"

################################################################
# Main
################################################################

################################################################
# Setup Backborn
#  realsever-epair0b-(epair0a-router0-epair1a-epair1b-bridge0)
################################################################

# tomocha as a manager of epairs
tomocha=Operator.new

# create router and connect to realserver
# * bin/mkrouter router0 before run this script
router0=Router.new("router0")
tomocha.createpair
ifconfig("epair0a inet 192.168.11.1 netmask 255.255.255.0")
ifconfig("epair0a up")
router0.connect("epair0b") # connect to realhost
router0.assignip("epair0b","192.168.11.254","255.255.255.0") 
tomocha.register("router0","epair0b","192.168.11.254","255.255.255.0") # you need this if you did not use $tomocha.assignip .
router0.up("epair0b")
router0.start("quagga")
#
# connect gateway to inner segment bridge (IX) 
# * bin/mkrouter bridge0 before run this script
bridge0=Bridge.new("bridge0")
bridge0.on
tomocha.createpair
router0.connect("epair1a")
router0.assignip("epair1a","192.168.0.254","255.255.255.0")
tomocha.register("epair1a","router0","192.168.0.254","255.255.255.0")
bridge0.connect("epair1b")
tomocha.register("epair1b","bridge0")
bridge0.up("epair1b")
#
# create root server and connect to gateway
# * bin/mkrouter server0 before run this script
server0=Server.new("server0")
tomocha.createpair
server0.connect("epair2a")
server0.assignip("epair2a","192.168.255.1","255.255.255.0")
tomocha.register("epair2a","server0","192.168.255.1","255.255.255.0","65000")
server0.up("epair2a")
router0.connect("epair2b")
router0.assignip("epair2b","192.168.255.2","255.255.255.0")
tomocha.register("epair2b","router0","192.168.255.2","255.255.255.0","65000")
router0.up("epair2b")
server0.assigngw("192.168.255.2")
server0.start("nsd")

##########################################################################
# Your own network
##########################################################################

### Setup ISP ### 
0.upto(2) do |gnum|
  #
  ## Setup ISP BGP Router
  #
  rname0 = "router" + (1+gnum*3).to_s
  ip = gnum + 1
  tomocha.setuprouter(rname0)
  # connect to bridge0
  epaira,epairb,n=tomocha.createpair
  tomocha.connect(rname0,epaira)
  tomocha.assignip(rname0,epaira,"192.168.0.#{ip}",'255.255.255.0')
  tomocha.up(rname0,epaira)
  bridge0.connect(epairb) 
  bridge0.up(epairb)
  tomocha.register(epairb,"bridge0")
  tomocha.start(rname0,"quagga")
  #
  ## setup customer bgp router
  #
  rname1="router" + (2+gnum*3).to_s
  seg=gnum+2
  tomocha.setuprouter(rname1)
  # connect to isp
  epaira,epairb,n=tomocha.createpair
  tomocha.connect(rname1,epaira)
  ip="192.168.#{seg}.2"
  as=(gnum+65001).to_s
  tomocha.assignip(rname1,epaira,ip,'255.255.255.0',as)
  tomocha.up(rname1,epaira)
  tomocha.connect(rname0,epairb)
  ip="192.168.#{seg}.1"
  tomocha.assignip(rname0,epairb,ip,'255.255.255.0',as)
  tomocha.up(rname0,epairb)
  tomocha.start(rname1,"quagga")
  #
  ## setup customer ospf router
  #    assign /20
  #
  rname2="router" + (3+gnum*3).to_s
  tomocha.setuprouter(rname2)
  # connect to isp
  epaira,epairb,n=tomocha.createpair
  tomocha.connect(rname2,"epair#{n}a")
  seg=gnum*16 
  ip="172.16.#{seg}.2"
  as=(gnum+65004).to_s
  tomocha.assignip(rname2,epaira,ip,'255.255.255.0',as)
  tomocha.up(rname2,epaira)
  tomocha.connect(rname1,epairb)
  ip="172.16.#{seg}.1"
  tomocha.assignip(rname1,epairb,ip,'255.255.255.0',as)
  tomocha.up(rname1,epairb)
  tomocha.start(rname2,"quagga")
  #
  ## setup customer server segment
  #
  bridge="bridge" + (gnum+1).to_s
  tomocha.setupbridge(bridge)
  epaira,epairb,n=tomocha.createpair
  tomocha.connect(rname2,epaira)
  seg=gnum*16+1 
  ip="172.16.#{seg}.254"
  tomocha.assignip(rname2,epaira,ip,'255.255.255.0',as)
  tomocha.up(rname2,epaira)
  tomocha.connect(bridge,"epair#{n}b")
  tomocha.up(bridge,"epair#{n}b")
  #
  ## setup servers
  #
  servername="server" + (1+gnum).to_s
  ip="172.16.#{seg}.1"
  gw="172.16.#{seg}.254"
  tomocha.setupserver(servername)
  # connect to bridge
  epaira,epairb,n=tomocha.createpair
  tomocha.connect(servername,epaira)
  tomocha.assignip(servername,epaira,ip,'255.255.255.0',as)
  tomocha.assigngw(servername,gw)
  tomocha.up(servername,epaira)
  tomocha.connect(bridge,epairb)
  tomocha.up(bridge,epairb)
end

tomocha.start("server1","nsd")
tomocha.start("server1","unbound")

# make nwdiag
puts "Now I'm drawing network diagram!"
f=open("#{$jails}/data/net.diag","w")
  f.puts tomocha.gendiag
f.close
system("nwdiag -o #{$jails}/data/net.png #{$jails}/data/net.diag")

puts "Finish!"
