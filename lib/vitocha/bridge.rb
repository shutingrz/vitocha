# VITOCHA Bridge Class
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

# 	$Id: bridge.rb,v 1.16 2013/02/16 06:30:17 tss Exp $

# usage
# bridge=Bridge.new(jailname) : create bridge which has a vbridge0
# bridge.on  : ifconfig vbridge0 up
# bridge.off : ifconfig vbridge0 down
# bridge.destroy : jail -r jailname in safe manner
# bridge.connect(epair) : connect epair to vbridge0
# bridge.up(epair) : ifconfig <epair> up
# bridge.down(epair) : ifconfig <epair> down
# bridge.assingip(ip,mask) : ifconfig vbridge0 inet <ip> netmask <mask>}

class Bridge < Equipment

  def initialize(jailname)
    super
    sh=Shell.new
    sh.transact{
#      if jls("host.hostname").to_a.index("#{jailname}\n")==nil
        bridgename=ifconfig("bridge create").to_s
        ifconfig("#{bridgename} vnet #{jailname}")
        # Naming "vbridge0" for the bridge interface
        jexec(jailname,"ifconfig #{bridgename} name vbridge0")
        jexec(jailname,"ifconfig vbridge0 up")
#      end
    }
  end

  def on
    sh=Shell.new
    name=@name
    sh.transact{
      jexec(name,"ifconfig vbridge0 up")
    }
  end

  def off
    sh=Shell.new
    name=@name
    sh.transact{
      jexec(name,"ifconfig vbridge0 down")
    }
  end

  def destroy
     puts "destroy #{@name}"
     jname=@name 
     sh=Shell.new
     sh.transact{
       ifnames=jexec(jname,"ifconfig -l").to_s.split(" ").select{|item| item =~ /epair.*/}
       ifnames.each{|epair| ifconfig("#{epair} -vnet #{jname}")}
       umt_nullfs(jname)
       jail("-r",jname)
       umt_devfs(jname)
     }
  end

  def connect(epair)
    name=@name 
    sh=Shell.new
    sh.transact{
      ifconfig("#{epair} vnet #{name}")
      jexec(name,"ifconfig vbridge0 addm #{epair}")
    }
    @epairs<< epair
  end

  def assignip(ip,mask)
    name=@name 
    sh=Shell.new
    sh.transact{
      jexec(name,"ifconfig vbridge0 inet #{ip} netmask #{mask}")
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

  attr_accessor :epairs
end
