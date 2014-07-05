local httpagent = {}

local hosts_down = {}

local hosts = {
	["209.15.211.168"] = "www.roblox.com"
}

local socket = require "socket"
local lfs = require "lfs"

-- Checks request on socket
function httpagent.checkrequest(socket)
	local fline = socket:receive()
	local get = fline:match("GET (.*) HTTP/%d%.%d")
	if get then 
		return get
	end
	return false 
end

function httpagent.getlocalcache(host,page)
	local file = host.."/"..page
	lfs.chdir("dynamic")
	local ret 
	local open = io.open(file)
	if open then 
		ret = open:read("*all")
	end 
	lfs.chdir("..")
	if not ret then 
		lfs.chdir("static")
		local open = io.open(file)
		if open then 
			ret = open:read("*all")
		end
		lfs.chdir("..")
	end
	return ret
end

function httpagent.setlocalcache(host,page,data)
	local file = host.."/"..page
	lfs.chdir("dynamic")
	local fileh = io.open(file, "w")
	print(fileh)
	if fileh then 
		fileh:write(data)
		print("wrote")
		fileh:close()
	end
	lfs.chdir("..")
end

function httpagent.download(host, page, additional_header, orig302page)
	if hosts_down[host] and os.time() - hosts_down[host] > 600 then 
		return httpagent.getlocalcache(host,page)
	else 
		hosts_down[host] = nil -- try again after 10 mins
	end
	local new = socket.tcp()
	new:settimeout(2)
	local ack, err = new:connect(host, 80)
	new:settimeout(2)
	print(ack, err)
	if new then 
		new:send("GET "..page.." HTTP/1.1\r\n")
		local page = orig302page or page
		new:send("User-Agent: RobloxStudio\r\n") -- lies!
		new:send("Connection: close\r\n")
		new:send("Accept-Encoding: gzip\r\n")
		new:send("Accept-Language: *\r\n")
		new:send("Host: ".. (hosts[host] or host) .. "\r\n")
		if additional_header then 
			new:send(additional_header)
		end
		new:send("\r\n")
		FILE_SCHEME = host.."/"..page
		local buff = ""
		local ret = new:receive("*a")
		if not ret then 
			return nil
		end
		buff = buff .. ret 
		local status = ret:match("HTTP/%d%.%d (%d+)") 
		print("RECEIVING; ", ret)
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
		print("Page: "..page)
		--print(content)
		if content and content:len() > 0 then
			httpagent.setlocalcache(host,page,content)
		end
		print("DONE")
		return content
	else 
		hosts_down[host] = os.time()
	end
end

function httpagent.addrule(pmatch, ovfunc)

end

function httpagent.response(content)

end

return httpagent