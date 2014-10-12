head	1.29;
access;
symbols;
locks
	guest:1.29; strict;
comment	@# @;


1.29
date	2013.11.23.17.29.36;	author guest;	state Exp;
branches;
next	1.28;

1.28
date	2013.11.17.16.36.33;	author guest;	state Exp;
branches;
next	1.27;

1.27
date	2013.11.17.03.36.24;	author tss;	state Exp;
branches;
next	1.26;

1.26
date	2013.02.16.06.21.42;	author tss;	state Exp;
branches;
next	1.25;

1.25
date	2013.02.16.05.56.26;	author tss;	state Exp;
branches;
next	1.24;

1.24
date	2013.02.12.05.40.17;	author tss;	state Exp;
branches;
next	1.23;

1.23
date	2013.02.12.05.39.29;	author tss;	state Exp;
branches;
next	1.22;

1.22
date	2013.02.12.05.38.08;	author tss;	state Exp;
branches;
next	1.21;

1.21
date	2013.01.20.13.57.18;	author tss;	state Exp;
branches;
next	1.20;

1.20
date	2013.01.20.13.30.13;	author tss;	state Exp;
branches;
next	1.19;

1.19
date	2013.01.20.13.03.18;	author tss;	state Exp;
branches;
next	1.18;

1.18
date	2013.01.20.12.58.31;	author tss;	state Exp;
branches;
next	1.17;

1.17
date	2013.01.20.07.38.52;	author tss;	state Exp;
branches;
next	1.16;

1.16
date	2013.01.20.06.25.55;	author tss;	state Exp;
branches;
next	1.15;

1.15
date	2013.01.20.06.18.55;	author tss;	state Exp;
branches;
next	1.14;

1.14
date	2013.01.13.08.29.29;	author root;	state Exp;
branches;
next	1.13;

1.13
date	2013.01.13.08.24.55;	author root;	state Exp;
branches;
next	1.12;

1.12
date	2012.11.10.07.36.19;	author root;	state Exp;
branches;
next	1.11;

1.11
date	2012.11.09.15.56.26;	author root;	state Exp;
branches;
next	1.10;

1.10
date	2012.11.09.15.24.13;	author root;	state Exp;
branches;
next	1.9;

1.9
date	2012.11.07.14.50.54;	author root;	state Exp;
branches;
next	1.8;

1.8
date	2012.11.06.02.09.16;	author root;	state Exp;
branches;
next	1.7;

1.7
date	2012.11.06.01.46.11;	author root;	state Exp;
branches;
next	1.6;

1.6
date	2012.11.02.08.24.48;	author root;	state Exp;
branches;
next	1.5;

1.5
date	2012.11.02.07.07.47;	author root;	state Exp;
branches;
next	1.4;

1.4
date	2012.11.01.14.03.57;	author root;	state Exp;
branches;
next	1.3;

1.3
date	2012.10.30.13.55.08;	author root;	state Exp;
branches;
next	1.2;

1.2
date	2012.10.28.08.20.17;	author root;	state Exp;
branches;
next	1.1;

1.1
date	2012.10.28.08.11.11;	author root;	state Exp;
branches;
next	;


desc
@@


1.29
log
@add genhtml
@
text
@#
# VITOCHA
#  - Virtual To**cha for VIMAGE Virtual Network-
#
#Copyright (c) 2012-2013, Tsunehiko Suzuki
#All rights reserved.
#                                                                              
# Redistribution and use in source and binary forms, with or without           
# modification, are permitted provided that the following conditions           
# are met:                                                                     
# 1. Redistributions of source code must retain the above copyright            
#    notice, this list of conditions and the following disclaimer.             
# 2. Redistributions in binary form must reproduce the above copyright         
#    notice, this list of conditions and the following disclaimer in the       
#    documentation and/or other materials provided with the distribution.      
#                                                                              
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND           
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE        
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   
# ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE          
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL   
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS      
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)        
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT   
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF       
# SUCH DAMAGE.                                                                 

# 	$Id: vitocha.rb 1.28 2013/11/17 16:36:33 guest Exp guest $

# Usage
# operator=Operator.new
# operator.createpair : create epair
# operator.destroypair : destroy epair
# operator.register(epair,jainame,ip,mask.as) : resgister "epair is in jailname" on @@daicho
# operator.unregister(epair) : unregister from @@daicho
# operator.find(epair) : get the jailname which the epair is in
# operator.epairnum : get the number of most recent epair
# operator.setuprouter(jailname) : create router instance
# operator.setupbridge(jailname) : create bridge instance
# operator.setupserver# (jailname) : create server instance
# operator.assignip(obj,epair,ip,mask,as) : set ip address
# operator.assignip6(obj,epair,ip,plefixlen,as) : set ipv6 address
# operator.assigngw(obj,gw) : set default gateway (only for server)
# operator.up(obj,epair) : ifconfig up
# operator.down(obj,epair) : ifconfig down
# operator.gendiag : generate a code for nwdiag

require 'shell'
require File.expand_path(File.dirname(__FILE__) + '/shcommand')
require File.expand_path(File.dirname(__FILE__) + '/equipment')
require File.expand_path(File.dirname(__FILE__) + '/router')
require File.expand_path(File.dirname(__FILE__) + '/bridge')
require File.expand_path(File.dirname(__FILE__) + '/server')

class Operator

  def initialize()
    @@daicho=Hash.new
    num=nil
    @@epairnum=num
    puts "Hi, I'll do your job."
  end

  def createpair
    sh=Shell.new
    num=nil
    sh.transact{
      num=ifconfig("epair create").to_s.scan(/epair([\d]+)a/)[0][0].to_i
    }
    ifconfig("epair#{num}a link 02:c0:e4:00:#{num}:0a")
    ifconfig("epair#{num}b link 02:c0:e4:00:#{num}:0b")
    @@epairnum=num
    return "epair#{num}a","epair#{num}b",num
  end

  def destroypair(epair)
    sh=Shell.new
    if epair=~/epair[0-9]+[ab]/ then epair!chop end
    sh.transact{
      ifconfig("#{epair}a destroy")
    }
    @@daicho.delete("#{epair}a".to_sym)
    @@daicho.delete("#{epair}b".to_sym)
  end

  def register(epair,jailname,ip4="",mask="",as="",ip6="",prefixlen="")
    @@daicho[epair.to_sym]=[jailname,ip4,mask,as,ip6,prefixlen]
  end

  def unregister(epair)
    @@daicho.delete(epair.to_sym)
  end

  def find(epair)
    return @@daicho[epair.to_sym]
  end

  def setuprouter(jailname)
    eval("$#{jailname}=Router.new('#{jailname}')")
    puts "#{jailname} done!"
  end

  def setupbridge(jailname)
    eval("$#{jailname}=Bridge.new('#{jailname}')")
    puts "#{jailname} done!"
  end

  def setupserver(jailname)
    eval("$#{jailname}=Server.new('#{jailname}')")
    puts "#{jailname} done!"
  end

  def connect(obj,epair)
    eval("$#{obj}.connect('#{epair}')")
    @@daicho[epair.to_sym]=[obj,"",""]
    puts "#{epair} is connected to #{obj}"
  end

  def assignip(obj,epair,ip,mask,as="")
    eval("$#{obj}.assignip('#{epair}','#{ip}','#{mask}')")
    ip6=self.find(epair)[4]
    prefixlen=self.find(epair)[5]
    @@daicho[epair.to_sym]=[obj,ip,mask,as,ip6,prefixlen]
    puts "#{epair} of #{obj} has #{ip}/#{mask}."
  end

  def assignip6(obj,epair,ip6,prefixlen,as="")
    eval("$#{obj}.assignip6('#{epair}','#{ip6}','#{prefixlen}')")
    ip4=self.find(epair)[1]
    mask=self.find(epair)[2]
    @@daicho[epair.to_sym]=[obj,ip4,mask,as,ip6,prefixlen]
    puts "#{epair} of #{obj} has #{ip6}/#{prefixlen}."
  end

  def assigngw(obj,gw)
    eval("$#{obj}.assigngw('#{gw}')")
    puts "assign #{gw} as gateway of #{obj}."
  end

  def up(obj,epair)
    eval("$#{obj}.up('#{epair}')")
    puts "#{epair} up."
  end

  def down(obj,epair)
    eval("$#{obj}.down('#{epair}')")
    puts "#{epair} down."
  end

  def start(obj,program)
    eval("$#{obj}.start('#{program}')")
    puts "start #{program} on #{obj}."
  end

  def gendiag
    @@diag="nwdiag {\n"
    @@topology=""
    bridge=Hash.new
    @@daicho.each_pair{|epair,data|
      equipment_a=self.find(epair)[0]
      b=self.find(epair.to_s.chop+'b')
      equipment_b=b[0] unless b==nil
      if equipment_a != nil && equipment_b != nil && epair.to_s =~ /epair.*a/ then
        if equipment_a =~ /bridge/ || equipment_b =~ /bridge/ then
          a=[]
          if equipment_a =~ /bridge/ then
            a.concat(bridge[equipment_a.to_sym]) unless bridge[equipment_a.to_sym] == nil
            a<< (epair.to_s.chop+b).to_sym
            bridge[equipment_a.to_sym]=a 
          end
          if equipment_b =~ /bridge/ then
            a.concat(bridge[equipment_b.to_sym]) unless bridge[equipment_b.to_sym] == nil
            a<< epair
            bridge[equipment_b.to_sym]=a
          end
        else
          equipment1=self.find(epair)[0]
          equipment2=self.find(epair.to_s.chop+'b')[0]
          fig1="";fig2=""
          fig1=',shape="cisco.router"' if equipment1 =~ /router/
          fig1=',shape="cisco.standard_host"' if equipment1 =~ /server/
          fig2=',shape="cisco.router"' if equipment2 =~ /router/
          fig2=',shape="cisco.standard_host"' if equipment2 =~ /server/
          @@topology=@@topology+"network {"+self.find(epair)[0]+' [address = "'+self.find(epair)[1]+'"'+fig1+']; '+self.find(epair.to_s.chop+'b')[0]+' [address = "'+self.find(epair.to_s.chop+'b')[1]+'"'+fig2+']; }'+"\n"
        end
      end
    }
    bridge.each_pair{|b,pairs|
      @@topology=@@topology+"network #{b} {"
      pairs.each{|p|
        equipment=@@daicho[p][0]
        address=@@daicho[p][1]
        fig=""
        fig=',shape="cisco.router"' if equipment =~ /router/
        fig=',shape="cisco.standard_host"' if equipment =~ /server/
        @@topology=@@topology+' '+equipment+' [address = "'+address+'"'+fig+"]; "
      }
    @@topology=@@topology+"}\n"
    }
    line=[]
    @@topology.each_line{|m| 
	i=m.scan(/(router[0-9]+) /).sort.shift[0].scan(/([0-9]+)/)[0][0].to_i
        if line[i] != nil then
          line[i]=line[i].to_s+"\n"+m
        else
          line[i]=m
        end
    }
    @@diag=@@diag+line.join($,)+"\n}"
    return @@diag
  end

  def genhtml
    equipments=Hash.new
    list=Array.new
    @@daicho.each{|p,data| equipments[data[0]]=data}
    equipments.each{|key,value| list<<"<li>#{key} (#{value[1]}/#{value[2]})"}
    html="<head><title>Inernet Simulator</title></head>\n"
    html=html+"<body>\n"
    html=html+"<table><tr><td><img src=\"net.png\"></td><td valign=\"top\">\n"
    html=html+"<ul>\n"
    html=html+list.sort.join
    html=html+"</ul>\n"
    html=html+"</td></table>\n"
    html=html+"</body>\n"
    return html
  end

  attr_accessor :epairnum
  attr_accessor :daicho
end
@


1.28
log
@rm debug print lines.
@
text
@d29 1
a29 1
# 	$Id: vitocha.rb 1.27 2013/11/17 03:36:24 tss Exp guest $
d214 16
@


1.27
log
@adapt to Ruby2.0
@
text
@d29 1
a29 1
# 	$Id: vitocha.rb 1.26 2013/02/16 06:21:42 tss Exp $
a188 1
    p bridge
a190 2
	puts "------------------"
	p pairs
@


1.26
log
@add Copyright
@
text
@d29 1
a29 1
# 	$Id: vitocha.rb 1.25 2013/02/16 05:56:26 tss Exp tss $
d69 1
a69 1
      num=ifconfig("epair create").to_s.scan(/epair([\d]+)a/).to_s.to_i
d189 1
d192 5
a196 8
      pairs.each{|p| 
        if p =~ /epair.*a/
          equipment=self.find(p.to_s.chop+'b')[0]
          address=self.find(p.to_s.chop+'b')[1]
        else
          equipment=self.find(p)[0]
          address=self.find(p)[1]
        end
d205 7
a211 7
    @@topology.each{|m| 
      i=m.scan(/(router[0-9]+) /).sort.shift.to_s.scan(/([0-9]+)/).to_s.to_i
      if line[i] != nil then
        line[i]=line[i].to_s+"\n"+m
      else
      line[i]=m
      end
d213 1
a213 1
    @@diag=@@diag+line.to_s+"\n}"
@


1.25
log
@hoge
@
text
@d1 1
a3 2
# 	$Id: vitocha.rb 1.24 2013/02/12 05:40:17 tss Exp tss $
# T.Suzuki
d5 27
a31 1
# usage
d47 1
a156 1
    # generate a code for nwdiag
@


1.24
log
@hoge
@
text
@d3 1
a3 1
# 	$Id: vitocha.rb 1.23 2013/02/12 05:39:29 tss Exp tss $
d103 1
a103 1
    eval("$#{obj}.assignip('#{epair}','#{ip6}','#{prefixlen}')")
@


1.23
log
@hoge
@
text
@d3 1
a3 1
# 	$Id: vitocha.rb 1.22 2013/02/12 05:38:08 tss Exp tss $
d107 1
a107 1
    puts "#{epair} of #{obj} has #{ip}/#{prefixlen}."
@


1.22
log
@assignip6(obj,epair,ip,prefixlen,as="") to assignip6(obj,epair,ip6,prefixlen,as="")
@
text
@d3 1
a3 1
# 	$Id: vitocha.rb 1.21 2013/01/20 13:57:18 tss Exp tss $
d106 1
a106 1
    @@daicho[epair.to_sym]=[obj,ip,mask,as,ip6,prefixlen]
@


1.21
log
@rename
@
text
@d3 1
a3 1
# 	$Id: vitocha.rb 1.20 2013/01/20 13:30:13 tss Exp tss $
d103 1
a103 1
    eval("$#{obj}.assignip('#{epair}','#{ip}','#{prefixlen}')")
@


1.20
log
@man to usage
@
text
@d1 3
a3 3
# CONVIVIT
#  - CONstruction kit for VIMAGE jail with VIrtual Tomocha -
# 	$Id: convivit.rb 1.19 2013/01/20 13:03:18 tss Exp tss $
@


1.19
log
@give default as in assignip
@
text
@d3 1
a3 1
# 	$Id: convivit.rb 1.18 2013/01/20 12:58:31 tss Exp tss $
d6 1
a6 1
# man
@


1.18
log
@hoge
@
text
@d3 1
a3 1
# 	$Id: convivit.rb 1.17 2013/01/20 07:38:52 tss Exp tss $
d94 1
a94 1
  def assignip(obj,epair,ip,mask,as)
d102 1
a102 1
  def assignip6(obj,epair,ip6,prefixlen,as)
@


1.17
log
@rm shbang
@
text
@d1 3
a3 2
# Internet Builder Tomocha Class
# 	$Id: operator.rb 1.16 2013/01/20 06:25:55 tss Exp tss $
a5 1

d23 7
d61 1
a61 1
  def register(epair,jailname,ip4,mask,as="",ip6="",prefixlen="")
@


1.16
log
@give default to ipv6
@
text
@a0 1
#!/usr/local/bin/ruby
d2 1
a2 1
# 	$Id: operator.rb 1.15 2013/01/20 06:18:55 tss Exp tss $
@


1.15
log
@add ipv6
@
text
@d3 1
a3 1
# 	$Id: operator.rb 1.14 2013/01/13 08:29:29 root Exp root $
d55 1
a55 1
  def register(epair,jailname,ip4,mask,as,ip6,prefixlen)
@


1.14
log
@registing AS in assignip
@
text
@d3 1
a3 1
# 	$Id: operator.rb 1.13 2013/01/13 08:24:55 root Exp root $
d18 2
a19 1
# operator.assignip(obj,epair,ip,mask) : set ip address
d42 1
a42 1
    return num
d55 2
a56 2
  def register(epair,jailname,ip,mask,as)
    @@daicho[epair.to_sym]=[jailname,ip,mask,as]
d90 3
a92 1
    @@daicho[epair.to_sym]=[obj,ip,mask,as]
d96 8
@


1.13
log
@add AS in register
@
text
@d3 1
a3 1
# 	$Id: operator.rb 1.12 2012/11/10 07:36:19 root Exp root $
d11 1
a11 1
# operator.register(epair,jainame) : resgister "epair is in jailname" on @@daicho
d87 1
a87 1
  def assignip(obj,epair,ip,mask)
d89 1
a89 1
    @@daicho[epair.to_sym]=[obj,ip,mask]
@


1.12
log
@sort nwdiag data
@
text
@d3 1
a3 1
# 	$Id: operator.rb 1.11 2012/11/09 15:56:26 root Exp root $
d54 2
a55 2
  def register(epair,jailname,ip,mask)
    @@daicho[epair.to_sym]=[jailname,ip,mask]
d136 8
a143 1
          @@topology=@@topology+"network {"+self.find(epair)[0]+' [address = "'+self.find(epair)[1]+'"]; '+self.find(epair.to_s.chop+'b')[0]+' [address = "'+self.find(epair.to_s.chop+'b')[1]+'"]; }'+"\n"
d157 4
a160 1
        @@topology=@@topology+' '+equipment+' [address = "'+address+'"'+"]; "
@


1.11
log
@modify nwdiag
@
text
@d3 1
a3 1
# 	$Id: operator.rb 1.10 2012/11/09 15:24:13 root Exp root $
d116 1
d136 1
a136 1
          @@diag=@@diag+"network {"+self.find(epair)[0]+' [address = "'+self.find(epair)[1]+'"]; '+self.find(epair.to_s.chop+'b')[0]+' [address = "'+self.find(epair.to_s.chop+'b')[1]+'"]; '+"\n"
d141 1
a141 1
      @@diag=@@diag+"network #{b} {"
d150 1
a150 1
        @@diag=@@diag+' '+equipment+' [address = "'+address+'"'+"]; "
d152 1
a152 1
    @@diag=@@diag+"}\n"
d154 10
a163 1
    @@diag=@@diag+"\n}"
@


1.10
log
@add nwdiag
@
text
@d3 1
a3 1
# 	$Id: operator.rb,v 1.9 2012/11/07 14:50:54 root Exp root $
d114 1
d135 1
a135 1
          @@diag=@@diag+"\n"+self.find(epair)[0]+' -- '+self.find(epair.to_s.chop+'b')[0]
d140 1
a140 1
      @@diag=@@diag+"\n network #{b} {\n"
d149 1
a149 1
        @@diag=@@diag+' '+equipment+' [address = "'+address+'"'+"];\n"
d151 1
a151 1
    @@diag=@@diag+" \n}"
@


1.9
log
@add start
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.8 2012/11/06 02:09:16 root Exp root $
d8 14
a21 14
# tomocha=Tomocha.new
# tomocha.createpair : create epair
# tomocha.destroypair : destroy epair
# tomocha.register(epair,jainame) : resgister "epair is in jailname" on @@daicho
# tomocha.unregister(epair) : unregister from @@daicho
# tomocha.find(epair) : get the jailname which the epair is in
# tomocha.epairnum : get the number of most recent epair
# tomocha.setuprouter(jailname) : create router instance
# tomocha.setupbridge(jailname) : create bridge instance
# tomocha.setupserver# (jailname) : create server instance
# tomocha.assignip(obj,epair,ip,mask) : set ip address
# tomocha.assigngw(obj,gw) : set default gateway (only for server)
# tomocha.up(obj,epair) : ifconfig up
# tomocha.down(obj,epair) : ifconfig down
d23 1
a23 1
class Tomocha
d46 1
d48 1
a48 1
      ifconfig("#{epair} destroy")
d50 2
d54 2
a55 2
  def register(epair,jailname)
    @@daicho["#{epair}"]=jailname
d59 1
a59 1
    @@daicho.delete("#{epair}")
d63 1
a63 1
    return @@daicho["#{epair}"]
d83 1
d89 1
d95 1
d100 1
d105 1
d110 44
d157 1
@


1.8
log
@add man
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.7 2012/11/06 01:46:11 root Exp root $
d19 1
a19 1
# tomocha.assigngw(obj,gw) : set default gateway
d29 1
d65 1
d70 1
d75 1
d80 1
d85 1
d100 4
@


1.7
log
@set MAC address
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.6 2012/11/02 08:24:48 root Exp root $
d9 4
a12 3
# tomocha.createpair 
# tomocha.register(epair,jainame) : resgister "epair is in jailname"
# tomocha.unregister(epair)
d15 7
d90 4
@


1.6
log
@setupserver etc
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.5 2012/11/02 07:07:47 root Exp root $
d29 2
d74 4
@


1.5
log
@hoge
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.4 2012/11/01 14:03:57 root Exp root $
d53 9
a61 1
      eval("#{jailname}=Router.new(jailname)")
d65 1
a65 1
    eval("#{obj}.connect(epair)")
d69 1
a69 1
    eval("#{obj}.assignip(epair,ip,mask)")
d73 1
a73 1
    eval("#{obj}.up(epair)")
@


1.4
log
@return num in createpair
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.3 2012/10/30 13:55:08 root Exp root $
d52 16
@


1.3
log
@rename where to find.
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.2 2012/10/28 08:20:17 root Exp root $
d30 1
@


1.2
log
@modify createpair
@
text
@d3 1
a3 1
# 	$Id: tomocha.rb,v 1.1 2012/10/28 08:11:11 root Exp root $
d8 6
d27 1
a27 1
      num=ifconfig("epair create").to_s.scan(/epair[\d]+a/).to_s.to_i
d47 1
a47 1
  def where(epair)
@


1.1
log
@Initial revision
@
text
@d3 1
a3 1
# 	$Id$
d13 1
a13 5
    num=0
    sh=Shell.new
    sh.transact{
      num=ifconfig_org.grep(/epair.a/).size
    }
d19 1
a19 1
    num=0
d21 1
a21 1
      num=ifconfig("epair create").scan(/epair[\d]+a/)
@
