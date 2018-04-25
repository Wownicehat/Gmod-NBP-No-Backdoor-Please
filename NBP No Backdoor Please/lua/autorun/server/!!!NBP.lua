print("Starting NBP")
local NBP = {}

-- Backdoor batabase for spoofing and RunString detection
NBP.Strings = {
		"UKT_MOMOS", "Sandbox_ArmDupe", "Fix_Keypads", "memeDoor",
		"Remove_Exploiters", "noclipcloakaesp_chat_text", "fellosnake", "NoNerks",
		"BackDoor", "kek", "OdiumBackDoor", "cucked", "ULogs_Info", "Ulib_Message",
		"m9k_addons", "Sbox_itemstore", "rcivluz", "Sbox_darkrp", "_Defqon", "something",
		"random", "strip0", "killserver", "DefqonBackdoor", "fuckserver", "cvaraccess",
		"rconadmin", "_CAC_ReadMemory", "nostrip", "DarkRP_AdminWeapons",
		"enablevac", "SessionBackdoor", "LickMeOut", "MoonMan", "Im_SOCool", "fix",
		"idk", "ULXQUERY2", "ULX_QUERY2", "jesuslebg", "zilnix", "ÃžÃ ?D)â—˜",
		"disablebackdoor", "oldNetReadData", "SENDTEST", "Sandbox_GayParty",
		"nocheat", "_clientcvars", "_main", "ZimbaBackDoor", "stream", "waoz", "DarkRP_UTF8",
		"bdsm", "ZernaxBackdoor", "anticrash", "audisquad_lua", "dontforget", "noprop", "thereaper",
		"0x13"
}

hook.Add("NBP_Message", "LogToFile", function(msg)
	file.Append("NBP_logs.txt", string.format("[NBP] %f : "..msg.."\n", CurTime()))
end)

-- Broacast message to all player
NBP.Broadcast = function(msg, ...)
	msg = string.format(msg, ...)
	hook.Run("NBP_Message", msg)
	for i,v in ipairs(player.GetHumans()) do
		v:ChatPrint(msg)
	end
	print(msg)
end


-- For LUA script detection
NBP.LuaStrings = {
	"player.GetAll()", "player.GetHumans()", "RunString", "CompileString",
	"hook.Add", "hook.Remove", "ulx groupallow user \"ulx luarun\"",
	"game.ConsoleCommand", "RunConsoleCommand", "while.+%do", "if.+%then",
	"http.Fetch", "http.Post",
	"net.Receive", "util.AddNetworkString"
}

-- Detecte if "includes/extensions/net.lua" is in the call stack
NBP.IsNet = function()
	for i=1,10 do
		local x = debug.getinfo(i)
		if x then
			if string.find(x.source, "includes/extensions/net.lua") then
				return true, i
			end
		end
	end
	return false
end




hook.Add("NBP_banning_hacker", "LogToFile", function(ply)
	file.Append("NBP_skids.txt", "[NBP] "..CurTime().." : Banning "..ply:Nick().."("..ply:SteamID().."{"..ply:IPAddress().."}) for trying to backdoor the server\n")
end)

-- For backdoor spoofing
NBP.Ban = function(l, ply)
	NBP.Broadcast("%s attempted to hack the server, banning him. . .", ply:Nick().."("..ply:SteamID().."{"..ply:IPAddress().."})")
	hook.Run("NBP_banning_hacker", ply)
	ply:Ban(0, false)
	ply:Kick("Attempted to hack the server")
end 

-- To be overwrote in net.ReadString
NBP.LastReadString = ""


--[[
Function: NBP.CheckRunningString
Parameter: str (lua code), name (compilation name), thing (HandleError)
]]
NBP.CheckRunningString = function( str, name, thing )
	-- F*ck ulx luarun [BACKDOOR]
	if string.find(str, "util.AddNetworkString") then
		NBP.Broadcast("Someone attempted to add a network string (probably backdoor)")
		return false
	end
	if string.find(str, "net.Receive") then
		NBP.Broadcast("Someone attempted to add a network receiver (probably backdoor)")
		return false
	end
	for i,v in pairs(NBP.Strings) do
		if (type(v) == type("")) and string.find(str, v) then
			NBP.Broadcast("Someone attempted to run lua code including backdoor name (%s)", v)
			return false
		end
	end
	local fromnet, sp = NBP.IsNet()
	if fromnet then -- Can't be good
		NBP.Broadcast("/!\\ Attempted to run dynamique code from net (SP: %x)", sp)
		return false
	end

	if NBP.LastReadString == str then
		NBP.Broadcast("Blocked code execution from net")
		return false
	end
	if (name == "[C]") and (thing) then
		NBP.Broadcast("Blocked backdoor")
		return false
	end
	return true
end

NBP.RunString = RunString
function RunString( str, name, thing )
	if NBP.CheckRunningString(str, name, thing) then
		return NBP.RunString(str, name, thing)
	end
end

NBP.CompileString = CompileString
function CompileString( str, name, thing )
	if NBP.CheckRunningString(str, name, thing) then
		return NBP.CompileString(str, name, thing)
	end
	return function(...) end
end

RunStringEx = RunString -- They are the same

----------------- GBackdoor interception
NBP.httpFetch = http.Fetch
function http.Fetch( url, os, orr )
	if string.find(url, "/core/stage1.php") then return end
	NBP.httpFetch(url, os, orr)
end

NBP.httpPost = http.Post
function http.Post( url, param, os, orr )
	if string.find(url, "/core/stage2.php") then return end
	NBP.httpPost(url, param, os, orr)
end
-----------------

NBP.ReadString = net.ReadString
function net.ReadString()
	local read = NBP.ReadString()
	for i,v in ipairs(NBP.LuaStrings) do
		if (type(v) == type("")) and string.match(read, v) then
			NBP.Broadcast("/!\\ Attempted to transmite code tought net")
			return [[print("oh no :(")]]
		end
	end
	NBP.LastReadString = read
	return read
end

NBP.Spoofed = NBP.Strings
-- Self explanatorie
timer.Create("NBP_RemoveAndSpoof", 2, 0, function()
	for i,v in pairs(NBP.Strings) do
		if net.Receivers[v] then
			net.Receive(v, ban)
		end
		if (not NBP.Spoofed[v]) and (type(v) == type("")) then
			util.AddNetworkString(v)
			net.Receive(v, ban)     -- Spoof
			NBP.Spoofed[v] = true
		end
	end
end)

concommand.Add("NBP_Check",function(p)
	p:ChatPrint("MBP v1.1 is present, don't try to backdoor this server :)")
end)

print("NBP OK !")
print("MBP || No Backdoor Please | By John | Discord : John-Doesent#0716")
