concommand.Add("nbp_config", function()

    local function SendNewConfig( tbl )
        net.Start("NBP_SETTING_SEND")
        net.WriteTable(tbl)
        net.SendToServer()
    end

    local blur = Material("pp/blurscreen")
    local function DrawBlur(panel, amount) -- Everyone use it xD
        local x, y = panel:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        for i = 1, 3 do
            blur:SetFloat("$blur", (i / 3) * (amount or 6))
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
    end

    net.Receive("NBP_SETTING_RECEIVE", function()
        local tbl = net.ReadTable()
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 500)
        frame:Center()
        frame:ShowCloseButton(true)
        frame:SetDraggable(true)
        frame:SetTitle("NBP Config")
        frame:MakePopup()
        frame.Paint = function( s )
           DrawBlur(s, 1)
            surface.SetDrawColor( 200, 200, 255, 150 )
            surface.DrawRect( 0, 0, frame:GetWide(), frame:GetTall() )
            surface.SetDrawColor( 20, 20, 20 )
            surface.DrawOutlinedRect( 0, 0, frame:GetWide(), frame:GetTall() )
            DrawBlur(s, 1)
        end

        local chk = vgui.Create("DCheckBoxLabel", frame)
        chk:SetText("Anti Strip Wepon")
        chk:SetValue(Either(tbl.AntiStrip, 1, 0))
        chk:SetPos(10, 30)
        chk:SetTextColor(Color(0, 0, 0))
        chk.OnChange = function(s, v)
            tbl.AntiStrip = v
            SendNewConfig(tbl)
        end

        local chk = vgui.Create("DCheckBoxLabel", frame)
        chk:SetText("Anti Script Hook")
        chk:SetValue(Either(tbl.AntiScriptHook, 1, 0))
        chk:SetPos(10, 50)
        chk:SetTextColor(Color(0, 0, 0))
        chk.OnChange = function(s, v)
            tbl.AntiScriptHook = v
            SendNewConfig(tbl)
        end

        local chk = vgui.Create("DCheckBoxLabel", frame)
        chk:SetText("La Blacklist Autoreport")
        chk:SetValue(Either(tbl.LaBlacklistAutoreport, 1, 0))
        chk:SetPos(10, 70)
        chk:SetTextColor(Color(0, 0, 0))
        chk.OnChange = function(s, v)
            tbl.LaBlacklistAutoreport = v
            SendNewConfig(tbl)
        end

        local chk = vgui.Create("DCheckBoxLabel", frame)
        chk:SetText("Report Founded SteamIDs")
        chk:SetValue(Either(tbl.ReportFoundSteamIDs, 1, 0))
        chk:SetPos(10, 90)
        chk:SetTextColor(Color(0, 0, 0))
        chk.OnChange = function(s, v)
            tbl.ReportFoundSteamIDs = v
            SendNewConfig(tbl)
        end
    end)
    net.Start("NBP_SETTING_RECEIVE")
    net.SendToServer()  


end)
