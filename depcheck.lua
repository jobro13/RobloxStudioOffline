local hassocket = pcall(function() require "socket" end)
local haslfs = pcall(function() require "lfs" end)
if not hassocket then 
	return false, "LuaSocket is not installed!"
end
if not haslfs then
	return false, "LuaFileSystem is not installed!"
end
return true