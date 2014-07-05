local httpagent = {}

local hosts_down = {}

local hosts = {
	["209.15.211.168"] = "www.roblox.com"

}
-- wow so cool
local mydns = {
	["c0.rbxcdn.com"] = "23.65.181.91",
	["c1.rbxcdn.com"] = "88.221.216.120",
	["c2.rbxcdn.com"] = "88.221.216.120",
	["c3.rbxcdn.com"] = "88.221.216.120",
	["c4.rbxcdn.com"] = "23.65.181.91",
	["c5.rbxcdn.com"] = "23.65.181.91",
	["c6.rbxcdn.com"] = "23.65.181.91",
	["c7.rbxcdn.com"] = "88.221.216.120"
}

local socket = require "socket"
local lfs = require "lfs"

-- Checks request on socket
function httpagent.checkrequest(socket)
	local fline = socket:receive()
	local get = fline:match("GET (.*) HTTP/%d%.%d")
	local host 
	local this 
	repeat 
		this = socket:receive()
		if this then 
			host = this:match("Host: (.*)")
		end 
	until not this or host 
		
	if get then 
		return get, host 
	end
	return false 
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

function httpagent.download(host, page, additional_header, ignore)
	if hosts_down[host] and os.time() - hosts_down[host] > 600 then 
		return httpagent.getlocalcache(host,page)
	else 
		hosts_down[host] = nil -- try again after 10 mins
	end
	local new = socket.tcp()
	new:settimeout(2)
	local ack, err = new:connect(mydns[host] or host, 80)
	new:settimeout(2)

	if new then 
		new:send("GET "..page.." HTTP/1.1\r\n")

		new:send("User-Agent: RobloxStudio\r\n") -- lies!
		new:send("Connection: close\r\n")
		new:send("Accept-Encoding: gzip\r\n")
		new:send("Accept-Language: *\r\n")
		new:send("Host: ".. (hosts[host] or host) .. "\r\n")
		if additional_header then 
			new:send(additional_header)
		end
		new:send("\r\n")

		local buff = ""
		local ret = new:receive("*a")
		if not ret then 
			return nil
		end
		buff = buff .. ret 
		local status = ret:match("HTTP/%d%.%d (%d+)") 
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

		if content:match("<a href=\"([^\"]*)\"") and content:match("<a href=\"([^\"]*)\""):match("rbxcdn") then 
			local url = (content:match("<a href=\"([^\"]*)\"") )
			print("->")
			print(url)
			local host, uri = url:match("http://([^/]*)(/.*)")
			print(host, uri)
			local body = httpagent.download(host, uri, nil, true)
			content=body
		end

		--print(content)
		if content and content:len() > 0 and not ignore then

			httpagent.setlocalcache(host,page,content)
		end

		return content
	else 
		hosts_down[host] = os.time()
		return httpagent.getlocalcache(host,page)
	end
end

function httpagent.addrule(pmatch, ovfunc)

end

function httpagent.response(content)

end

return httpagent