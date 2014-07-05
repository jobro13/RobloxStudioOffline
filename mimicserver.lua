local target = "209.15.211.168"
local port = 80

local socket = require "socket"

local agent = require "httpagent"

local server = socket.tcp()
local x, err = server:bind("127.0.0.1", port)
print(x,err)
server:listen()
server:settimeout(1)

for i = 0, 65535 do 
	agent.download(target, "//game/join.ashx?UserID=0&serverPort="..i)
	print(i)
end 
os.exit()

while true do
	local conn = server:accept()
	if conn then 
	local my, targ = agent.checkrequest(conn)
	print("connection")
	if my then
		--print(my)
		local to = target
		if targ ~= "www.roblox.com" then 
			print("NEWTARG!!!!")
			to=targ
		end 
		print(targ)
		local file = agent.download(to, my)
		if file then 
			conn:send(file) -- huehuehue take that bitch
		end
	end
	end
end
