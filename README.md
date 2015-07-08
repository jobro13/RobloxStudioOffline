Roblox offline usage 
====================

WARNING.
THIS PROGRAM WILL DUMP ALL TRAFFIC TO ROBLOX.COM AND THEIR CONTENT SERVERS TO A LOCAL DIRECTORY. IF YOU ARE LOGGED IN, THIS MAY ALSO MEAN THAT YOUR AUTHENTICATION COOKIES OR OTHER VULNERABLE INFORMATION IS RETRIEVED. 
TO PLAY SAFE: LOG OUT BEFORE YOU SET THIS UP.

Instructions:

Use lua version 5.1.

*	Run install.lua for an interactive way of setting this up.

* Check if you have lfs and luasocket installed. (also checked in install.lua)
* Append hosts.txt to your hosts file. /etc/hosts on unix, /system32/drivers/etc/hosts on windows
* Run setup.lua to download game server scripts for ports 56k - 58k to the cache. This takes a while.
* Run mimicserver.lua in admin mode. You will be prompted to disable the hosts file - this is done by default (the # disables the line which redirects all roblox hosts to localhost). 
* This will setup the DNS cache of the lua script.
* Once done and ready, uncomment the line in the hosts file (make sure to save).
* Now open roblox studio. Every request to roblox.com and other data servers of roblox are now dumped on your system. In case of you being offline, either temporary or semi-permanent, it will fall back on the local cache.
* This might take long! There are some bugs (?) which makes roblox sleep for a minute before going on. Just wait paitently.
* Now do everything you want to do offline: play solo, start a game server, start a player.
* Once done, quit roblox studio and unplug your internet. Now open roblox studio. Normally, this will give you a bugged studio which cannot be used to play solo or start servers. However, with the local cache, this will work!




How does it work?
=================

It's very simple. Mimicserver acts like a man in the middle between roblox and the internet. If a connection is present, it will serve the current content and the local cache is updated. If no connection is present for any reason, it will try to retrieve the file from the local cache, serving that.

Note that this is basically a big ugly hack. If roblox uses any other request type than http then this will not work. The same goes with timestamped files. For now, it works.

Disclaimer 
==========

Use this software at your own risk.