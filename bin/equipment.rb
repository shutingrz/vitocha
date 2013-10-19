# VITOCHA Equipment Class
#    Equipment class has Server, Router and Bridge child class.
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

# 	$Id: equipment.rb,v 1.12 2013/02/16 06:33:30 tss Exp $

class Equipment

  def initialize(jailname)
    @name=jailname
    @epairs=[]
    sh=Shell.new
    sh.transact{
      if jls("host.hostname").to_a.index("#{jailname}\n")==nil
        jailc(jailname)
        mt_devfs(jailname)
        mt_nullfs(jailname)
        jexec(jailname,"ifconfig lo0 127.0.0.1/24 up")
        jexec(jailname,"ipfw add allow ip from any to any")
      end
    }
  end

  def destroy
    puts "destroy #{@name}"
    jname=@name 
    sh=Shell.new
    sh.transact{
      ifnames=jexec(jname,"ifconfig -l").to_s.split(" ")
      epairs=ifnames.select{|item| item =~ /epair.*/}
      puts epairs
      epairs.each{|epair| 
        ifconfig("#{epair} -vnet #{jname}")
        ifconfig("#{epair} destroy")
      }
      bridges=ifnames.select{|item| item =~ /vbridge.*/}
      puts bridges
      bridges.each{|bridge|
        ifconfig("#{bridge} -vnet #{jname}")
        ifconfig("#{bridge} destroy")
      }
      puts "do umount_nullfs #{jname}"
      umt_nullfs(jname)
      puts "done umount_nullfs #{jname}"
      jail("-r",jname)
      puts "do umount_devfs #{jname}"
      umt_devfs(jname)
      puts "done umount_devfs #{jname}"
     }
  end

  def connect(epair)
    name=@name 
    sh=Shell.new
    sh.transact{
      ifconfig("#{epair} vnet #{name}")
    }
  end

  def disconnect(epair)
    name=@name 
    sh=Shell.new
    sh.transact{
      ifconfig("#{epair} -vnet #{name}")
    }
  end

  def assignip(epair,ip,mask)
    name=@name 
    sh=Shell.new
    sh.transact{
      jexec(name,"ifconfig #{epair} inet #{ip} netmask #{mask}")
    }
  end

  def assignip6(epair,ip,prefixlen)
    name=@name 
    sh=Shell.new
    sh.transact{
      jexec(name,"ifconfig #{epair} inet6 #{ip}/#{prefixlen}")
    }
  end

  def up(epair)
    name=@name 
    sh=Shell.new
    sh.transact{
      jexec(name,"ifconfig #{epair} up")
    }
  end

  def down(epair)
    name=@name 
    sh=Shell.new
    sh.transact{
      jexec(name,"ifconfig #{epair} down")
    }
  end

  def start(program)
    name=@name
    sh=Shell.new
    sh.transact{
      jexec(name,"/usr/local/etc/rc.d/#{program} start")
    }
  end

  attr_accessor :epairs
end
