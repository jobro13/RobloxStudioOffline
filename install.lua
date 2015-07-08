print("This short script will guide you through all steps to setup your system to run roblox studio offline")
print("Jobro13 is now on vacation so if stuff doesnt work please fork this with your own fixes. Thanks.")
print("I hope no bugs are found because if there are bugs found it means I cannot dev on vacation! Yay!")
print("This is all coded in Lua. While most people disagree on this, I'll just go for: it must work. And it will!")
print("Doing a dependency check ..")

local ret, err = dofile("depcheck.lua")

if not ret then
	print("Error in dependency: "..tostring(err))
	os.exit()
end

print("Setup your hosts file so that roblox.com will redirect to localhost (127.0.0.1)")
print("Why? We catch roblox requests on localhost - MAKE SURE YOU DISABLE ANY HTTP DAEMON YOU HAVE RUNNING ON LOCALHOST PORT 80")
print("We will then try to download the original assets and if that is not possible we will provide a local copy of it, or just timeout.")
print(" -------- ")
print("Warning: You cannot use DataStores or any other functionality which requires you being online.")
print("This may seem logical but think if it will work for you.")
print("Press any key to continue when you read all this.")
io.read()

print("Now edit hosts (C:/Windows/System32/etc/hosts) (Mac; /etc/hosts, need to be superuser) with your favorite text editor")
print("No, notepad is not your favorite text editor; sublime text 2 is.")
print("On mac this can be found in /etc/hosts, the command sudo nano /etc/hosts will do")
print("It could look like this: 127.0.0.1 	localhost www.roblox.com roblox.com")
print("Also add roblox cdn servers to this; c0.rbxcdn.com till c7.rbxcdn.com (all redirect to 127.0.0.1)")
print("Press any key when you are done")
io.read()

print("If you are now online, boot mimicserver.lua (sudo required on mac) and run studio. Studio will now request files")
print("These requests are caught by our mimicserver which tries to download it from the roblox servers (and create a local copy) or get its own local copy from our dynamic directory.")
print("If you are offline, run mimicserver; you should get studio up and running with limited performance")
print("Some last tricks: you can use local image files by using rbxasset://font/image for example in your content properties")

print("Press any key to quit.")
io.read()
os.exit()