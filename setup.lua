_G.__skipdns=true
local agent = require "httpagent"
require "socket"
require "socket.http"
local target = socket.dns.toip("www.roblox.com")
print("roblox ip: " .. target)
if target == "127.0.0.1" then
	error("roblox is redirected to localhost; fix in hosts")
end 

-- be nice on roblox servers
local waittime = 1; 
local ports, porte = 56000,58000 
for port = ports, porte do
	local url = "http://www.roblox.com//game/join.ashx?UserID=0&serverPort="..port.."&universeId=0"
	local body = socket.http.request(url)
	agent.setlocalcache("www.roblox.com","//game/join.ashx?UserID=0&serverPort="..port.."&universeId=0",body)
	--socket.select(nil,nil,waittime)
	print(porte-port .. " remaining")
end 