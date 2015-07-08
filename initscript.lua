-- Setups initial communications 

local ds = game:GetService("DataStoreService")
local rs = game:GetService("ReplicatedStorage")

function wrapfunction(func, name)
	if rs:FindFirstChild(name) then
		rs[name]:Destroy()
	end
	local new = Instance.new("RemoteFunction", rs)
	new.Name = name
	new.OnServerInvoke = func
end

function getmod(root, name)
	if root:FindFirstChild(name) then
		return root[name]
	end
	local new = Instance.new("Model", root)
	new.Name = name
	return new
end

function getbp(player)
	return getmod(getmod(getmod(rs, "LocalPlayerData"), player.userId), "Backpack")
end

function getproot(player)
	return getmod(getmod(rs, "LocalPlayerData"), player.userId)
end

function ClearBackpack(player)
	local mod = getbp(player.userId)
	mod:ClearAllChildren()
end

function getcontainer(player, what)
	return getmod(getproot(player), what)
end

function setup(player)
	local root = getbp(player)
	local proot = getproot(player)
	local app = getcontainer(player, "Appearance")
	local tools = getcontainer(player, "Tools")
	local stats = getcontainer(player, "Stats")
end

function AddBackpackItem(player, item)
	local root = getbp(player)
	if item.Parent and item.Parent:IsDescendantOf(Workspace) then
		-- kthen
		item.Parent = root
		return true
	end
	return false
end



wrapfunction(AddBackpackItem, "AddBPItem")


