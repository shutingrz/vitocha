#
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

# 	$Id: vitocha.rb 1.29 2013/11/23 17:29:36 guest Exp guest $

# Usage
# operator=Operator.new
# operator.createpair : create epair
# operator.destroypair : destroy epair
# operator.register(epair,jainame,ip,mask.as) : resgister "epair is in jailname" on @daicho
# operator.unregister(epair) : unregister from @daicho
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
    @daicho=Hash.new
    num=nil
    @epairnum=num
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
    @epairnum=num
    return "epair#{num}a","epair#{num}b",num
  end

  def destroypair(epair)
    sh=Shell.new
    if epair=~/epair[0-9]+[ab]/ then epair!chop end
    sh.transact{
      ifconfig("#{epair}a destroy")
    }
    @daicho.delete("#{epair}a".to_sym)
    @daicho.delete("#{epair}b".to_sym)
  end

  def register(epair,jailname,ip4="",mask="",as="",ip6="",prefixlen="")
    @daicho[epair.to_sym]=[jailname,ip4,mask,as,ip6,prefixlen]
  end

  def unregister(epair)
    @daicho.delete(epair.to_sym)
  end

  def find(epair)
    return @daicho[epair.to_sym]
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
    @daicho[epair.to_sym]=[obj,"",""]
    puts "#{epair} is connected to #{obj}"
  end

  def assignip(obj,epair,ip,mask,as="")
    eval("$#{obj}.assignip('#{epair}','#{ip}','#{mask}')")
    ip6=self.find(epair)[4]
    prefixlen=self.find(epair)[5]
    @daicho[epair.to_sym]=[obj,ip,mask,as,ip6,prefixlen]
    puts "#{epair} of #{obj} has #{ip}/#{mask}."
  end

  def assignip6(obj,epair,ip6,prefixlen,as="")
    eval("$#{obj}.assignip6('#{epair}','#{ip6}','#{prefixlen}')")
    ip4=self.find(epair)[1]
    mask=self.find(epair)[2]
    @daicho[epair.to_sym]=[obj,ip4,mask,as,ip6,prefixlen]
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
    @diag="nwdiag {\n"
    @topology=""
    bridge=Hash.new
    @daicho.each_pair{|epair,data|
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
          @topology=@topology+"network {"+self.find(epair)[0]+' [address = "'+self.find(epair)[1]+'"'+fig1+']; '+self.find(epair.to_s.chop+'b')[0]+' [address = "'+self.find(epair.to_s.chop+'b')[1]+'"'+fig2+']; }'+"\n"
        end
      end
    }
    bridge.each_pair{|b,pairs|
      @topology=@topology+"network #{b} {"
      pairs.each{|p|
        equipment=@daicho[p][0]
        address=@daicho[p][1]
        fig=""
        fig=',shape="cisco.router"' if equipment =~ /router/
        fig=',shape="cisco.standard_host"' if equipment =~ /server/
        @topology=@topology+' '+equipment+' [address = "'+address+'"'+fig+"]; "
      }
    @topology=@topology+"}\n"
    }
    line=[]
    @topology.each_line{|m| 
	i=m.scan(/(router[0-9]+) /).sort.shift[0].scan(/([0-9]+)/)[0][0].to_i
        if line[i] != nil then
          line[i]=line[i].to_s+"\n"+m
        else
          line[i]=m
        end
    }
    @diag=@diag+line.join($,)+"\n}"
    return @diag
  end

  def genhtml
    equipments=Hash.new
    list=Array.new
    @daicho.each{|p,data| equipments[data[0]]=data}
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
