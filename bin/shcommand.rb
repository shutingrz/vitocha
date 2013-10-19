# VITOCHA Shell Commands
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
 
# 	$Id: shcommand.rb,v 1.4 2013/02/16 06:27:13 tss Exp $	

#
# define command
#
Shell.def_system_command("ifconfig_org", path = "/sbin/ifconfig")
Shell.def_system_command("mount", path = "/sbin/mount")
Shell.def_system_command("umount", path = "/sbin/umount")
Shell.def_system_command("mount_nullfs", path = "/sbin/mount_nullfs")
Shell.def_system_command("sysctl", path = "/sbin/sysctl")
Shell.def_system_command("jail", path = "/usr/sbin/jail")
Shell.def_system_command("jls", path = "/usr/sbin/jls")
Shell.def_system_command("jexec_org", path = "/usr/sbin/jexec")

#
# primitive commands
#
def ifconfig(param)
  sh=Shell.new
  sh.transact{
    ifconfig_org(*param.split)
  }
end

def jexec(name,param)
  jexec_org(name,*param.split)
end

def ifalias(interface,ip)
    ifconfig_org("#{interface}","alias","#{ip}")
end

def jailc(name)
  jail("-c","vnet","host.hostname=#{name}","name=#{name}","path=#{$jails}/#{name}","persist")
end

def mt_devfs(path)
  mount("-t","devfs","devfs","#{$jails}/#{path}/dev")
end

def umt_devfs(path)
  umount("#{$jails}/#{path}/dev")
end

def mt_nullfs(path)
  mount_nullfs("#{$jails}/basejail","#{$jails}/#{path}/basejail")
end

def umt_nullfs(path)
  umount("#{$jails}/#{path}/basejail")
end
