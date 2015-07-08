local color = require "color"
print(color('%{green bold}Lua haxxy webcache made to use roblox studio offline'))
print(color('Follow the instructions and use roblox studio normally'))
print(color('This program will save all data received and will present it to roblox if your connection fails. You can disable this program if you have gathered enough data and re-enable it when you need it (this is recommended)'))
local copas = require "copas"
local socket = require "socket"
print(color('%{red bold}Setting up roblox HTTP bouncer..'))
local agent = require "httpagent"


local server = socket.tcp()
local ok, err = server:bind("127.0.0.1", 80)

if err then 
	print(color('%{red}'..err))
	os.exit()
end 

server:listen()
server:settimeout(1)

copas.addserver(server, function(connection) 
	if connection then 
		local url, host, received = agent.checkrequest(connection)
		if url then 
			local file = agent.download(host, url, received)
			if file then
				copas.send(connection, file)
			end 
		end 
	end
end)

print(color("%{green}All set!"))

io.write(color("{red bold}\nTo also add support for play server (which has a 'random' port assigned by the OS every time you start a server) run the file setup.lua"))

copas.loop()