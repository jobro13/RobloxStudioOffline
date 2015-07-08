local httpagent = {}

--manuel set to serve cache?
httpagent.cachemode=false

httpagent.downtime_recheck = 600;
-- ^ after how many seconds do we retry connecting to host?
-- default is 10 minutes.

-- default socket timeout time;
-- make this higher on less reliable networks
httpagent.socket_timeout = 0.5

-- max headers for download
-- only to make sure non-http request dont exhaust copas over time
httpagent.max_headers = 1000


require "socket"

local copas = require "copas"
local color = require "color"
local lfs = require "lfs"
if not _G.__skipdns then 
print("Disable all roblox hosts in your hosts file, so you can surf to roblox normally, without entering the raw IP adress")
print("This is necessary, because we need to update the DNS cache here")
print("Press a key when done")
io.read()

hosts_down = {}
mydns = {
	["c0.rbxcdn.com"] = "23.65.181.91",
	["c1.rbxcdn.com"] = "88.221.216.120",
	["c2.rbxcdn.com"] = "88.221.216.120",
	["c3.rbxcdn.com"] = "88.221.216.120",
	["c4.rbxcdn.com"] = "23.65.181.91",
	["c5.rbxcdn.com"] = "23.65.181.91",
	["c6.rbxcdn.com"] = "23.65.181.91",
	["c7.rbxcdn.com"] = "88.221.216.120",
	["setup.roblox.com"] = "54.231.1.160",
	["ajax.aspnetcdn.com"] = "68.232.34.200",
	["js.rbxcdn.com"] = "23.65.181.74",
	["t7.rbxcdn.com"] = "88.221.216.41",
--	["logging.service.roblox.com"] = "54.225.220.196",
	["t0.rbxcdn.com"] = "88.221.216.98",
	["t1.rbxcdn.com"] = "88.221.216.41",
	["t2.rbxcdn.com"] = "95.101.0.50",
	["t3.rbxcdn.com"] = "95.101.0.50",
	["t4.rbxcdn.com"] = "95.101.0.34",
	["t5.rbxcdn.com"] = "95.101.0.34",
	["t6.rbxcdn.com"] = "95.101.0.34",
	["www.roblox.com"] = "209.15.211.168";
	["roblox.com"] = "";
	["js.rbxcdn.com"] = "";
	["api.roblox.com"] = "";
	["clientsettings.api.roblox.com"] = "";
	["wiki.roblox.com"] = "";
	["ecsv2.roblox.com"] = "";
	["ephemeralcounters.api.roblox.com"] = "";
	["images.rbxcdn.com"] = "";
}
print("doing dns queries")


for i,v in pairs(mydns) do
	mydns[i] = socket.dns.toip(i)
	if mydns[i] == nil then
		print(color("%{red}error dns " .. i))
		os.exit()
	end
	print(color(i .. " -> %{yellow}" .. mydns[i]))
end 

print(color("%{green bold}Done. To cache redirect all hosts to localhost. This program wont work if you dont do this!"))
else 
	print("not setting up dns - cache mode unavailable, unset _G.__skipdns to fix")
end
-- Check http request

function httpagent.checkrequest(socket)
	socket:settimeout(httpagent.socket_timeout)
	local fline = copas.receive(socket)
	if fline then
		local url = fline:match("%w+ (.*) HTTP/%d%.%d")
		local received = "" .. fline .. "\r\n";
		local host, this;
		repeat 
			this = copas.receive(socket)
			if this then
				host = host or this:match("Host: (.*)")
				received = received .. this .. "\r\n"
				if this == "" then 
					break 
				end
			end 
		until false
		httpagent.setlocalcache("last_request", "", received)
		return url, host, received 
	end 
	return false, nil, fline
end 

-- ugly file fixer for non valid file characters

function httpagent.getfilename(host,page)
	local name = host.."_0_"..page
	local subs = {["/"] = "_001_",
	["\\"] = "_002_",
	[":"] = "_003_",
	["*"] = "_004_",
	["?"] = "_005_",
	["\""] = "_006_",
	[">"] = "_007_",
	["<"] = "_008_",
	["|"] = "_009_"
	}
	for i,v in pairs(subs) do 
		name = name:gsub(i,v)
	end
	return name 
end 

-- gets a file (content) from local cache;

function httpagent.getlocalcache(host,page)
	local file = httpagent.getfilename(host,page)
	lfs.chdir("dynamic")
	local ret 
	local open = io.open(file)
	if open then 
		ret = open:read("*a")
	end 
	lfs.chdir("..")
	if not ret then 
		lfs.chdir("static")
		local open = io.open(file)
		if open then 
			ret = open:read("*a")
		end
		lfs.chdir("..")
	end
	return ret
end

-- sets a file (with content) to local cache 

function httpagent.setlocalcache(host,page,data)
	local file = httpagent.getfilename(host,page)

	lfs.chdir("dynamic")
	lfs.touch(file)
	local fileh,err = io.open(file, "w")

	if fileh then 
		fileh:write(data)
		fileh:close()
	end
	lfs.chdir("..")
end

-- get a line from socket (raw) 
-- preservers \r and \n
function sGetLine(sock)
	-- keep reading one byte
	local buffer = ""
	while true do 
		char = copas.receive(sock, 1)
		buffer = buffer .. char 
		if char == "\n" then 
			break
		end 
	end 
	return buffer 
end 

function httpagent.download(host, page, request)
	if not host then
		print(color("%{red} no host? returning"))
		return 
	end 
	print(color("%{green}Incoming request to: %{white}" .. host .. "%{green dim} "..string.sub(page, 1, 30)))
	if httpagent.cachemode or hosts_down[host] and os.time() - hosts_down[host] < 600 then 
		return httpagent.getlocalcache(host,page)
	else 
		hosts_down[host] = nil -- try again after 10 mins
	end
	local new = socket.tcp()
	new:settimeout(httpagent.socket_timeout)
	if not mydns[host] then
		print(color("%{red}Unknown host: " .. host))
		return 
	end 
	io.write(color("\t%{yellow}Connecting..."))
	local ack, err = new:connect(mydns[host] or host,80)
	if err then
		io.write(color("\t\t%{red} ERROR: " .. err.."\n"))
	else 
		io.write(color("\t\t%{green} OK, sending request\n"))
	end 
	if ack then 
		copas.send(new, request)
		local buffer = "";
		local amount, status;
		for i = 1, httpagent.max_headers do 
			local line = sGetLine(new)
			amount = amount or line:match("^Content%-Length: (%d+)") 
			status = status or line:match("^HTTP/%d%.%d (%d+) ")
			if not line then
				print(color("\t\t\t%{red}Strange http request, abandon thread"))
				return 
			end 
			buffer = buffer .. line 
			if line == "\r\n" then 
				-- last line of http request.
				-- http body starts after this
				break 
			end 
			if i >= httpagent.max_headers then
				print(color("\t\t\t%{red}Abandoning http receive loop: too many headers"))
			end 
		end 
		if amount then
			io.write(color("\t\t\t%{blue}HTTP status: " .. tostring(status) .. " Content-Length: " .. amount .. ". Downloading..."))
			buffer = buffer .. copas.receive(new, tonumber(amount))
			io.write(color(" %{green bold}Done.\n"))
		else 
			print(color("\t\t\t%{red}Content-Length not set. Aborting. (not a http request?)"))
			return 
		end 
		httpagent.setlocalcache(host, page, buffer)
		return buffer 
	else 
		-- set host as down
		hosts_down[host] = os.time()
		return httpagent.getlocalcache(host, page)
	end 
end 

return httpagent 
