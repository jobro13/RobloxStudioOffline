local target = "209.15.211.168"
local port = 80

local socket = require "socket"

local agent = require "httpagent"

local server = socket.tcp()
local x, err = server:bind("127.0.0.1", port)
print(x,err)
server:listen()

while true do
	local conn = server:accept()
	local my = agent.checkrequest(conn)
	print("connection")
	if my then
		print(my)
		local file = agent.download(target, my)
		if file then 
			conn:send(file) -- huehuehue take that bitch
		end
	end
end
