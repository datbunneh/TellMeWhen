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

-- -----------------------
-- LOCALS/GLOBALS
-- -----------------------

local LSM = LibStub("LibSharedMedia-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
local _,pclass = UnitClass("Player")
local tonumber, tostring, type, pairs, tinsert = tonumber, tostring, type, pairs, tinsert 
local strfind, strmatch, format, gsub, strsub, strlower = strfind, strmatch, format, gsub, strsub, strlower
local _G = _G
local _,pclass = UnitClass("Player")
local tiptemp,conditionstemp = {},{}

TMW.TempEnabled = {}
TMW.CI = { g = 1, i = 1 }		--current icon, for dropdown menus and such
TMW.CNI = { g = 1, i = 1 }		--current name icon
TMW.CCoI = { g = 1, i = 1 }		--current copy icon
TMW.CCnI = { g = 1, i = 1 }		--current condition icon
TMW.CEI = { g = 1, i = 1 }		--current editor icon
TMW.CMI = { g = 1, i = 1 }		--current meta icon
TMW.D = {} 						--group settings to restore on icon copier hide
TMW.Flags = {
	MONOCHROME = L["OUTLINE_NO"],
	OUTLINE = L["OUTLINE_THIN"],
	THICKOUTLINE = L["OUTLINE_THICK"],
}

local oldp=print
local function print(...)
	if TMW.TestOn then
		oldp("|cffff0000TMW:|r ", ...)
	end
end

do -- STANCES
	--ADD ANY NEW STANCES THE THE >>>END<<< OF EACH CLASSES' SECTION
	--STANCES WILL NEED TO BE RESET FOR A CLASS IF THEY LOSE A STANCE

	TMW.Stances = {
		{class = "WARRIOR",		id = 2457},		-- Battle Stance
		{class = "WARRIOR",		id = 71},		-- Defensive Stance
		{class = "WARRIOR",		id = 2458},		-- Berserker Stance

		{class = "DRUID",		id = 5487},		-- Bear Form
		{class = "DRUID",		id = 768},		-- Cat Form
		{class = "DRUID",		id = 1066},		-- Aquatic Form
		{class = "DRUID",		id = 783},		-- Travel Form
		{class = "DRUID",		id = 24858},	-- Moonkin Form
		{class = "DRUID",		id = 33891},	-- Tree of Life
		{class = "DRUID",		id = 33943},	-- Flight Form
		{class = "DRUID",		id = 40120},	-- Swift Flight Form

		{class = "PRIEST",		id = 15473},	-- Shadowform

		{class = "ROGUE",		id = 1784},		-- Stealth

		{class = "HUNTER",		id = 82661},	-- Aspect of the Fox
		{class = "HUNTER",		id = 13165},	-- Aspect of the Hawk
		{class = "HUNTER",		id = 5118},		-- Aspect of the Cheetah
		{class = "HUNTER",		id = 13159},	-- Aspect of the Pack
		{class = "HUNTER",		id = 20043},	-- Aspect of the Wild

		{class = "DEATHKNIGHT",	id = 48263},	-- Blood Presence
		{class = "DEATHKNIGHT",	id = 48266},	-- Frost Presence
		{class = "DEATHKNIGHT",	id = 48265},	-- Unholy Presence

		{class = "PALADIN",		id = 19746},	-- Concentration Aura
		{class = "PALADIN",		id = 32223},	-- Crusader Aura
		{class = "PALADIN",		id = 465},		-- Devotion Aura
		{class = "PALADIN",		id = 19891},	-- Resistance Aura
		{class = "PALADIN",		id = 7294},		-- Retribution Aura

		{class = "WARLOCK",		id = 47241},	-- Metamorphosis
	}

	TMW.CS = {
		[0] = 0,
	}

	TMW.CSN = {
		[0] = L["NONE"],
	}

	if pclass == "DRUID" then
		TMW.CSN[0] = L["CASTERFORM"]
	end

	for k,v in pairs(TMW.Stances) do
		if TMW.Stances[k]["class"] == pclass then
			local zz = GetSpellInfo(TMW.Stances[k]["id"])
			tinsert(TMW.CS,TMW.Stances[k]["id"])
			tinsert(TMW.CSN,zz)
		end
	end
end

local function TT(f,t)
	f:SetScript("OnEnter",function(self)
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		GameTooltip:AddLine(t, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
end
-- -----------------------
-- INTERFACE OPTIONS PANEL
-- -----------------------

function TellMeWhen_GroupPositionReset(groupID)
	local group = _G["TellMeWhen_Group"..groupID]
	TellMeWhen_Settings.Groups[groupID]["Scale"] = 2.0
	TellMeWhen_Update()
	group:SetPoint("CENTER", "UIParent", "CENTER", 0, 0)
	local p = TellMeWhen_Settings.Groups[groupID]["Point"]
	p.point,p.relativePoint,p.x,p.y = "CENTER", "CENTER", 0, 0
	TellMeWhen_Settings.Groups[groupID]["Point"] = p
	DEFAULT_CHAT_FRAME:AddMessage(format(L["GROUPRESETMSG"],groupID))
end

function TellMeWhen_LockToggle()
	if (not UnitAffectingCombat("player")) or (TMW.TestOn) then
		TellMeWhen_Settings["Locked"] = not TellMeWhen_Settings["Locked"]
		PlaySound("UChatScrollButton")
		TellMeWhen_Update()
	else
		DEFAULT_CHAT_FRAME:AddMessage(L["CMD_ERROR"])
	end
end

function TellMeWhen_Reset()
	TellMeWhen_Settings = TellMeWhen_GetDefaults()
	TellMeWhen_Settings.Groups[1]["Enabled"] = true
	TellMeWhen_Update()
	DEFAULT_CHAT_FRAME:AddMessage("[TellMeWhen]: Groups have been Reset")
end

function TellMeWhen_SetGroupPositions(group,groupID)
	local p = {}
	p = TellMeWhen_Settings.Groups[groupID]["Point"] or {}
	group:ClearAllPoints()
	if p.y then
		group:SetPoint(p.point,UIParent,p.relativePoint,p.x,p.y)
	else
		group:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 100, (-20 - (30*groupID)))
		p.point,p.relativePoint,p.x,p.y = "TOPLEFT", "TOPLEFT", 100, (-20 - (30*groupID))
		TellMeWhen_Settings.Groups[groupID]["Point"] = p
	end
end

function TellMeWhen_Options_Compile()
	TMW.OptionsTable = {
		type = "group",
		args = {
			main = {
				type = "group",
				name = L["UIPANEL_MAINOPT"],
				order = 1,
				args = {
					header = {
						name = L["ICON_TOOLTIP1"] .. " " .. TELLMEWHEN_VERSION .. TELLMEWHEN_VERSION_MINOR,
						type = "header",
						order = 1,
					},
					togglelock = {
						name = L["UIPANEL_LOCKUNLOCK"],
						desc = L["UIPANEL_SUBTEXT2"],
						type = "toggle",
						order = 2,
						set = function(info,val)
							TellMeWhen_Settings["Locked"] = val
							TellMeWhen_Update()
						end,
						get = function(info) return TellMeWhen_Settings["Locked"] end
					},
					bartexture = {
						name = L["UIPANEL_BARTEXTURE"],
						type = "select",
						order = 3,
						dialogControl = 'LSM30_Statusbar',
						values = LSM:HashTable("statusbar"),
						set = function(info,val)
							TellMeWhen_Settings["Texture"] = LSM:Fetch("statusbar",val)
							TellMeWhen_Settings["TextureName"] = val
							TellMeWhen_Update()
						end,
						get = function(info) return TellMeWhen_Settings["TextureName"] end
					},
					updinterval = {
						name = L["UIPANEL_UPDATEINTERVAL"],
						desc = L["UIPANEL_TOOLTIP_UPDATEINTERVAL"],
						type = "range",
						order = 9,
						min = 0,
						max = 0.5,
						step = 0.01,
						bigStep = 0.01,
						set = function(info,val)
						TellMeWhen_Settings.Interval = val
						TellMeWhen_Update()
						end,
						get = function(info) return TellMeWhen_Settings.Interval end

					},
					iconspacing = {
						name = L["UIPANEL_ICONSPACING"],
						desc = L["UIPANEL_ICONSPACING_DESC"],
						type = "range",
						order = 10,
						min = 0,
						softMax = 20,
						step = 0.1,
						bigStep = 1,
						set = function(info,val)
							TellMeWhen_Settings["Spacing"] = val
							TELLMEWHEN_ICONSPACING = TellMeWhen_Settings["Spacing"] or TELLMEWHEN_ICONSPACING
							TellMeWhen_Update()
						end,
						get = function(info) return TELLMEWHEN_ICONSPACING end
					},
					barignoregcd = {
						name = L["UIPANEL_BARIGNOREGCD"],
						desc = L["UIPANEL_BARIGNOREGCD_DESC"],
						type = "toggle",
						order = 21,
						set = function(info,val)
							TellMeWhen_Settings["BarGCD"] = not val
							TellMeWhen_Update()
						end,
						get = function(info) return not TellMeWhen_Settings["BarGCD"] end
					},
					clockignoregcd = {
						name = L["UIPANEL_CLOCKIGNOREGCD"],
						desc = L["UIPANEL_CLOCKIGNOREGCD_DESC"],
						type = "toggle",
						order = 22,
						set = function(info,val)
							TellMeWhen_Settings["ClockGCD"] = not val
							TellMeWhen_Update()
						end,
						get = function(info) return not TellMeWhen_Settings["ClockGCD"] end
					},
					drawedge = {
						name = L["UIPANEL_DRAWEDGE"],
						desc = L["UIPANEL_DRAWEDGE_DESC"],
						type = "toggle",
						order = 40,
						set = function(info,val)
							TellMeWhen_Settings["DrawEdge"] = val
							TellMeWhen_Update()
						end,
						get = function(info) return TellMeWhen_Settings["DrawEdge"] end
					},
					condense = {
						name = L["UIPANEL_CONDENSE"],
						desc = L["UIPANEL_TOOLTIP_CONDENSE"],
						type = "execute",
						order = 50,
						confirm = false,
						func = function()
							TellMeWhen_CondenseSettings()
						end,
					},
					resetall = {
						name = L["UIPANEL_ALLRESET"],
						desc = L["UIPANEL_TOOLTIP_ALLRESET"],
						type = "execute",
						order = 51,
						confirm = true,
						func = function() TellMeWhen_Reset() end,
					},
					coloropts = {
						type = "group",
						name = L["UIPANEL_COLORS"],
						order = 3,
						args = {
							cdstcolor = {
								name = L["UIPANEL_COLOR_STARTED"],
								desc = L["UIPANEL_COLOR_STARTED_DESC"],
								type = "color",
								order = 31,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["CDSTColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["CDSTColor"]  return c.r, c.g, c.b, c.a end,
							},
							cdcocolor = {
								name = L["UIPANEL_COLOR_COMPLETE"],
								desc = L["UIPANEL_COLOR_COMPLETE_DESC"],
								type = "color",
								order = 32,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["CDCOColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["CDCOColor"]  return c.r, c.g, c.b, c.a end,
							},
							oorcolor = {
								name = L["UIPANEL_COLOR_OOR"],
								desc = L["UIPANEL_COLOR_OOR_DESC"],
								type = "color",
								order = 37,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["OORColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["OORColor"]  return c.r, c.g, c.b, c.a end,
							},
							oomcolor = {
								name = L["UIPANEL_COLOR_OOM"],
								desc = L["UIPANEL_COLOR_OOM_DESC"],
								type = "color",
								order = 38,
								hasAlpha = true,
								set = function(info,nr,ng,nb,na) local c = TellMeWhen_Settings["OOMColor"] c.r = nr c.g = ng c.b = nb c.a = na TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["OOMColor"]  return c.r, c.g, c.b, c.a end,
							},
							desc = {
								name = L["UIPANEL_COLOR_DESC"],
								type = "description",
								order = 40,
							},
							--[[usablecolor = {
								name = L["UIPANEL_COLOR_COMPLETE"],
								desc = L["UIPANEL_COLOR_COMPLETE_DESC"],
								type = "color",
								order = 41,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["USEColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["USEColor"] return c.r, c.g, c.b end,
							},
							unusablecolor = {
								name = L["UIPANEL_COLOR_COMPLETE"],
								desc = L["UIPANEL_COLOR_COMPLETE_DESC"],
								type = "color",
								order = 43,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["UNUSEColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["UNUSEColor"] return c.r, c.g, c.b end,
							},]]
							presentcolor = {
								name = L["UIPANEL_COLOR_PRESENT"],
								desc = L["UIPANEL_COLOR_PRESENT_DESC"],
								type = "color",
								order = 45,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["PRESENTColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["PRESENTColor"] return c.r, c.g, c.b end,
							},
							absentcolor = {
								name = L["UIPANEL_COLOR_ABSENT"],
								desc = L["UIPANEL_COLOR_ABSENT_DESC"],
								type = "color",
								order = 47,
								hasAlpha = false,
								set = function(info,nr,ng,nb) local c = TellMeWhen_Settings["ABSENTColor"] c.r = nr c.g = ng c.b = nb TellMeWhen_ColorUpdate() end,
								get = function(info) local c = TellMeWhen_Settings["ABSENTColor"] return c.r, c.g, c.b end,
							},
						},
					},
					countfont = {
						type = "group",
						name = L["UIPANEL_FONT"],
						order = 4,
						args = {
							font = {
								name = L["UIPANEL_FONT"],
								desc = L["UIPANEL_FONT_DESC"],
								type = "select",
								order = 3,
								dialogControl = 'LSM30_Font',
								values = LSM:HashTable("font"),
								set = function(info,val)
									TellMeWhen_Settings.Font.Path = LSM:Fetch("font",val)
									TellMeWhen_Settings.Font.Name = val
									TellMeWhen_Update()
								end,
								get = function(info) return TellMeWhen_Settings.Font.Name end,
							},
							fontSize = {
								name = L["UIPANEL_FONT_SIZE"],
								desc = L["UIPANEL_FONT_SIZE_DESC"],
								type = "range",
								order = 10,
								min = 6,
								max = 26,
								step = 1,
								bigStep = 1,
								set = function(info,val)
									TellMeWhen_Settings.Font.Size = val
									TellMeWhen_Update()
								end,
								get = function(info) return TellMeWhen_Settings.Font.Size end,
							},
							outline = {
								name = L["UIPANEL_FONT_OUTLINE"],
								desc = L["UIPANEL_FONT_OUTLINE_DESC"],
								type = "select",
								values = TMW.Flags,
								style = "dropdown",
								order = 11,
								set = function(info,val)
									TellMeWhen_Settings.Font.Outline = val
									TellMeWhen_Update()
								end,
								get = function(info) return TellMeWhen_Settings.Font.Outline end,
							},
						},
					},
				},
			},
			groups = {
				type = "group",
				name = L["UIPANEL_GROUPS"],
				order = 2,
				args = {
				}
			}
		}
	}

	for zz=1,TELLMEWHEN_MAXGROUPS do
		local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
		TMW.OptionsTable.args.groups.args["group"..zz] = {
			type = "group",
			name = L["UIPANEL_ICONGROUP"] .. zz,
			order = zz,
			args = {
				enable = {
					name = L["UIPANEL_ENABLEGROUP"],
					desc = L["UIPANEL_TOOLTIP_ENABLEGROUP"],
					type = "toggle",
					order = 1,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["Enabled"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"Enabled") end
				},
				columns = {
					name = L["UIPANEL_COLUMNS"],
					desc = L["UIPANEL_TOOLTIP_COLUMNS"],
					type = "range",
					order = 10,
					min = 1,
					max = TELLMEWHEN_MAXROWS,
					step = 1,
					bigStep = 1,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["Columns"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"Columns") end

				},
				rows = {
					name = L["UIPANEL_ROWS"],
					desc = L["UIPANEL_TOOLTIP_ROWS"],
					type = "range",
					order = 11,
					min = 1,
					max = TELLMEWHEN_MAXROWS,
					step = 1,
					bigStep = 1,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["Rows"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"Rows") end

				},
				combat = {
					name = L["UIPANEL_ONLYINCOMBAT"],
					desc = L["UIPANEL_TOOLTIP_ONLYINCOMBAT"],
					type = "toggle",
					order = 2,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["OnlyInCombat"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"OnlyInCombat") end
				},
				vehicle = {
					name = L["UIPANEL_NOTINVEHICLE"],
					desc = L["UIPANEL_TOOLTIP_NOTINVEHICLE"],
					type = "toggle",
					order = 3,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["NotInVehicle"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"NotInVehicle") end
				},
				mainspec = {
					name = L["UIPANEL_PRIMARYSPEC"],
					desc = L["UIPANEL_TOOLTIP_PRIMARYSPEC"],
					type = "toggle",
					order = 6,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["PrimarySpec"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"PrimarySpec") end
				},
				offspec = {
					name = L["UIPANEL_SECONDARYSPEC"],
					desc = L["UIPANEL_TOOLTIP_SECONDARYSPEC"],
					type = "toggle",
					order = 7,
					set = function(info,val)
						TellMeWhen_Settings.Groups[zz]["SecondarySpec"] = val
						TellMeWhen_Group_Update(zz)
					end,
					get = function(info) return TellMeWhen_GetGroupSetting(zz,"SecondarySpec") end
				},
				reset = {
					name = L["UIPANEL_GROUPRESET"],
					desc = L["UIPANEL_TOOLTIP_GROUPRESET"],
					type = "execute",
					order = 13,
					func = function() TellMeWhen_GroupPositionReset(zz) end
				},
			}
		}
		if #(TMW.CSN) > 0 then 		-- 	[0] doesnt factor into the length
			TMW.OptionsTable.args.groups.args["group".. zz].args.stance = {
				type = "multiselect",
				name = L["UIPANEL_STANCE"],
				order = 12,
				values = TMW.CSN,
				set = function(info,key,val)		--true values are stances that are hidden, this way i dont have to define every single stance as true and make the config file even bigger.
					TellMeWhen_Settings.Groups[zz]["Stance"][key] = not val
					TellMeWhen_Group_Update(zz)
				end,
				get = function(info,key)
					return not TellMeWhen_Settings.Groups[zz]["Stance"][key]
				end,
			}
		end
	end
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TellMeWhen Options", TMW.OptionsTable)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TellMeWhen Options",L["ICON_TOOLTIP1"])
	LibStub("AceConfigCmd-3.0"):CreateChatCommand("tmwconfig", "TellMeWhen Options")
end

function TellMeWhen_SlashCommand(cmd)
	cmd = strlower(tostring(cmd))
	if cmd == strlower(L["CMD_RESET"]) then
		TellMeWhen_Reset()
	elseif cmd == strlower(L["CMD_OPTIONS"]) then
		InterfaceOptionsFrame_OpenToCategory(L["ICON_TOOLTIP1"])
	else
		TellMeWhen_LockToggle()
	end
end


-- --------
-- ICON GUI
-- --------

function TellMeWhen_Equivs_GenerateTips(BoD,equiv)
	local r = "" --tconcat doesnt allow me to exclude duplicates unless i make another garbage table, so lets just do this
	local tab = TellMeWhen_SplitNames(TMW.BE[BoD][equiv])
	for k,v in pairs(tab) do
		local name = GetSpellInfo(v)
		if not tiptemp[name] then --prevents display of the same name twice when there are multiple ranks.
			if not (k == #tab) then
				r = r .. GetSpellInfo(v) .. "\r\n"
			else
				r = r .. GetSpellInfo(v)
			end
		end
		tiptemp[name] = true
	end
	wipe(tiptemp)
	return r
end

function TellMeWhen_GetIconMenuDropDownText(g,i)
	g,i = tonumber(g),tonumber(i)
	local text = TellMeWhen_GetIconSetting(g,i,"Name")
	if TellMeWhen_GetIconSetting(g,i,"Type") == "wpnenchant" then
		if TellMeWhen_GetIconSetting(g,i,"WpnEnchantType") == "MainHandSlot" then text = INVTYPE_WEAPONMAINHAND
		elseif TellMeWhen_GetIconSetting(g,i,"WpnEnchantType") == "SecondaryHandSlot" then text = INVTYPE_WEAPONOFFHAND
		elseif TellMeWhen_GetIconSetting(g,i,"WpnEnchantType") == "RangedSlot" then text = INVTYPE_THROWN end
		text = text .. " ((" .. L["ICONMENU_WPNENCHANT"] .. "))"
	elseif TellMeWhen_GetIconSetting(g,i,"Type") == "meta" then
		text = "((" .. L["ICONMENU_META"] .. "))"
	end
	local textshort = strsub(text,1,35)
	if strlen(text) > 35 then textshort = textshort .. "..." end
	return text,textshort
end


TMW.IconMenuOptions = {}
TMW.IconMenuOptions.cooldown = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 												},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "CooldownType", 		text = L["ICONMENU_COOLDOWNTYPE"], 	hasArrow = true,							},
	{ value = "CooldownShowWhen",	text = L["ICONMENU_SHOWWHEN"], 		hasArrow = true,							},
	{ value = "RangeCheck", 		text = L["ICONMENU_RANGECHECK"], 	desc = L["ICONMENU_RANGECHECK_DESC"],		},
	{ value = "ManaCheck", 			text = L["ICONMENU_MANACHECK"], 	desc = L["ICONMENU_MANACHECK_DESC"],		},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			hasArrow = true,							},
}

TMW.IconMenuOptions.reactive = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"],													},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "CooldownShowWhen", 	text = L["ICONMENU_SHOWWHEN"], 		hasArrow = true,							},
	{ value = "CooldownCheck", 		text = L["ICONMENU_COOLDOWNCHECK"], desc = L["ICONMENU_COOLDOWNCHECK_DESC"],	},
	{ value = "RangeCheck", 		text = L["ICONMENU_RANGECHECK"],	desc = L["ICONMENU_RANGECHECK_DESC"],		},
	{ value = "ManaCheck", 			text = L["ICONMENU_MANACHECK"], 	desc = L["ICONMENU_MANACHECK_DESC"],		},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			hasArrow = true,							},
}

TMW.IconMenuOptions.buff = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 												},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"],	desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "OnlyMine", 			text = L["ICONMENU_ONLYMINE"],													},
	{ value = "BuffOrDebuff", 		text = L["ICONMENU_BUFFTYPE"], 		hasArrow = true,							},
	{ value = "Unit",				text = L["ICONMENU_UNIT"], 			hasArrow = true,							},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_BUFFSHOWWHEN"], 	hasArrow = true,							},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			hasArrow = true,							},
}

TMW.IconMenuOptions.wpnenchant = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 												},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "HideUnequipped", 	text = L["ICONMENU_HIDEUNEQUIPPED"],											},
	{ value = "WpnEnchantType", 	text = L["ICONMENU_WPNENCHANTTYPE"],hasArrow = true,							},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_SHOWWHEN"], 		hasArrow = true,							},
}

TMW.IconMenuOptions.totem = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"],													},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_SHOWWHEN"], 		hasArrow = true,							},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			hasArrow = true,							},
}

TMW.IconMenuOptions.multistatecd = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 												},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "CooldownShowWhen",	text = L["ICONMENU_SHOWWHEN"], 		hasArrow = true,							},
	{ value = "RangeCheck", 		text = L["ICONMENU_RANGECHECK"], 	desc = L["ICONMENU_RANGECHECK_DESC"],		},
	{ value = "ManaCheck", 			text = L["ICONMENU_MANACHECK"], 	desc = L["ICONMENU_MANACHECK_DESC"],		},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			hasArrow = true,							},
}

TMW.IconMenuOptions.cast = {
	{ value = "ShowTimer", 			text = L["ICONMENU_SHOWTIMER"], 												},
	{ value = "ShowTimerText", 		text = L["ICONMENU_SHOWTIMERTEXT"], desc = L["ICONMENU_SHOWTIMERTEXT_DESC"],	},
	{ value = "Interruptible", 		text = L["ICONMENU_ONLYINTERRUPTIBLE"],											},
	{ value = "Unit",				text = L["ICONMENU_UNIT"], 			hasArrow = true,							},
	{ value = "BuffShowWhen", 		text = L["ICONMENU_CASTSHOWWHEN"], 	hasArrow = true,							},
	{ value = "Bars", 				text = L["ICONMENU_BARS"], 			hasArrow = true,							},
}

TMW.IconMenuOptions.meta = {
}

TMW.IconMenu_SubMenus = {
	-- the keys on this table need to match the settings variable names
	Type = {
		{ value = "cooldown", 		text = L["ICONMENU_COOLDOWN"] },
		{ value = "buff", 			text = L["ICONMENU_BUFFDEBUFF"] },
		{ value = "reactive", 		text = L["ICONMENU_REACTIVE"] },
		{ value = "wpnenchant",		text = L["ICONMENU_WPNENCHANT"] },
		{ value = "totem", 			text = L["ICONMENU_TOTEM"], 			desc = pclass == "DEATHKNIGHT" and L["ICONMENU_TOTEM_DESC"]},
		{ value = "multistatecd",	text = L["ICONMENU_MULTISTATECD"], 		desc = L["ICONMENU_MULTISTATECD_DESC"] },
		{ value = "cast",			text = L["ICONMENU_CAST"], 				desc = L["ICONMENU_CAST_DESC"] },
		{ value = "meta", 			text = L["ICONMENU_META"],				desc = L["ICONMENU_META_DESC"] },
	},
	CooldownType = {
		{ value = "spell", 			text = L["ICONMENU_SPELL"] },
		{ value = "item", 			text = L["ICONMENU_ITEM"] },
	},
	BuffOrDebuff = {
		{ value = "HELPFUL", 		text = L["ICONMENU_BUFF"], 				color = "|cFF00FF00" },
		{ value = "HARMFUL", 		text = L["ICONMENU_DEBUFF"], 			color = "|cFFFF0000" },
		{ value = "EITHER", 		text = L["ICONMENU_BOTH"] },
	},
	Unit = {
		{ value = "player", 		text = PLAYER },
		{ value = "target", 		text = TARGET },
		{ value = "targettarget", 	text = L["ICONMENU_TARGETTARGET"] },
		{ value = "focus", 			text = FOCUS },
		{ value = "focustarget", 	text = L["ICONMENU_FOCUSTARGET"] },
		{ value = "target;focus",   text = L["ICONMENU_TARGET_OR_FOCUS"] },
		{ value = "pet", 			text = PET },
		{ value = "pettarget", 		text = L["ICONMENU_PETTARGET"] },
		{ value = "mouseover", 		text = L["ICONMENU_MOUSEOVER"] },
		{ value = "mouseovertarget",text = L["ICONMENU_MOUSEOVERTARGET"]  },
		{ value = "vehicle", 		text = L["ICONMENU_VEHICLE"] },
	},
	BuffShowWhen = {
		{ value = "present", 		text = L["ICONMENU_PRESENT"], 			color = "|cFF00FF00" },
		{ value = "absent", 		text = L["ICONMENU_ABSENT"], 			color = "|cFFFF0000" },
		{ value = "always", 		text = L["ICONMENU_ALWAYS"] },
	},
	CooldownShowWhen = {
		{ value = "usable", 		text = L["ICONMENU_USABLE"], 			color = "|cFF00FF00" },
		{ value = "unusable", 		text = L["ICONMENU_UNUSABLE"], 			color = "|cFFFF0000" },
		{ value = "always", 		text = L["ICONMENU_ALWAYS"] },
	},
	WpnEnchantType = {
		{ value = "MainHandSlot", 	text = INVTYPE_WEAPONMAINHAND },
		{ value = "SecondaryHandSlot",text = INVTYPE_WEAPONOFFHAND },
	},
	Bars = {
		{ value = "ShowPBar", 		text = L["ICONMENU_SHOWPBAR"] },
		{ value = "ShowCBar", 		text = L["ICONMENU_SHOWCBAR"] },
		{ value = "InvertBars", 	text = L["ICONMENU_INVERTBARS"] },
	},
}

for i=1,4 do
	tinsert(TMW.IconMenu_SubMenus.Unit, { value = "party" .. i, text = PARTY .. " " .. i })
end
for i=1,5 do
	tinsert(TMW.IconMenu_SubMenus.Unit, { value = "arena" .. i, text = ARENA .. " " .. i })
end
if pclass == "ROGUE" then
	tinsert(TMW.IconMenu_SubMenus.WpnEnchantType, { value = "RangedSlot", text = INVTYPE_THROWN })
end


function TellMeWhen_IconMenu_Initialize(self)
	local groupID = TMW.CI.g
	local iconID = TMW.CI.i
	local icon = _G["TellMeWhen_Group"..groupID.."_Icon"..iconID]
	if not icon then return end
	
	TMW.IconMenu_SubMenus.Icons = TMW.IconMenu_SubMenus.Icons or {}
	wipe(TMW.IconMenu_SubMenus.Icons)
	for k,v in pairs(TMW.Icons) do
		if _G[v] then
			local g,i = _G[v]:GetParent():GetID(), _G[v]:GetID()
			local text = TellMeWhen_GetIconSetting(g,i,"Name")
			local textshort = strsub(text,1,20)
			if strlen(text) > 20 then textshort = textshort .. "..." end
			TMW.IconMenu_SubMenus.Icons[k] = {
				value = v,
				text = textshort,
				tooltipTitle = text,
				desc = string.format(L["GROUPICON"], g,i),
				tooltipOnButton = true,
			}
		end
	end
	
	if (UIDROPDOWNMENU_MENU_LEVEL == 2) then
		local subMenus = TMW.IconMenu_SubMenus[UIDROPDOWNMENU_MENU_VALUE]
		for k in pairs(subMenus) do
			-- here, UIDROPDOWNMENU_MENU_VALUE is the setting name
			local info = UIDropDownMenu_CreateInfo()
			info.text = subMenus[k].text
			info.value = subMenus[k].value
			if subMenus[k]["desc"] then
				info.tooltipTitle = subMenus[k].tooltipTitle or subMenus[k].text
				info.tooltipText = subMenus[k].desc
				info.tooltipOnButton = true
			end
			info.colorCode = subMenus[k].color
			if UIDROPDOWNMENU_MENU_VALUE == "Icons" then
				TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons or {}
				info.checked = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[subMenus[k].value]
				info.func = TellMeWhen_IconMenu_ToggleIconSetting
				info.keepShownOnClick = true
			elseif UIDROPDOWNMENU_MENU_VALUE == "Bars" then
				info.checked = TellMeWhen_Settings.Groups[groupID].Icons[iconID][info.value]
				info.func = TellMeWhen_IconMenu_ToggleSetting
				info.keepShownOnClick = true
			else
				info.checked = (info.value == TellMeWhen_GetIconSetting(groupID,iconID,UIDROPDOWNMENU_MENU_VALUE))
				info.func = TellMeWhen_IconMenu_ChooseSetting
			end
			UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
		end
		return
	end

	-- show name
	local info = UIDropDownMenu_CreateInfo()
	if icon.Name and icon.Name ~= "" and icon.Type ~= "wpnenchant" and icon.Type ~= "meta" then
		info = UIDropDownMenu_CreateInfo()
		local textshort = strsub(icon.Name,1,35)
		if strlen(icon.Name) > 35 then
			textshort = textshort .. "..."
			info.tooltipTitle = icon.Name
			info.tooltipOnButton = true
			info.tooltipWhileDisabled = true
		end
		info.text = textshort
		info.isTitle = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)
	end

	-- choose name
	if icon.Type ~= "wpnenchant" and icon.Type ~= "meta" then
		info = UIDropDownMenu_CreateInfo()
		info.value = L["ICONMENU_CHOOSENAME"]
		info.text = L["ICONMENU_CHOOSENAME"]
		info.func = TellMeWhen_ChooseName_Load
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)
	end

	-- enable icon
	info = UIDropDownMenu_CreateInfo()
	info.value = "Enabled"
	info.text = L["ICONMENU_ENABLE"]
	info.checked = icon.Enabled
	info.func = TellMeWhen_IconMenu_ToggleSetting
	info.keepShownOnClick = true
	UIDropDownMenu_AddButton(info)

	-- icon type
	info = UIDropDownMenu_CreateInfo()
	info.value = "Type"
	info.text = L["ICONMENU_TYPE"]
	info.hasArrow = true
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)

	-- icon condition
	info = UIDropDownMenu_CreateInfo()
	if not icon.Conditions then return end --this runs too early sometimes
	if (#(icon.Conditions) > 0) then
		info.text = L["ICONMENU_EDITCONDITION"]
		info.value = "Edit condition"
		info.func = function()
			TMW.CCnI = { g = TMW.CI.g, i = TMW.CI.i }
			TellMeWhen_Conditions_LoadDialog()
		end
	else
		info.text = L["ICONMENU_ADDCONDITION"]
		info.value = "Add condition"
		info.func = function()
			TMW.CCnI = { g = TMW.CI.g, i = TMW.CI.i }
			TellMeWhen_Conditions_ClearDialog()
		end
	end
	info.hasArrow = false
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)
	
	--alpha/duration/stacks
	if icon.Type ~= "meta" then
		info = UIDropDownMenu_CreateInfo()
		local text = L["ICONMENU_EDIT"] .. " "
		
		if TellMeWhen_GetIconSetting(TMW.CI.g,TMW.CI.i,"Alpha") ~= 1 or TellMeWhen_GetIconSetting(TMW.CI.g,TMW.CI.i,"UnAlpha") ~= 1
		or TellMeWhen_GetIconSetting(TMW.CI.g,TMW.CI.i,"StackAlpha") ~= 0 or TellMeWhen_GetIconSetting(TMW.CI.g,TMW.CI.i,"DurationAlpha") ~= 0
		or TellMeWhen_GetIconSetting(TMW.CI.g,TMW.CI.i,"ConditionAlpha") ~= 0 or TellMeWhen_GetIconSetting(TMW.CI.g,TMW.CI.i,"FakeHidden") == true  then
			text = text .. "|cFFFF5959" .. L["ICONMENU_ALPHA"] .. "|r"
		else
			text = text .. L["ICONMENU_ALPHA"]
		end
		
		if TellMeWhen_GetIconSetting(groupID,iconID,"DurationMinEnabled") or TellMeWhen_GetIconSetting(groupID,iconID,"DurationMaxEnabled") then
			text = text .. "/" .. "|cFFFF5959" .. L["DURATIONPANEL_TITLE"] .. "|r" 
		else
			text = text .. "/" .. L["DURATIONPANEL_TITLE"]
		end
		
		if icon.Type == "buff" then
			if TellMeWhen_GetIconSetting(groupID,iconID,"StackMinEnabled") or TellMeWhen_GetIconSetting(groupID,iconID,"StackMaxEnabled") then
				text = text .. "/" .. "|cFFFF5959" .. L["STACKSPANEL_TITLE"] .. "|r"
			else
				text = text .. "/" .. L["STACKSPANEL_TITLE"]
			end
			info.func = function()
				TMW.CEI = { g = TMW.CI.g, i = TMW.CI.i }
				TellMeWhen_StackEditorFrame:Show()
				TellMeWhen_Editor_Load()
			end
		else
			info.func = function()
				TMW.CEI = { g = TMW.CI.g, i = TMW.CI.i }
				TellMeWhen_StackEditorFrame:Hide()
				TellMeWhen_Editor_Load()
			end
		end
		
		info.text = text
		info.hasArrow = false
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)
	end

	info = UIDropDownMenu_CreateInfo()
	info.disabled = true
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)

	--meta icons
	if icon.Type == "meta" then
		info = UIDropDownMenu_CreateInfo()
		info.text = L["ICONMENU_ICONS"]
		info.func = function()
			TMW.CMI = { g = TMW.CI.g, i = TMW.CI.i }
			TellMeWhen_MetaEditor_Update()
			TellMeWhen_MetaEditorFrame:Show()
		end
		info.hasArrow = false
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)
	end
	
	-- additional options
	if icon.Type ~= "" and icon.Type ~= "meta" then
		local moreOptions = TMW.IconMenuOptions[icon.Type]
		
		if not moreOptions then return end
		for index, value in pairs(moreOptions) do
			info = UIDropDownMenu_CreateInfo()
			info.hasArrow = moreOptions[index]["hasArrow"]
			if moreOptions[index]["desc"] then
				info.tooltipTitle = moreOptions[index]["text"]
				info.tooltipText = moreOptions[index]["desc"]
				info.tooltipOnButton = true
			end
			info.text = moreOptions[index]["text"]
			info.value = moreOptions[index]["value"]

			if not info.hasArrow then
				info.func = TellMeWhen_IconMenu_ToggleSetting
				info.checked = TellMeWhen_GetIconSetting(groupID,iconID,info.value)
				info.notCheckable = false
			else
				info.notCheckable = true
			end
			if moreOptions[index]["value"] == "ShowTimerText" then
				if IsAddOnLoaded("OmniCC") or IsAddOnLoaded("tullaCC") then
					info.disabled = false
				else
					info.disabled = true
					info.tooltipWhileDisabled = true
				end
			end
			info.keepShownOnClick = true
			UIDropDownMenu_AddButton(info)
		end

	elseif icon.Type ~= "meta" then
		info = UIDropDownMenu_CreateInfo()
		info.text = L["ICONMENU_OPTIONS"]
		info.disabled = true
		UIDropDownMenu_AddButton(info)
	end

	if ((icon.Name) and (icon.Name ~= "")) or (icon.Type ~= "") then
		info = UIDropDownMenu_CreateInfo()
		info.disabled = true
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)
	end

	--copy settings
	info = UIDropDownMenu_CreateInfo()
	info.notCheckable = true
	info.text = L["COPYSETTINGS"]
	info.func = function()
		TMW.CCoI.i = TMW.CI.i
		TMW.CCoI.g = TMW.CI.g
		TellMeWhen_CopyPanel_Update()
		TellMeWhen_CopyFrame:Show()
		CloseDropDownMenus()
	end
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)


	-- clear settings
	if ((icon.Name) and (icon.Name ~= "")) or (icon.Type ~= "") then
		info = UIDropDownMenu_CreateInfo()
		info.text = L["ICONMENU_CLEAR"]
		info.func = TellMeWhen_IconMenu_ClearSettings
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)
	end
end

function TellMeWhen_IconMenu_ShowNameDialog()
	TMW.CNI = { g = TMW.CI.g, i = TMW.CI.i }
	local dialog = StaticPopup_Show("TELLMEWHEN_CHOOSENAME_DIALOG")
	TMWOPENDIALOG = dialog
	if not dialog then return false end
	local text = _G[dialog:GetName() .. "Text"]
	local editbox = _G[dialog:GetName() .. "EditBox"]
	local dd = _G["TellMeWhen_EquivSelectDropdown"]
	local oldheight = text:GetStringHeight()
	TMW.D.dwidth = dialog:GetWidth()
	TMW.D.dheight = dialog:GetWidth()
	TMW.D.twidth = text:GetWidth()
	TMW.D.ewidth = editbox:GetWidth()
	dialog:SetWidth(450)
	text:SetWidth(dialog:GetWidth()-20)
	dialog:SetHeight(dialog:GetHeight() - (oldheight - text:GetStringHeight()))
	editbox:SetWidth(dialog:GetWidth()-50)

	local groupID = TMW.CNI.g
	local iconID = TMW.CNI.i
	text:SetText("|cFFF8CE00" .. L["ICON_TOOLTIP1"] .. " " .. format(L["GROUPICON"],groupID,iconID) .. "|r\r\n\r\n" .. L["CHOOSENAME_DIALOG"])
	local Type = TellMeWhen_GetIconSetting(groupID,iconID,"Type")
	local Name = TellMeWhen_GetIconSetting(groupID,iconID,"Name")
	if ((Type == "buff") or (Type == "")) then
		dialog:SetHeight(dialog:GetHeight() + dd:GetHeight())
		dd:SetParent(dialog)
		dd:ClearAllPoints()
		dd:SetPoint("BOTTOM",dialog,"BOTTOM",0,76)
		dd:Show()
		UIDropDownMenu_SetText(dd,L["CHOOSENAME_DIALOG_DDDEFAULT"])
	else
		dd:Hide()
	end
end

function TellMeWhen_IconMenu_ChooseName(text)
	local groupID = TMW.CNI.g
	local iconID = TMW.CNI.i
	TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Name"] = TellMeWhen_CleanString(text)
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID)
end

function TellMeWhen_IconMenu_ToggleSetting(self)
	local groupID = TMW.CI.g
	local iconID = TMW.CI.i
	TellMeWhen_Settings.Groups[groupID].Icons[iconID][self.value] = self.checked
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID)
end
				
function TellMeWhen_IconMenu_ToggleIconSetting(self)
	local groupID = TMW.CI.g
	local iconID = TMW.CI.i
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons or {}
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[self.value] = self.checked
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID)
end

function TellMeWhen_IconMenu_ChooseSetting(self,arg1)
	local groupID = TMW.CI.g
	local iconID = TMW.CI.i
	TellMeWhen_Settings.Groups[groupID].Icons[iconID][arg1 or UIDROPDOWNMENU_MENU_VALUE] = self.value
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID)
	if (UIDROPDOWNMENU_MENU_VALUE == "Type") then
		CloseDropDownMenus()
	end
end

function TellMeWhen_IconMenu_ClearSettings()
	local groupID = TMW.CI.g
	local iconID = TMW.CI.i
	TellMeWhen_Settings.Groups[groupID].Icons[iconID] = {}
	TellMeWhen_Icon_Update(_G["TellMeWhen_Group"..groupID.."_Icon"..iconID], groupID, iconID)
	CloseDropDownMenus()
end


function TellMeWhen_Icon_OnEnter(icon, motion)
	GameTooltip_SetDefaultAnchor(GameTooltip, icon)
	GameTooltip:AddLine(L["ICON_TOOLTIP1"] .. " " .. format(L["GROUPICON"],icon:GetParent():GetID(),icon:GetID()), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
	GameTooltip:AddLine(L["ICON_TOOLTIP2"], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
	GameTooltip:Show()
end

function TellMeWhen_Icon_OnMouseDown(icon, button)
	if (button == "RightButton") then
 		PlaySound("UChatScrollButton")
		TMW.CI.i = icon:GetID()		-- yay for dirty hacks
		TMW.CI.g = icon:GetParent():GetID()
		ToggleDropDownMenu(1, nil, _G[icon:GetName().."DropDown"], "cursor", 0, 0)
 	end
end


function TellMeWhen_ChooseName_Init()
	local groupID,iconID = TMW.CNI.g,TMW.CNI.i
	TellMeWhen_ChooseNameFrameFS1:SetText(L["ICONMENU_CHOOSENAME"] .. ": " .. format(L["GROUPICON"],groupID,iconID))
	TellMeWhen_ChooseNameFrameText:SetText(L["CHOOSENAME_DIALOG"])
	TellMeWhen_ChooseNameFrame:SetHeight(160 + TellMeWhen_ChooseNameFrameText:GetStringHeight())
	TellMeWhen_ChooseNameFrameCancelButton:SetText(CANCEL)
	TellMeWhen_ChooseNameFrameOkayButton:SetText(OKAY)
	UIDropDownMenu_SetText(TellMeWhen_EquivSelectDropdown,L["CHOOSENAME_DIALOG_DDDEFAULT"])
end

function TellMeWhen_ChooseName_Load()
	TMW.CNI = { g = TMW.CI.g, i = TMW.CI.i }
	local groupID,iconID = TMW.CNI.g,TMW.CNI.i
	TellMeWhen_ChooseNameFrameIconTexture:SetTexture(_G["TellMeWhen_Group" .. groupID .. "_Icon" .. iconID].texture:GetTexture())
	TellMeWhen_ChooseNameFrameEditBox:SetText(TellMeWhen_GetIconSetting(groupID,iconID,"Name"))
	TellMeWhen_ChooseNameFrameEditBox:SetFocus()
	TellMeWhen_ChooseNameFrameFS1:SetText(L["ICONMENU_CHOOSENAME"] .. ": " .. format(L["GROUPICON"],groupID,iconID))
	TellMeWhen_ChooseNameFrame:Show()
	TellMeWhen_ChooseNameFrame:SetFrameLevel(120)
end

function TellMeWhen_ChooseName_OK()
	TellMeWhen_IconMenu_ChooseName(TellMeWhen_ChooseNameFrameEditBox:GetText())
	TellMeWhen_ChooseNameFrame:Hide()
end


function TellMeWhen_Alpha_Init()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	TellMeWhen_AlphaEditorFrameFS1:SetText(L["ALPHAPANEL_TITLE"])

	TellMeWhen_AlphaEditorFrameAlphaSliderText:SetText(L["ICONALPHAPANEL_ALPHA"])
	TellMeWhen_AlphaEditorFrameUnAlphaSliderText:SetText(L["ICONALPHAPANEL_UNALPHA"])
	TellMeWhen_AlphaEditorFrameConditionAlphaSliderText:SetText(L["ICONALPHAPANEL_CNDTALPHA"])
	TellMeWhen_AlphaEditorFrameDurationSliderText:SetText(L["ICONALPHAPANEL_DURATIONALPHA"])
	TellMeWhen_AlphaEditorFrameStackSliderText:SetText(L["ICONALPHAPANEL_STACKALPHA"])
	TellMeWhen_AlphaEditorFrameFakeHiddenText:SetText(L["ICONALPHAPANEL_FAKEHIDDEN"])
	TellMeWhen_AlphaEditorFrameFakeHiddenText:SetFontObject("GameFontHighlight")
	
	
	TT(TellMeWhen_AlphaEditorFrameAlphaSlider,L["ICONALPHAPANEL_ALPHA_DESC"])
	TT(TellMeWhen_AlphaEditorFrameUnAlphaSlider,L["ICONALPHAPANEL_UNALPHA_DESC"])
	TT(TellMeWhen_AlphaEditorFrameConditionAlphaSlider,L["ICONALPHAPANEL_CNDTALPHA_DESC"])
	TT(TellMeWhen_AlphaEditorFrameDurationSlider,L["ICONALPHAPANEL_DURATIONALPHA_DESC"])
	TT(TellMeWhen_AlphaEditorFrameStackSlider,L["ICONALPHAPANEL_STACKALPHA_DESC"])
	TT(TellMeWhen_AlphaEditorFrameFakeHidden,L["ICONALPHAPANEL_FAKEHIDDEN_DESC"])
end

function TellMeWhen_Alpha_OK()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	local Alpha = TellMeWhen_AlphaEditorFrameAlphaSlider
	local UnAlpha = TellMeWhen_AlphaEditorFrameUnAlphaSlider
	local StackAlpha = TellMeWhen_AlphaEditorFrameStackSlider
	local DurationAlpha = TellMeWhen_AlphaEditorFrameDurationSlider
	local ConditionAlpha = TellMeWhen_AlphaEditorFrameConditionAlphaSlider
	local FakeHidden = TellMeWhen_AlphaEditorFrameFakeHidden

	if Alpha:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"Alpha") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] = Alpha:GetValue()/100
	end
	if UnAlpha:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"UnAlpha") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["UnAlpha"] = UnAlpha:GetValue()/100
	end
	if StackAlpha:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"StackAlpha") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["StackAlpha"] = StackAlpha:GetValue()/100
	end
	if DurationAlpha:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"DurationAlpha") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["DurationAlpha"] = DurationAlpha:GetValue()/100
	end
	if ConditionAlpha:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"ConditionAlpha") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["ConditionAlpha"] = ConditionAlpha:GetValue()/100
	end
	if FakeHidden:GetChecked() ~= TellMeWhen_GetIconSetting(groupID,iconID,"FakeHidden") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["FakeHidden"] = not not FakeHidden:GetChecked() --not not turns it into true/false isntead of 1/nil
	end
end

function TellMeWhen_Alpha_Reset()
	TellMeWhen_AlphaEditorFrameAlphaSlider:SetValue(TMW.Icon_Defaults.Alpha*100)
	TellMeWhen_AlphaEditorFrameUnAlphaSlider:SetValue(TMW.Icon_Defaults.UnAlpha*100)
	TellMeWhen_AlphaEditorFrameStackSlider:SetValue(TMW.Icon_Defaults.StackAlpha*100)
	TellMeWhen_AlphaEditorFrameDurationSlider:SetValue(TMW.Icon_Defaults.DurationAlpha*100)
	TellMeWhen_AlphaEditorFrameConditionAlphaSlider:SetValue(TMW.Icon_Defaults.ConditionAlpha*100)
	
	TellMeWhen_AlphaEditorFrameFakeHidden:SetChecked(false)
	TellMeWhen_Editor_OnCheckOrChange()
end

function TellMeWhen_Alpha_Load()
	TellMeWhen_Alpha_Reset()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i

	TellMeWhen_AlphaEditorFrameAlphaSlider:SetValue(TellMeWhen_GetIconSetting(groupID,iconID,"Alpha")*100)
	TellMeWhen_AlphaEditorFrameUnAlphaSlider:SetValue(TellMeWhen_GetIconSetting(groupID,iconID,"UnAlpha")*100)
	TellMeWhen_AlphaEditorFrameStackSlider:SetValue(TellMeWhen_GetIconSetting(groupID,iconID,"StackAlpha")*100)
	TellMeWhen_AlphaEditorFrameDurationSlider:SetValue(TellMeWhen_GetIconSetting(groupID,iconID,"DurationAlpha")*100)
	TellMeWhen_AlphaEditorFrameConditionAlphaSlider:SetValue(TellMeWhen_GetIconSetting(groupID,iconID,"ConditionAlpha")*100)
	TellMeWhen_AlphaEditorFrameFakeHidden:SetChecked(TellMeWhen_GetIconSetting(groupID,iconID,"FakeHidden"))
	TellMeWhen_Editor_OnCheckOrChange()
end


function TellMeWhen_Stack_Init()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	TellMeWhen_StackEditorFrameFS1:SetText(L["STACKSPANEL_TITLE"])
	TellMeWhen_StackEditorFrameMinSliderText:SetText(MINIMUM)
	TellMeWhen_StackEditorFrameMaxSliderText:SetText(MAXIMUM)
	
	TT(TellMeWhen_StackEditorFrameMinSlider,L["ICONMENU_STACKS_MIN_DESC"])
	TT(TellMeWhen_StackEditorFrameMaxSlider,L["ICONMENU_STACKS_MAX_DESC"])
end

function TellMeWhen_Stack_OK()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	local StackMin = TellMeWhen_StackEditorFrameMinSlider
	local StackMax = TellMeWhen_StackEditorFrameMaxSlider
	local StackMinCheck = TellMeWhen_StackEditorFrameMinCheck
	local StackMaxCheck = TellMeWhen_StackEditorFrameMaxCheck

	if StackMin:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"StackMin") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["StackMin"] = StackMin:GetValue()
	end
	if StackMax:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"StackMax") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["StackMax"] = StackMax:GetValue()
	end
	if StackMinCheck:GetChecked() ~= TellMeWhen_GetIconSetting(groupID,iconID,"StackMinEnabled") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["StackMinEnabled"] = not not StackMinCheck:GetChecked()
	end
	if StackMaxCheck:GetChecked() ~= TellMeWhen_GetIconSetting(groupID,iconID,"StackMaxEnabled") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["StackMaxEnabled"] = not not StackMaxCheck:GetChecked()
	end
end

function TellMeWhen_Stack_Reset()
	local StackMin = TellMeWhen_StackEditorFrameMinSlider
	local StackMax = TellMeWhen_StackEditorFrameMaxSlider
	
	StackMin:Disable()
	StackMin:SetAlpha(.4)
	StackMax:Disable()
	StackMax:SetAlpha(.4)
	TellMeWhen_StackEditorFrameMinCheck:SetChecked(false)
	TellMeWhen_StackEditorFrameMaxCheck:SetChecked(false)
	
	StackMin:SetMinMaxValues(max(0,(TMW.Icon_Defaults.StackMin-20)),max(20,(TMW.Icon_Defaults.StackMin+20)))
	StackMax:SetMinMaxValues(max(0,(TMW.Icon_Defaults.StackMax-20)),max(20,(TMW.Icon_Defaults.StackMax+20)))
	StackMin:SetValue(TMW.Icon_Defaults.StackMin)
	StackMax:SetValue(TMW.Icon_Defaults.StackMax)
	StackMin:SetMinMaxValues(max(0,(StackMin:GetValue()-20)),max(20,(StackMin:GetValue()+20)))
	StackMax:SetMinMaxValues(max(0,(StackMax:GetValue()-20)),max(20,(StackMax:GetValue()+20)))
	TellMeWhen_Editor_OnCheckOrChange()
end

function TellMeWhen_Stack_Load()
	TellMeWhen_Stack_Reset()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	
	local StackMin = TellMeWhen_StackEditorFrameMinSlider
	local StackMax = TellMeWhen_StackEditorFrameMaxSlider
	local StackMinCheck = TellMeWhen_StackEditorFrameMinCheck
	local StackMaxCheck = TellMeWhen_StackEditorFrameMaxCheck
	
	local MinVal = TellMeWhen_GetIconSetting(groupID,iconID,"StackMin")
	local MaxVal = TellMeWhen_GetIconSetting(groupID,iconID,"StackMax")
	StackMin:SetMinMaxValues(max(0,(MinVal-20)),max(20,(MinVal+20)))
	StackMax:SetMinMaxValues(max(0,(MaxVal-20)),max(20,(MaxVal+20)))
	StackMin:SetValue(MinVal)
	StackMax:SetValue(MaxVal)
	StackMinCheck:SetChecked(TellMeWhen_GetIconSetting(groupID,iconID,"StackMinEnabled"))
	StackMaxCheck:SetChecked(TellMeWhen_GetIconSetting(groupID,iconID,"StackMaxEnabled"))
	StackMin:SetMinMaxValues(max(0,(StackMin:GetValue()-20)),max(20,(StackMin:GetValue()+20)))
	StackMax:SetMinMaxValues(max(0,(StackMax:GetValue()-20)),max(20,(StackMax:GetValue()+20)))
	if StackMinCheck:GetChecked() then
		StackMin:Enable()
		StackMin:SetAlpha(1)
	else
		StackMin:Disable()
		StackMin:SetAlpha(.4)
	end
	if StackMaxCheck:GetChecked() then
		StackMax:Enable()
		StackMax:SetAlpha(1)
	else
		StackMax:Disable()
		StackMax:SetAlpha(.4)
	end
	TellMeWhen_Editor_OnCheckOrChange()
end


function TellMeWhen_Duration_Init()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	TellMeWhen_DurationEditorFrameFS1:SetText(L["DURATIONPANEL_TITLE"])
	TellMeWhen_DurationEditorFrameMinSliderText:SetText(MINIMUM)
	TellMeWhen_DurationEditorFrameMaxSliderText:SetText(MAXIMUM)
	
	TT(TellMeWhen_DurationEditorFrameMinSlider,L["ICONMENU_DURATION_MIN_DESC"])
	TT(TellMeWhen_DurationEditorFrameMaxSlider,L["ICONMENU_DURATION_MAX_DESC"])
end

function TellMeWhen_Duration_OK()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	local DurationMin = TellMeWhen_DurationEditorFrameMinSlider
	local DurationMax = TellMeWhen_DurationEditorFrameMaxSlider
	local DurationMinCheck = TellMeWhen_DurationEditorFrameMinCheck
	local DurationMaxCheck = TellMeWhen_DurationEditorFrameMaxCheck

	if DurationMin:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"DurationMin") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["DurationMin"] = DurationMin:GetValue()
	end
	if DurationMax:GetValue() ~= TellMeWhen_GetIconSetting(groupID,iconID,"DurationMax") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["DurationMax"] = DurationMax:GetValue()
	end
	if DurationMinCheck:GetChecked() ~= TellMeWhen_GetIconSetting(groupID,iconID,"DurationMinEnabled") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["DurationMinEnabled"] = not not DurationMinCheck:GetChecked()
	end
	if DurationMaxCheck:GetChecked() ~= TellMeWhen_GetIconSetting(groupID,iconID,"DurationMaxEnabled") then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID]["DurationMaxEnabled"] = not not DurationMaxCheck:GetChecked()
	end
end

function TellMeWhen_Duration_Reset()
	local DurationMin = TellMeWhen_DurationEditorFrameMinSlider
	local DurationMax = TellMeWhen_DurationEditorFrameMaxSlider
	
	DurationMin:Disable()
	DurationMin:SetAlpha(.4)
	DurationMax:Disable()
	DurationMax:SetAlpha(.4)
	TellMeWhen_DurationEditorFrameMinCheck:SetChecked(false)
	TellMeWhen_DurationEditorFrameMaxCheck:SetChecked(false)
	
	DurationMin:SetMinMaxValues(max(0,(TMW.Icon_Defaults.DurationMin-20)),max(20,(TMW.Icon_Defaults.DurationMin+20)))
	DurationMax:SetMinMaxValues(max(0,(TMW.Icon_Defaults.DurationMax-20)),max(20,(TMW.Icon_Defaults.DurationMax+20)))
	DurationMin:SetValue(TMW.Icon_Defaults.DurationMin)
	DurationMax:SetValue(TMW.Icon_Defaults.DurationMax)
	DurationMin:SetMinMaxValues(max(0,(DurationMin:GetValue()-20)),max(20,(DurationMin:GetValue()+20)))
	DurationMax:SetMinMaxValues(max(0,(DurationMax:GetValue()-20)),max(20,(DurationMax:GetValue()+20)))
	TellMeWhen_Editor_OnCheckOrChange()
end

function TellMeWhen_Duration_Load()
	TellMeWhen_Duration_Reset()
	local groupID,iconID = TMW.CEI.g,TMW.CEI.i
	
	local DurationMin = TellMeWhen_DurationEditorFrameMinSlider
	local DurationMax = TellMeWhen_DurationEditorFrameMaxSlider
	local DurationMinCheck = TellMeWhen_DurationEditorFrameMinCheck
	local DurationMaxCheck = TellMeWhen_DurationEditorFrameMaxCheck
	
	local MinVal = TellMeWhen_GetIconSetting(groupID,iconID,"DurationMin")
	local MaxVal = TellMeWhen_GetIconSetting(groupID,iconID,"DurationMax")
	DurationMin:SetMinMaxValues(max(0,(MinVal-20)),max(20,(MinVal+20)))
	DurationMax:SetMinMaxValues(max(0,(MaxVal-20)),max(20,(MaxVal+20)))
	DurationMin:SetValue(MinVal)
	DurationMax:SetValue(MaxVal)
	DurationMinCheck:SetChecked(TellMeWhen_GetIconSetting(groupID,iconID,"DurationMinEnabled"))
	DurationMaxCheck:SetChecked(TellMeWhen_GetIconSetting(groupID,iconID,"DurationMaxEnabled"))
	DurationMin:SetMinMaxValues(max(0,(DurationMin:GetValue()-20)),max(20,(DurationMin:GetValue()+20)))
	DurationMax:SetMinMaxValues(max(0,(DurationMax:GetValue()-20)),max(20,(DurationMax:GetValue()+20)))
	if DurationMinCheck:GetChecked() then
		DurationMin:Enable()
		DurationMin:SetAlpha(1)
	else
		DurationMin:Disable()
		DurationMin:SetAlpha(.4)
	end
	if DurationMaxCheck:GetChecked() then
		DurationMax:Enable()
		DurationMax:SetAlpha(1)
	else
		DurationMax:Disable()
		DurationMax:SetAlpha(.4)
	end
	TellMeWhen_Editor_OnCheckOrChange()
end


function TellMeWhen_Editor_Init()
	TellMeWhen_EditorFrameCancelButton:SetText(CANCEL)
	TellMeWhen_EditorFrameOkayButton:SetText(OKAY)
	TellMeWhen_EditorFrameFS1:SetText(L["EDITORPANEL_TITLE"] .. ": " .. (format(L["GROUPICON"],TMW.CEI.g,TMW.CEI.i)))
end

function TellMeWhen_Editor_OK()
	TellMeWhen_Alpha_OK()
	TellMeWhen_Duration_OK()
	TellMeWhen_Stack_OK()
end

function TellMeWhen_Editor_Load()
	TellMeWhen_EditorFrameIconTexture:SetTexture(_G["TellMeWhen_Group" .. TMW.CEI.g .. "_Icon" .. TMW.CEI.i].texture:GetTexture())
	TellMeWhen_EditorFrameFS1:SetText(L["EDITORPANEL_TITLE"] .. ": " .. (format(L["GROUPICON"],TMW.CEI.g,TMW.CEI.i)))
	TellMeWhen_Alpha_Load()
	TellMeWhen_Duration_Load()
	TellMeWhen_Stack_Load()
	TellMeWhen_EditorFrame:Show()
	TellMeWhen_EditorFrame:SetFrameLevel(110)
	TellMeWhen_Editor_OnCheckOrChange()
end

function TellMeWhen_Editor_OnCheckOrChange()
	if not TMW.Initd then return end
	if TellMeWhen_DurationEditorFrameMinCheck:GetChecked()
	or TellMeWhen_DurationEditorFrameMaxCheck:GetChecked() then
		TellMeWhen_DurationEditorFrameFS1:SetText("|cFFFF5959" .. L["DURATIONPANEL_TITLE"] .. "|r")
	else
		TellMeWhen_DurationEditorFrameFS1:SetText(L["DURATIONPANEL_TITLE"])
	end
	
	if TellMeWhen_StackEditorFrameMinCheck:GetChecked()
	or TellMeWhen_StackEditorFrameMaxCheck:GetChecked() then
		TellMeWhen_StackEditorFrameFS1:SetText("|cFFFF5959" .. L["STACKSPANEL_TITLE"] .. "|r")
	else
		TellMeWhen_StackEditorFrameFS1:SetText(L["STACKSPANEL_TITLE"])
	end
	
	if TellMeWhen_AlphaEditorFrameAlphaSlider:GetValue() ~= 100
	or TellMeWhen_AlphaEditorFrameUnAlphaSlider:GetValue() ~= 100
	or TellMeWhen_AlphaEditorFrameStackSlider:GetValue() ~= 0
	or TellMeWhen_AlphaEditorFrameDurationSlider:GetValue() ~= 0
	or TellMeWhen_AlphaEditorFrameConditionAlphaSlider:GetValue() ~= 0
	or TellMeWhen_AlphaEditorFrameFakeHidden:GetChecked() then
		TellMeWhen_AlphaEditorFrameFS1:SetText("|cFFFF5959" .. L["ALPHAPANEL_TITLE"] .. "|r")
	else
		TellMeWhen_AlphaEditorFrameFS1:SetText(L["ALPHAPANEL_TITLE"])
	end
	
	
	local height = 245
	if TellMeWhen_StackEditorFrame:IsShown() then
		height = height + 90
	end
	if TellMeWhen_DurationEditorFrame:IsShown() then
		height = height + 90
	end
	TellMeWhen_EditorFrame:SetHeight(height)
end


function TellMeWhen_Equiv_OnEnter(self)
	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	GameTooltip:AddLine(L["CHOOSENAME_EQUIVS_TOOLTIP"], 1, 1, 1, 1)
	GameTooltip:Show()
end

function TellMeWhen_Equiv_Select(frame)
	if (UIDROPDOWNMENU_MENU_LEVEL == 2) then
		if TMW.BE[UIDROPDOWNMENU_MENU_VALUE] then
			for k,v in pairs(TMW.BE[UIDROPDOWNMENU_MENU_VALUE]) do
				local info = UIDropDownMenu_CreateInfo()
				info.func = TellMeWhen_Equiv_Insert
				info.text = L[k]
				info.tooltipTitle = k
				local text = TellMeWhen_Equivs_GenerateTips(UIDROPDOWNMENU_MENU_VALUE,k)
				info.tooltipText = text
				info.tooltipOnButton = true
				info.value = k
				info.notCheckable = true
				UIDropDownMenu_AddButton(info,2)
			end
		elseif UIDROPDOWNMENU_MENU_VALUE == "dispel" then
			for k,v in pairs(TMW.DS) do
				local info = UIDropDownMenu_CreateInfo()
				info.func = TellMeWhen_Equiv_Insert
				info.text = L[k]
				info.value = k
				info.notCheckable = true
				UIDropDownMenu_AddButton(info,2)
			end
		end
		return
	end
	local info = UIDropDownMenu_CreateInfo()
	info.text = L["ICONMENU_BUFF"]
	info.value = "buffs"
	info.hasArrow = true
	info.colorCode = "|cFF00FF00"
	info.notCheckable = true
	UIDropDownMenu_AddButton(info)

	--some stuff is reused for this one
	info.text = L["ICONMENU_DEBUFF"]
	info.value = "debuffs"
	info.colorCode = "|cFFFF0000"
	UIDropDownMenu_AddButton(info)

	info.text = L["ICONMENU_CASTS"]
	info.value = "casts"
	info.colorCode = nil
	UIDropDownMenu_AddButton(info)
	
	info.text = L["ICONMENU_DISPEL"]
	info.value = "dispel"
	UIDropDownMenu_AddButton(info)
	
	UIDropDownMenu_JustifyText(frame, "LEFT")
end

function TellMeWhen_Equiv_Insert(self)
	local e = TellMeWhen_ChooseNameFrameEditBox
	local str = self.value
	e:Insert(";" .. str .. ";")
	e:SetText(TellMeWhen_CleanString(e:GetText()))
	CloseDropDownMenus()
end


-- -------------
-- RESIZE BUTTON
-- -------------

function TellMeWhen_Group_ResizeOnEnter(self, shortText, longText)
	local tooltip = _G["GameTooltip"]
	if (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(tooltip, self)
		tooltip:AddLine(L[shortText], HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1)
		tooltip:AddLine(L[longText], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1)
		tooltip:Show()
	else
		tooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		tooltip:SetText(L[shortText])
	end
end

function TellMeWhen_Group_StartSizing(self, button)
	local scalingFrame = self:GetParent()
	scalingFrame.oldScale = scalingFrame:GetScale()
	self.oldCursorX, self.oldCursorY = GetCursorPosition(UIParent)
	scalingFrame.oldX = scalingFrame:GetLeft()
	scalingFrame.oldY = scalingFrame:GetTop()
	self:SetScript("OnUpdate", TellMeWhen_Group_SizeUpdate)
end

function TellMeWhen_Group_SizeUpdate(self)
	local uiScale = UIParent:GetScale()
	local scalingFrame = self:GetParent()
	local cursorX, cursorY = GetCursorPosition(UIParent)

	-- calculate new scale
	local newXScale = scalingFrame.oldScale * (cursorX/uiScale - scalingFrame.oldX*scalingFrame.oldScale) / (self.oldCursorX/uiScale - scalingFrame.oldX*scalingFrame.oldScale)
	local newYScale = scalingFrame.oldScale * (cursorY/uiScale - scalingFrame.oldY*scalingFrame.oldScale) / (self.oldCursorY/uiScale - scalingFrame.oldY*scalingFrame.oldScale)
	local newScale = max(0.6, newXScale, newYScale)
	scalingFrame:SetScale(newScale)

	-- calculate new frame position
	local newX = scalingFrame.oldX * scalingFrame.oldScale / newScale
	local newY = scalingFrame.oldY * scalingFrame.oldScale / newScale
	scalingFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", newX, newY)
end

function TellMeWhen_Group_StopSizing(self, button)
	self:SetScript("OnUpdate", nil)
	local scalingFrame = self:GetParent()
	TellMeWhen_Settings.Groups[scalingFrame:GetID()]["Scale"] = scalingFrame:GetScale()
	local p = TellMeWhen_Settings.Groups[scalingFrame:GetID()]["Point"]
	p.point,_,p.relativePoint,p.x,p.y = scalingFrame:GetPoint(1)
	TellMeWhen_Settings.Groups[scalingFrame:GetID()]["Point"] = p

end

function TellMeWhen_Group_StopMoving(self, button)
	local scalingFrame = self:GetParent()
	scalingFrame:StopMovingOrSizing()
	local p = TellMeWhen_Settings.Groups[scalingFrame:GetID()]["Point"]
	p.point,_,p.relativePoint,p.x,p.y = scalingFrame:GetPoint(1)
	TellMeWhen_Settings.Groups[scalingFrame:GetID()]["Point"] = p
end


-- -----------------------
-- CONDITION EDITOR DIALOG
-- -----------------------

TMW.CondtMenu_Types={
	{ text=HEALTH, 						value="HEALTH", 	percent=true,	min=0,	max=100,												},
	{ text=L["CONDITIONPANEL_POWER"], 	value="DEFAULT", 	percent=true,	min=0,	max=100, 	tooltip=L["CONDITIONPANEL_POWER_DESC"],		},
	{ text=MANA, 						value="MANA",		percent=true,	min=0,	max=100,												},
	{ text=ENERGY, 						value="ENERGY",		percent=true,	min=0,	max=100,												},
	{ text=RAGE, 						value="RAGE",		percent=true,	min=0,	max=100,												},
	{ text=FOCUS, 						value="FOCUS",		percent=true,	min=0,	max=100,												},
	{ text=RUNIC_POWER, 				value="RUNIC_POWER",percent=true,	min=0,	max=100,												},
	{ text=L["CONDITIONPANEL_COMBO"], 	value="COMBO", 		percent=false, 	min=0, 	max=5, 													},
	{ text=L["CONDITIONPANEL_EXISTS"],	value="EXISTS",		percent=false,	min=0,	max=1,		bool=true,	nooperator=true,	tooltip=L["CONDITIONPANEL_EXISTS_DESC"], 	},
	{ text=L["CONDITIONPANEL_ALIVE"],	value="ALIVE",		percent=false, 	min=0,	max=1,		bool=true,	nooperator=true,	tooltip=L["CONDITIONPANEL_ALIVE_DESC"], 	},
	{ text=L["CONDITIONPANEL_COMBAT"],	value="COMBAT",		percent=false, 	min=0,	max=1,		bool=true,	nooperator=true,												},
	{ text=L["ICONMENU_REACT"],			value="REACT",		percent=false, 	min=1,	max=2,		mint=L["ICONMENU_HOSTILE"], maxt=L["ICONMENU_FRIEND"], nooperator=true,		},
	{ text=L["UIPANEL_SPEC"],			value="SPEC",		percent=false, 	min=1,	max=2,		mint=L["UIPANEL_PRIMARYSPEC"], maxt=L["UIPANEL_SECONDARYSPEC"], nooperator=true,unit=PLAYER},
	{ text=L["CONDITIONPANEL_ICON"], 	value="ICON",		percent=false,	min=0,	max=1, 		bool=true,	isicon=true, nooperator=true, tooltip=L["CONDITIONPANEL_ICON_DESC"], },
}

TMW.CondtMenu_Operators={
	{ text=L["CONDITIONPANEL_EQUALS"], 		value="==" 	},
	{ text=L["CONDITIONPANEL_NOTEQUAL"], 	value="~=" 	},
	{ text=L["CONDITIONPANEL_LESS"], 		value="<" 	},
	{ text=L["CONDITIONPANEL_LESSEQUAL"], 	value="<=" 	},
	{ text=L["CONDITIONPANEL_GREATER"], 	value=">" 	},
	{ text=L["CONDITIONPANEL_GREATEREQUAL"],value=">=" 	},
}

TMW.CondtMenu_AndOrs={
	{ text=L["CONDITIONPANEL_AND"], value="AND" },
	{ text=L["CONDITIONPANEL_OR"], 	value="OR" 	},
}

if pclass=="WARLOCK" then
	tinsert(TMW.CondtMenu_Types,{ text=SOUL_SHARDS, value="SOUL_SHARDS", percent=false, min=0, max=3, unit=PLAYER,})
elseif pclass=="DRUID" then
	tinsert(TMW.CondtMenu_Types,{ text=ECLIPSE, value="ECLIPSE", percent=false, min=-100, max=100, mint="-100 ("..L["MOON"].. ")", maxt="-100 ("..L["SUN"].. ")", unit=PLAYER, tooltip=L["CONDITIONPANEL_ECLIPSE_DESC"], })
	tinsert(TMW.CondtMenu_Types,{ text=L["ECLIPSE_DIRECTION"], value="ECLIPSE_DIRECTION", percent=false, min=0, max=1, mint=L["MOON"], maxt=L["SUN"], unit=PLAYER, nooperator=true})
elseif pclass=="HUNTER" then
	tinsert(TMW.CondtMenu_Types,{ text=HAPPINESS, value="HAPPINESS", percent=false, min=1, max=3, mint=PET_HAPPINESS1, maxt=PET_HAPPINESS3, unit=PET })
elseif pclass=="PALADIN" then
	tinsert(TMW.CondtMenu_Types,{ text=HOLY_POWER, value="HOLY_POWER", percent=false, min=0, max=3, unit=PLAYER, })
end

function TellMeWhen_Conditions_TypeMenuOnClick(self, frame, i)
	UIDropDownMenu_SetSelectedValue(frame, self.value)
	local num = frame:GetParent():GetID()
	local group = _G["TellMeWhen_ConditionEditorGroup" .. num]
	local showval = TellMeWhen_Conditions_Typecheck(num,TMW.CondtMenu_Types[i].unit,TMW.CondtMenu_Types[i].isicon, TMW.CondtMenu_Types[i].nooperator, TMW.CondtMenu_Types[i].noslide)
	TellMeWhen_Conditions_SetSliderMinMax(group.Slider)
	if showval then
		TellMeWhen_Conditions_SetValText(group.Slider)
	else
		group.ValText:SetText("")
	end

end

function TellMeWhen_Conditions_TypeMenu(frame)
	for k,v in pairs(TMW.CondtMenu_Types) do
		local info = UIDropDownMenu_CreateInfo()
		info.func = TellMeWhen_Conditions_TypeMenuOnClick
		info.text = v.text
		info.tooltipTitle = v.text
		info.tooltipText = v.tooltip
		info.tooltipOnButton = true
		info.value = v.value
		info.arg1 = frame
		info.arg2 = k
		UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_JustifyText(frame, "LEFT")
end


function TellMeWhen_Conditions_UnitMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value)
end

function TellMeWhen_Conditions_UnitMenu(frame)
	for k,v in pairs(TMW.IconMenu_SubMenus.Unit) do
		local info = UIDropDownMenu_CreateInfo()
		info.func = TellMeWhen_Conditions_UnitMenuOnClick
		info.text = v.text
		info.value = v.value
		info.hasArrow = v.hasArrow
		info.arg1 = frame
		UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_JustifyText(frame, "LEFT")
end


function TellMeWhen_Conditions_IconMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value)
end

function TellMeWhen_Conditions_IconMenu(frame)
	for k,v in pairs(TMW.Icons) do
		local info = UIDropDownMenu_CreateInfo()
		info.func = TellMeWhen_Conditions_IconMenuOnClick
		local g,i = strmatch(v, "TellMeWhen_Group(%d+)_Icon(%d+)")
		g,i = tonumber(g),tonumber(i)
		local text,textshort = TellMeWhen_GetIconMenuDropDownText(g,i)
		if strlen(text) > 35 then textshort = textshort .. "..." end
		info.text = textshort
		info.value = v
		info.tooltipTitle = text
		info.tooltipText = string.format(L["GROUPICON"], g,i)
		info.tooltipOnButton = true
		info.arg1 = frame
		UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_JustifyText(frame, "LEFT")
end


function TellMeWhen_Conditions_OperatorMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value)
end

function TellMeWhen_Conditions_OperatorMenu(frame)
	for k,v in pairs(TMW.CondtMenu_Operators) do
		local info = UIDropDownMenu_CreateInfo()
		info.func = TellMeWhen_Conditions_OperatorMenuOnClick
		info.text = v.text
		info.value = v.value
		info.arg1 = frame
		UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_JustifyText(frame, "LEFT")
end


function TellMeWhen_Conditions_AndOrMenuOnClick(self, frame)
	UIDropDownMenu_SetSelectedValue(frame, self.value)
end

function TellMeWhen_Conditions_AndOrMenu(frame)
	for k,v in pairs(TMW.CondtMenu_AndOrs) do
		local info = UIDropDownMenu_CreateInfo()
		info.func = TellMeWhen_Conditions_AndOrMenuOnClick
		info.text = v.text
		info.value = v.value
		info.arg1 = frame
		UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_JustifyText(frame, "CENTER")
end


function TellMeWhen_Conditions_CheckboxHandler()
	local i=1
	while _G["TellMeWhen_ConditionEditorGroup" .. i] do
		if _G["TellMeWhen_ConditionEditorGroup" .. i+1] then
			if (_G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:GetChecked()) then
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Show()
				_G["TellMeWhen_ConditionEditorGroup" .. i+1 .. "Check"]:Show()
			else
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Hide()
				_G["TellMeWhen_ConditionEditorGroup" .. i+1 .. "Check"]:Hide()
				_G["TellMeWhen_ConditionEditorGroup" .. i+1 .. "Check"]:SetChecked(false)
			end
		else -- this handles the last one in the frame
			if (_G["TellMeWhen_ConditionEditorGroup" .. i .. "Check"]:GetChecked()) then
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Show()
				TellMeWhen_Conditions_CreateGroups(i+1)
			else
				_G["TellMeWhen_ConditionEditorGroup" .. i]:Hide()
			end
		end
		i=i+1
	end
end

function TellMeWhen_Conditions_CondtOk(i,conditionstemp)
	local group = _G["TellMeWhen_ConditionEditorGroup" .. i]
	if (group.Check:GetChecked()) then
		local condition = {
			Type		= "HEALTH",
			Unit		= "player",
			Operator	= "==",
			Level		= 0,
			Icon		= "",
			AndOr		= "AND",
		}
		condition.Type = UIDropDownMenu_GetSelectedValue(group.Type) or "HEALTH"
		condition.Unit = UIDropDownMenu_GetSelectedValue(group.Unit) or "player"
		condition.Operator = UIDropDownMenu_GetSelectedValue(group.Operator) or "=="
		condition.Icon = UIDropDownMenu_GetSelectedValue(group.Icon) or ""
		condition.Level = tonumber(group.Slider:GetValue()) or 0
		condition.AndOr = UIDropDownMenu_GetSelectedValue(group.AndOr) or "AND"

		table.insert(conditionstemp, condition)
		i=i+1
		if (i <= TELLMEWHEN_MAXCONDITIONS) and (group.Check:GetChecked()) then
			return TellMeWhen_Conditions_CondtOk(i,conditionstemp)
		else
			return conditionstemp or {}
		end
	else
		return conditionstemp or {}
	end
end

function TellMeWhen_Conditions_EditorOkayOnClick()
	local groupID = TMW.CCnI.g
	local iconID = TMW.CCnI.i
	conditionstemp = {}
	local conditions = TellMeWhen_Conditions_CondtOk(1,conditionstemp)
	TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] = conditions
	local icon = _G["TellMeWhen_Group"..groupID.."_Icon"..iconID]
	TellMeWhen_Icon_Update(icon, groupID, iconID)
end

function TellMeWhen_Conditions_LoadCondt(i,conditions)
	local group = _G["TellMeWhen_ConditionEditorGroup" .. i]
	if (#conditions >= i) then
		TellMeWhen_Conditions_SetUIDropdownText(group.Type, conditions[i].Type, TMW.CondtMenu_Types)
		TellMeWhen_Conditions_SetUIDropdownText(group.Unit, conditions[i].Unit, TMW.IconMenu_SubMenus.Unit)
		TellMeWhen_Conditions_SetUIDropdownText(group.Icon, conditions[i].Icon, TMW.Icons)
		TellMeWhen_Conditions_SetUIDropdownText(group.Operator, conditions[i].Operator, TMW.CondtMenu_Operators)
		group.Slider:SetValue(conditions[i].Level or 0)
		TellMeWhen_Conditions_SetValText(group.Slider)
		group.Check:SetChecked(true)
		if i > 1 then
			TellMeWhen_Conditions_SetUIDropdownText(group.AndOr, conditions[i].AndOr, TMW.CondtMenu_AndOrs)
		end
	end
	i=i+1
	if (#conditions >= i) and (i <= TELLMEWHEN_MAXCONDITIONS) then
		TellMeWhen_Conditions_LoadCondt(i,conditions)
	end
end

function TellMeWhen_Conditions_LoadDialog()
	TellMeWhen_Conditions_ClearDialog()
	local groupID = TMW.CCnI.g
	local iconID = TMW.CCnI.i
	local conditions = TellMeWhen_GetIconSetting(groupID,iconID,"Conditions")
	TellMeWhen_Conditions_CreateGroups(#conditions)
	TMW.CurrConditions = conditions
	TellMeWhen_Conditions_LoadCondt(1,conditions)
	TellMeWhen_ConditionEditorFrameFS1:SetText(L["CONDITIONPANEL_TITLE"] .. ": " .. format(L["GROUPICON"],groupID,iconID))
	TellMeWhen_Conditions_CheckboxHandler()
	TellMeWhen_ConditionEditorFrame:Show()
	TellMeWhen_ConditionEditorFrame:SetFrameLevel(100)
end

function TellMeWhen_Conditions_ClearDialog()
	TellMeWhen_ConditionEditorScrollFrameScrollBar:Hide()
	for i=1,TELLMEWHEN_MAXCONDITIONS do
		local group = _G["TellMeWhen_ConditionEditorGroup" .. i]
		UIDropDownMenu_SetSelectedValue(group.Type, "HEALTH")
		UIDropDownMenu_SetSelectedValue(group.Unit, "player")
		UIDropDownMenu_SetSelectedValue(group.Icon, "")
		UIDropDownMenu_SetSelectedValue(group.Operator, "==")
		UIDropDownMenu_SetText(group.Type, "")
		UIDropDownMenu_SetText(group.Unit, "")
		UIDropDownMenu_SetText(group.Operator, "")
		group.Slider:SetValue(0)
		group.Check:SetChecked(false)
		group.Unit:Show()
		group.Operator:Show()
		group.Icon:Hide()
		TellMeWhen_Conditions_SetSliderMinMax(group.Slider)
		TellMeWhen_Conditions_SetValText(group.Slider)
	end
	for i=2,TELLMEWHEN_MAXCONDITIONS do
		local group = _G["TellMeWhen_ConditionEditorGroup" .. i]
		UIDropDownMenu_SetSelectedValue(group.AndOr, "AND")
		UIDropDownMenu_SetText(group.AndOr, "")
	end
	local groupID = TMW.CCnI.g
	local iconID = TMW.CCnI.i
	local conditions = TellMeWhen_GetIconSetting(groupID,iconID,"Conditions")
	TellMeWhen_ConditionEditorFrameFS1:SetText(L["CONDITIONPANEL_TITLE"] .. ": " .. format(L["GROUPICON"],groupID,iconID))
	TellMeWhen_ConditionEditorFrameIconTexture:SetTexture(_G["TellMeWhen_Group" .. groupID .. "_Icon" .. iconID].texture:GetTexture())
	TellMeWhen_Conditions_CheckboxHandler()
	TellMeWhen_ConditionEditorFrame:Show()
	TellMeWhen_ConditionEditorFrame:SetFrameLevel(100)
	TellMeWhen_Conditions_SetText()
end


function TellMeWhen_Conditions_CreateGroups(num)
	while _G["TellMeWhen_ConditionEditorGroup"..TELLMEWHEN_MAXCONDITIONS] do
		TELLMEWHEN_MAXCONDITIONS=TELLMEWHEN_MAXCONDITIONS+1
	end
	for i=TELLMEWHEN_MAXCONDITIONS,num do
		local condtgrp = _G["TellMeWhen_ConditionEditorGroup"..i] or CreateFrame("Frame","TellMeWhen_ConditionEditorGroup"..i,TellMeWhen_ConditionEditorGroups,"TellMeWhen_ConditionEditorGroup",i)
		condtgrp:SetPoint("TOPLEFT",_G["TellMeWhen_ConditionEditorGroup"..i-1],"BOTTOMLEFT",0,0)
		UIDropDownMenu_Initialize(condtgrp.Icon, TellMeWhen_Conditions_IconMenu, "DROPDOWN")
		condtgrp.Check:ClearAllPoints()
		condtgrp.Check:SetPoint("TOPLEFT",_G["TellMeWhen_ConditionEditorGroup"..i],17,10)
	end
	TELLMEWHEN_MAXCONDITIONS = num
	TellMeWhen_Conditions_SetText()
end

function TellMeWhen_Conditions_SetUIDropdownText(frame, value, tab)
	UIDropDownMenu_SetSelectedValue(frame, value)
	local num = frame:GetParent():GetID()
	TellMeWhen_Conditions_SetSliderMinMax(_G["TellMeWhen_ConditionEditorGroup" .. num .. "Slider"])
	if tab == TMW.CondtMenu_Types then
		for k,v in pairs(tab) do
			if (v.value == value) then
				TellMeWhen_Conditions_Typecheck(num,v.unit, v.isicon, v.nooperator, v.noslide)
			end
		end
	end
	if tab == TMW.Icons then
		for k,v in pairs(tab) do
			if (v == value) then
				UIDropDownMenu_SetText(frame, _G[v].Name)
				return
			end
		end
	end
	for k,v in pairs(tab) do
		if (v.value == value) then
			UIDropDownMenu_SetText(frame, v.text)
			return
		end
	end
	UIDropDownMenu_SetText(frame, "")
end

function TellMeWhen_Conditions_SetText(num)
	TellMeWhen_ConditionEditorFrameCancelButton:SetText(CANCEL)
	TellMeWhen_ConditionEditorFrameOkayButton:SetText(OKAY)
	for i=1,TELLMEWHEN_MAXCONDITIONS do
		if num then i=num end
		local group = _G["TellMeWhen_ConditionEditorGroup" .. i]
		if not (group and group.TextType) then return end
		group.TextType:SetText(L["CONDITIONPANEL_TYPE"])
		group.TextUnitOrIcon:SetText(L["CONDITIONPANEL_UNIT"])
		group.TextUnitDef:SetText("")
		group.TextOperator:SetText(L["CONDITIONPANEL_OPERATOR"])
		group.AndOrTxt:SetText(L["CONDITIONPANEL_ANDOR"])
		group.TextValue:SetText(L["CONDITIONPANEL_VALUEN"])
		if num then break end
	end
end

function TellMeWhen_Conditions_SetValText(self)
	if TMW.Initd then
		local val = self:GetValue()
		local type = UIDropDownMenu_GetSelectedValue(_G[self:GetParent():GetName() .. "Type"])
		if type == "ECLIPSE_DIRECTION" then
			if val == 0 then val = L["MOON"] end
			if val == 1 then val = L["SUN"] end
		end
		if type == "HAPPINESS" then
			val = _G["PET_HAPPINESS" .. val]
		end
		if type == "REACT" then
			if val == 0 then val = L["ICONMENU_EITHER"] end
			if val == 1 then val = L["ICONMENU_HOSTILE"] end
			if val == 2 then val = L["ICONMENU_FRIEND"] end
		end
		for k,v in pairs(TMW.CondtMenu_Types) do
			if (v.value == type) and (v.bool) then
				if val == 0 then val = L["TRUE"] end
				if val == 1 then val = L["FALSE"] end
			end
		end
		for k,v in pairs(TMW.CondtMenu_Types) do
			if (v.value == type) and (v.percent) then
				val = val .. "%"
			end
		end
		if _G[self:GetParent():GetName() .. "ValText"] then
			_G[self:GetParent():GetName() .. "ValText"]:SetText(val)
		end
	end
end

function TellMeWhen_Conditions_SetSliderMinMax(self)
	local type = UIDropDownMenu_GetSelectedValue(_G[self:GetParent():GetName() .. "Type"])
	for k,v in pairs(TMW.CondtMenu_Types) do
		if (v.value == type) then
			self:SetMinMaxValues(v.min,v.max)
			if v.bool then
				_G[self:GetName() .. "Low"]:SetText(L["TRUE"])
				_G[self:GetName() .. "High"]:SetText(L["FALSE"])
				break
			end
			_G[self:GetName() .. "Low"]:SetText(v.mint or v.min)
			_G[self:GetName() .. "Mid"]:SetText(v.midt or "")
			_G[self:GetName() .. "High"]:SetText(v.maxt or v.max)
			break
		end
	end
end

function TellMeWhen_Conditions_Typecheck(num,unit,isicon,nooperator,noslide)
	local group = _G["TellMeWhen_ConditionEditorGroup" .. num]
	group.Icon:Hide() --it bugs sometimes so just do it by default
	local showval = true
	TellMeWhen_Conditions_SetText(num)
	group.Unit:Show()
	if unit then
		group.Unit:Hide()
		group.TextUnitDef:SetText(unit)
	end
	if nooperator then
		group.TextOperator:SetText("")
		group.Operator:Hide()
	else
		group.Operator:Show()
	end
	if noslide then
		showval = false
		group.Slider:Hide()
		group.TextValue:SetText("")
		group.ValText:Hide()
	else
		group.ValText:Show()
		group.Slider:Show()
	end
	if isicon then
		group.TextUnitOrIcon:SetText(L["ICONTOCHECK"])
		group.Icon:Show()
		group.Unit:Hide()
	else
		group.Icon:Hide()
	end
	return showval
end


function TellMeWhen_MetaEditor_Reset()
	local groupID,iconID = TMW.CMI.g,TMW.CMI.i
	local i=1
	while _G["TellMeWhen_MetaEditorGroup" .. i] do
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_MetaEditorGroup" .. i].icon, nil)
		UIDropDownMenu_SetText(_G["TellMeWhen_MetaEditorGroup" .. i].icon,"")
		if i>1 then
			_G["TellMeWhen_MetaEditorGroup" .. i]:Hide()
		end
		i=i+1
	end
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons={}
	TellMeWhen_MetaEditor_Update()
end

function TellMeWhen_MetaEditor_UpOrDown(self,delta)
	local groupID,iconID = TMW.CMI.g,TMW.CMI.i
	local settings = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons
	local ID = self:GetParent():GetID()
	local curdata,destinationdata
	curdata = settings[ID]
	destinationdata = settings[ID+delta]
	settings[ID] = destinationdata
	settings[ID+delta] = curdata
	TellMeWhen_MetaEditor_Update()
end

function TellMeWhen_MetaEditor_Insert(self)
	local groupID,iconID = TMW.CMI.g,TMW.CMI.i
	local where = self:GetParent():GetID()+1
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons or {}
	if not TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[1] then
		TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[1] = TMW.Icons[1]
		UIDropDownMenu_SetSelectedValue(TellMeWhen_MetaEditorGroup1.icon, TMW.Icons[1])
		UIDropDownMenu_SetText(TellMeWhen_MetaEditorGroup1.icon,TMW.Icons[1])
	end
	tinsert(TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons,where,TMW.Icons[1])
	TellMeWhen_MetaEditor_Update()
end

function TellMeWhen_MetaEditor_Delete(self)
	local groupID,iconID = TMW.CMI.g,TMW.CMI.i
	local where = self:GetParent():GetID()
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons or {}
	local i=1
	local len=#TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons
	for i=where,len do
		TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[i] = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[i+1]
	end
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[len] = nil
	TellMeWhen_MetaEditor_Update()
end

function TellMeWhen_MetaEditor_Update()
	local groupID,iconID = TMW.CMI.g,TMW.CMI.i
	TellMeWhen_MetaEditorFrameFS1:SetText(L["METAPANEL_TITLE"] .. ": " .. format(L["GROUPICON"],groupID,iconID))
	TellMeWhen_MetaEditorFrameIconTexture:SetTexture(_G["TellMeWhen_Group" .. groupID .. "_Icon" .. iconID].texture:GetTexture())
	TellMeWhen_MetaEditorFrame:SetFrameLevel(130)
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons or {}
	local settings = TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons
	local i=1
	while _G["TellMeWhen_MetaEditorGroup" .. i] do
		UIDropDownMenu_SetSelectedValue(_G["TellMeWhen_MetaEditorGroup" .. i].icon, nil)
		UIDropDownMenu_SetText(_G["TellMeWhen_MetaEditorGroup" .. i].icon,"")
		_G["TellMeWhen_MetaEditorGroup" .. i].up:Show()
		_G["TellMeWhen_MetaEditorGroup" .. i].down:Show()
		_G["TellMeWhen_MetaEditorGroup" .. i]:Show()
		i=i+1
	end
	i=i-1 -- i is always the number of groups plus 1
	TellMeWhen_MetaEditorGroup1.up:Hide()
	TellMeWhen_MetaEditorGroup1.delete:Hide()
	local k=1
	for k,v in pairs(settings) do
		local mg = _G["TellMeWhen_MetaEditorGroup"..k]
		if not mg then
			mg = CreateFrame("Frame","TellMeWhen_MetaEditorGroup"..k,TellMeWhen_MetaEditorFrame,"TellMeWhen_MetaEditorGroup",k)
			TellMeWhen_MetaEditor_IconMenu(mg.icon)
		end
		mg:Show()
		mg:SetPoint("TOP",_G["TellMeWhen_MetaEditorGroup"..k-1],"BOTTOM",0,0)
		mg:SetFrameLevel(131)
		UIDropDownMenu_SetSelectedValue(mg.icon, v)
		local text = TellMeWhen_GetIconMenuDropDownText(strmatch(v, "TellMeWhen_Group(%d+)_Icon(%d+)"))
		UIDropDownMenu_SetText(mg.icon,text)
	end
	for f=#settings+1,i do
		_G["TellMeWhen_MetaEditorGroup" .. f]:Hide()
	end
	if #settings > 0 then
		_G["TellMeWhen_MetaEditorGroup" .. #settings].down:Hide()
	else
		TellMeWhen_MetaEditorGroup1.down:Hide()
	end
	TellMeWhen_MetaEditorGroup1:Show()
end

function TellMeWhen_MetaEditor_IconMenu(frame)
	for k,v in pairs(TMW.Icons) do
		local info = UIDropDownMenu_CreateInfo()
		info.func = TellMeWhen_MetaEditor_IconMenuOnClick
		local g,i = strmatch(v, "TellMeWhen_Group(%d+)_Icon(%d+)")
		local text,textshort = TellMeWhen_GetIconMenuDropDownText(g,i)
		info.text = textshort
		info.value = v
		info.tooltipTitle = text
		info.tooltipText = string.format(L["GROUPICON"], g,i)
		info.tooltipOnButton = true
		info.arg1 = frame
		UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_JustifyText(frame, "LEFT")
end

function TellMeWhen_MetaEditor_IconMenuOnClick(self, frame)
	local groupID,iconID = TMW.CMI.g,TMW.CMI.i
	TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[frame:GetParent():GetID()] = self.value
	UIDropDownMenu_SetSelectedValue(frame, self.value)
end



-- ----------
-- COPY PANEL
-- ----------

for i=1,TELLMEWHEN_MAXGROUPS do
	TMW.TempEnabled[i] = {
	["C"] = false,
	["E"] = false,
	["P"] = false,
	["S"] = false,
	}
end

function TellMeWhen_CopyPanel_Update(one)
	if TMW.Initd then
		local groupn = TellMeWhen_CopyFrameGroupSlider:GetValue()
		local iconn = TellMeWhen_CopyFrameIconSlider:GetValue()
		local curgroupID = TMW.CCoI.g
		local curiconID = TMW.CCoI.i
		TellMeWhen_CopyFrameTitleFS:SetText(L["COPYPANEL_TITLE"])
		TellMeWhen_CopyFrameCancelButton:SetText(CANCEL)
		TellMeWhen_CopyFrameOkayButton:SetText(L["COPY"])
		TellMeWhen_CopyFrameEnableGroupButton:SetText(string.format(L["GENABLEBUTTON"],groupn))
		TellMeWhen_CopyFrameGroupFS:SetText(L["COPYPANEL_GROUP"] .. groupn)
		TellMeWhen_CopyFrameIconFS:SetText(L["COPYPANEL_ICON"] .. iconn)
		TellMeWhen_CopyFrameFromFS:SetText(L["FROM"])
		TellMeWhen_CopyFrameToFS:SetText(L["TO"])
		TellMeWhen_CopyFrameFromNumbersFS:SetText(format(L["GROUPICON"],groupn,iconn))
		TellMeWhen_CopyFrameToNumbersFS:SetText(format(L["GROUPICON"],curgroupID,curiconID))
		local group = _G["TellMeWhen_Group".. groupn] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate")
		if one == 1 then
			TMW.TempEnabled[groupn]["C"] = true
			TMW.TempEnabled[groupn]["E"] = TellMeWhen_GetGroupSetting(group,"Enabled")
			TMW.TempEnabled[groupn]["P"] = group.PrimarySpec
			TMW.TempEnabled[groupn]["S"] = group.SecondarySpec
			TellMeWhen_Settings.Groups[groupn]["Enabled"] = true
			TellMeWhen_Settings.Groups[groupn]["PrimarySpec"] = true
			TellMeWhen_Settings.Groups[groupn]["SecondarySpec"] = true
			TellMeWhen_Update()
			TellMeWhen_CopyPanel_Update()
		end
		TellMeWhen_CopyFrameIconSlider:SetMinMaxValues(1,(group.Rows*group.Columns))
		if not group.Enabled then
			TellMeWhen_CopyFrameEnableGroupButton:Show()
			TellMeWhen_CopyFrameIconSlider:Hide()
		else
			TellMeWhen_CopyFrameEnableGroupButton:Hide()
			TellMeWhen_CopyFrameIconSlider:Show()
		end
		local fromicon = _G["TellMeWhen_Group".. groupn .. "_Icon" .. iconn]
		local toicon = _G["TellMeWhen_Group".. curgroupID .. "_Icon" .. curiconID]
		if fromicon then
			local fromtex = fromicon.texture:GetTexture()
			TellMeWhen_CopyFrameTextureFrom:SetTexture(fromtex)
			TellMeWhen_CopyFrameFromNameFS:SetText(gsub(gsub(fromicon.Name,"; ",";"),";","; ")) -- lets make sure that every semicolon has one space after it for clean formatting
		else
			TellMeWhen_CopyFrameTextureFrom:SetTexture(nil)
			TellMeWhen_CopyFrameFromNameFS:SetText("")
		end
		if toicon then
			local totex = toicon.texture:GetTexture()
			TellMeWhen_CopyFrameTextureTo:SetTexture(totex)
			TellMeWhen_CopyFrameToNameFS:SetText(gsub(gsub(toicon.Name,"; ",";"),";","; "))
		else
			TellMeWhen_CopyFrameTextureTo:SetTexture(nil)
			TellMeWhen_CopyFrameToNameFS:SetText("")
		end
		TellMeWhen_CopyFrame:SetFrameLevel(105)
	end
end

function TellMeWhen_CopyPanel_Copy()
	if TMW.Initd then
		local fromgroupid = TellMeWhen_CopyFrameGroupSlider:GetValue()
		local fromiconid = TellMeWhen_CopyFrameIconSlider:GetValue()
		local togroupID = TMW.CCoI.g
		local toiconID = TMW.CCoI.i
		local fromicon = _G["TellMeWhen_Group".. fromgroupid .. "_Icon" .. fromiconid]
		local toicon = _G["TellMeWhen_Group".. togroupID .. "_Icon" .. toiconID]
		local fromiconsettings = TellMeWhen_Settings.Groups[fromgroupid].Icons[fromiconid]
		TellMeWhen_Settings.Groups[togroupID].Icons[toiconID] = {}
		for k,v in pairs(fromiconsettings) do
			TellMeWhen_Settings.Groups[togroupID].Icons[toiconID][k] = fromiconsettings[k]
		end
		for a,b in pairs(TMW.TempEnabled) do
			if b["C"] == true then
				TellMeWhen_Settings.Groups[a]["Enabled"] = b["E"]
				TellMeWhen_Settings.Groups[a]["PrimarySpec"] = b["P"]
				TellMeWhen_Settings.Groups[a]["SecondarySpec"] = b["S"]
			end
		end
		for qqq=1,TELLMEWHEN_MAXGROUPS do
			TMW.TempEnabled[qqq] = {
			["C"] = false,
			["E"] = false,
			["P"] = false,
			["S"] = false,
			}
		end
		TellMeWhen_Update()
	end
	TellMeWhen_CopyFrame:Hide()
end

function TellMeWhen_CopyPanel_Cancel()
	if TMW.Initd then
		for a,b in pairs(TMW.TempEnabled) do
			if b["C"] == true then
				TellMeWhen_Settings.Groups[a]["Enabled"] = b["E"]
				TellMeWhen_Settings.Groups[a]["PrimarySpec"] = b["P"]
				TellMeWhen_Settings.Groups[a]["SecondarySpec"] = b["S"]
			end
		end
		for qqq=1,TELLMEWHEN_MAXGROUPS do
			TMW.TempEnabled[qqq] = {
			["C"] = false,
			["E"] = false,
			["P"] = false,
			["S"] = false,
			}
		end
		TellMeWhen_Update()
	end
	TellMeWhen_CopyFrame:Hide()
end
