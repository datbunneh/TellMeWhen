-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>
-- Major updates by
-- Oozebull of Twisting Nether
-- Banjankri of Blackrock 
-- Cybeloras of Mal'Ganis
-- --------------------


if not TMW then return end
local TMW = TMW

local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
local popupFrame = CreateFrame("Frame", "TellMeWhenLaunchermenu", UIParent, "UIDropDownmenuTemplate")
TMW.LDBMenu = {}

local function Update()
	CloseDropDownMenus()
	TMW.LDBMenu = wipe(TMW.LDBMenu)
	for i = 1,TELLMEWHEN_MAXGROUPS do
		local tmp = {
			text = L["COPYPANEL_GROUP"] .. i,
			tooltipTitle = L["COPYPANEL_GROUP"] .. i,
			tooltipText = L["COPYPANEL_GROUP"] .. i,
			disabled = false,
			notCheckable = true,
			tooltipOnButton = true,
			hasArrow = true,
			menuList = {
				{
					text = L["UIPANEL_ENABLEGROUP"],
					checked = TellMeWhen_GetGroupSetting(i,"Enabled"),
					tooltipTitle = L["UIPANEL_ENABLEGROUP"],
					tooltipText = L["UIPANEL_TOOLTIP_ENABLEGROUP"],
					tooltipOnButton = true,
					func = function()
						TellMeWhen_Settings.Groups[i].Enabled = not TellMeWhen_Settings.Groups[i].Enabled
						TellMeWhen_Group_Update(i)
						Update()
					end,
				},
				{
					text = L["UIPANEL_PRIMARYSPEC"],
					checked = TellMeWhen_GetGroupSetting(i,"PrimarySpec"),
					tooltipTitle = L["UIPANEL_PRIMARYSPEC"],
					tooltipText = L["UIPANEL_TOOLTIP_PRIMARYSPEC"],
					tooltipOnButton = true,
					func = function()
						TellMeWhen_Settings.Groups[i].PrimarySpec = not TellMeWhen_Settings.Groups[i].PrimarySpec
						TellMeWhen_Group_Update(i)
						Update()
					end,
				},
				{
					text = L["UIPANEL_SECONDARYSPEC"],
					checked = TellMeWhen_GetGroupSetting(i,"SecondarySpec"),
					tooltipTitle = L["UIPANEL_SECONDARYSPEC"],
					tooltipText = L["UIPANEL_TOOLTIP_SECONDARYSPEC"],
					tooltipOnButton = true,
					func = function()
						TellMeWhen_Settings.Groups[i].SecondarySpec = not TellMeWhen_Settings.Groups[i].SecondarySpec
						TellMeWhen_Group_Update(i)
						Update()
					end,
				},
				{
					text = L["UIPANEL_ONLYINCOMBAT"],
					checked = TellMeWhen_GetGroupSetting(i,"OnlyInCombat"),
					tooltipTitle = L["UIPANEL_ONLYINCOMBAT"],
					tooltipText = L["UIPANEL_TOOLTIP_ONLYINCOMBAT"],
					tooltipOnButton = true,
					func = function()
						TellMeWhen_Settings.Groups[i].OnlyInCombat = not TellMeWhen_Settings.Groups[i].OnlyInCombat
						TellMeWhen_Group_Update(i)
						Update()
					end,
				},
			},

		}
		table.insert(TMW.LDBMenu, tmp)
	end
end

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("TellMeWhen") or
	ldb:NewDataObject("TellMeWhen", {
		type = "launcher",
		icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
	})

dataobj.OnClick = function(self, button)
	if button == "RightButton" then
		Update()
		if #TMW.LDBMenu > 0 then
			EasyMenu(TMW.LDBMenu, popupFrame, self, 20, 4, "MENU")
		end
	else
		TellMeWhen_LockToggle()
	end
end

dataobj.OnTooltipShow = function(tt)
	tt:AddLine(L["ICON_TOOLTIP1"])
	tt:AddLine(L["LDB_TOOLTIP1"])
	tt:AddLine(L["LDB_TOOLTIP2"])
end