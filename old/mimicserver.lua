local copas = require "copas"

local target = "209.15.211.168"
local port = 80

local socket = require "socket"

local agent = require "httpagent"

local server = socket.tcp()
local x, err = server:bind("127.0.0.1", port)
print(x,err)
if err then
	os.exit()
end
server:listen()
server:settimeout(1)

copas.addserver(server, function(conn) 

--[[for i = 56000, 58000 do 
	agent.download(target, "//game/join.ashx?UserID=0&serverPort="..i)
	print(i)
end 
os.exit()--]]


	local conn=conn
--	print('wait',conn)

	if conn then 
	local my, targ,buffer = agent.checkrequest(conn)
	--print(targ, my)
	--print(my, targ,1)
--	print("connection", my, targ)
	if my then
		--print(my)
		local to = targ
		if targ ~= "www.roblox.com" then 
--			print("NEWTARG!!!!")
			to=targ
		end 
--		print(targ, my)
		local file = agent.download(to, my, buffer)
		if file then 
			copas.send(conn, file) -- huehuehue take that bitch
		end
	end
	end
	conn:close()

end)

copas.loop()
