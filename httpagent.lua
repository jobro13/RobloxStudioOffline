local httpagent = {}

require "socket"
local copas = require "copas"

local hosts_down = {}

local hosts = {
	--["209.15.211.168"] = "www.roblox.com"

}

io.write("disable hosts file and hit a key")
io.read()
-- wow so cool
local mydns = {
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
		error("error dns " .. i)
	end
	print(i .. " -> " .. mydns[i])
end 

io.write("enable hosts file")
io.read()

local socket = require "socket"
local lfs = require "lfs"

-- Checks request on socket
function httpagent.checkrequest(socket)
	socket:settimeout(0.5)
	local GOTCONN =false;
	local fline = copas.receive(socket)
	if fline then 
	local get = fline:match("%w+ (.*) HTTP/%d%.%d")
	local BUFFER = ""
	BUFFER =  BUFFER .. fline .. "\r\n"
	local host 
	local this 
	local skip = true
	repeat 
		this = copas.receive(socket)
		if this:match("^Connection: ") then 
			GOTCONN=true
			BUFFER = BUFFER .. "Connection: close\r\n"
		else
			BUFFER = BUFFER .. this .. "\r\n"
		end
		if this then 
			host = this:match("Host: (.*)")

		end 
		if this == "\r\n" then
			 skip=false
		end 
	until not this or host or not skip
	while true do 
	local nxt = copas.receive(socket)
	if nxt then
		if nxt:match("^Connection: ") then
		GOTCONN=true 
			BUFFER = BUFFER .. "Connection: close\r\n"
		else 
			if nxt == "" and not GOTCONN then
				BUFFER = BUFFER .. "Connection: close\r\n";
			end
			BUFFER = BUFFER .. 	(nxt or "") .. "\r\n"
		end
	end
	if nxt == "" then
		break
	end 
	end
	if get then 
		print(BUFFER:match("Connection: (%w+)"))
		httpagent.setlocalcache('test','buffer',BUFFER)
		return get, host, BUFFER
	end
end
	return false, nil, BUFFER 
end

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

-- FOR FUCKS SAKE LAUSOCKET PLS
function GETLINE(sock)
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

function httpagent.download(host, page, buffer,debug)
	if not host then
		return
	end
	print("HIT: " .. host)
	--print("host download" , host)
	if hosts_down[host] and os.time() - hosts_down[host] < 600 then 
		return httpagent.getlocalcache(host,page)
	else 
		hosts_down[host] = nil -- try again after 10 mins
	end
	local new = socket.tcp()
	new:settimeout(2)
	if not mydns[host] then
	--	print("New host: " .. tostring(host))
	end

	--print(ip, host)
	io.write('connecting..')
	local ack, err = new:connect( mydns[host] or ip or host, 80)
	io.write(' connected, ' .. tostring(ack) .. ' ' .. tostring(err) .. '\n')
	new:settimeout(2)
	--print(ack, err)
	if ack and new then 
	--[[	new:send("GET "..page.." HTTP/1.1\r\n")

		new:send("User-Agent: RobloxStudio\r\n") -- lies!
		new:send("Connection: close\r\n")
		new:send("Accept-Encoding: none\r\n")
		new:send("Accept-Language: *\r\n")
		new:send("Host: ".. (hosts[host] or host) .. "\r\n")
		if additional_header then 
			new:send(additional_header)
		end
		new:send("\r\n")--]]
		--print(buffer)
		copas.send(new, buffer)

		local buff = ""
		local amount
		local status 
		for i = 1, 1000 do
			local ret = GETLINE(new)
			io.write(ret)
			amount = amount or ret:match("^Content%-Length: (%d+)") 
			status = status or ret:match("^HTTP/%d%.%d (%d+) ")
			if not ret then 
				return nil
			end
			buff = buff ..ret 
			if ret == "\r\n" then 
				break 
			end 
			if i == 1000 then
				print("loop completed; too many headers")
			end
		end 
		print("done reading status: " .. tostring(status))
		if amount then 
			buff = buff .. copas.receive(new, tonumber(amount))
		else 
			print("err reading amount")
			return nil 
		end 	
		--local status = ret:match("HTTP/%d%.%d (%d+)") 
	--	print("HTTP STATUS: " .. tostring(status))
		--print("RECEIVING; ", ret)
		--[[if tonumber(status) == 3032 then 
			-- crap
			while ret do 
				ret = new:receive("*a") 
				if ret then 
					buff = buff .. ret
				end 
			end
			local content = buff
			local url = content:match("<a href=\"([^\"]+)\">")
			print(url)
			if url then
				local host, serv,npage = url:match("http://([^%.])%.([^%.]+%.[^/]+)(.*)")
				print(host, serv)
				if host and serv then 
					local add_header = "Host: "..host.."."..serv.."\r\n"
					return httpagent.download(serv, npage, add_header, page)
				end
			end 
		end --]]
		buff = buff 
		-- more


		
		local content = buff
		-- detect http redirects;
		--[[if tostring(status) == "302" then 
			local url = content:match("Location: ([^\r]+)")
			if not url then 
				url = (content:match("<a href=\"([^\"]*)\"") )
			end
			print("->")
			print(url)
			local host, uri = url:match("http://([^/]*)(/.*)")
			print(host, uri)
			local body = httpagent.download(host, uri)
			content=body
		end
--]]
		--print(content)
		if debug then
			--[[for i = 1, math.ceil(string.len(content)/50) do
				local start = (i-1)*50 + 1
				local ends = i * 50 + 1
				if ends > string.len(content) then
					ends = string.len(content)
				end 
				print(string.sub(content, start, ends))
			end--]] 
		end 
		if content and content:len() > 0 and not ignore then

			httpagent.setlocalcache(host,page,content)
		end

		return content
	else 
		--print("yes")
		hosts_down[host] = os.time()
		return httpagent.getlocalcache(host,page)
	end
end

function httpagent.addrule(pmatch, ovfunc)

end

function httpagent.response(content)

end

return httpagent