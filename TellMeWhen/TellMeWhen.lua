-- --------------------
-- TellMeWhen
-- Originally by Nephthys of Hyjal <lieandswell@yahoo.com>
-- Other contributions by 
-- Oozebull of Twisting Nether
-- Banjankri of Blackrock
-- Predeter of Proudmoore
-- Xenyr of Aszune
-- Cybeloras of Mal'Ganis
-- --------------------

-- -------------
-- ADDON GLOBALS AND LOCALS
-- -------------

TMW = {...}
local TMW = TMW
TMW.Initd = false
TMW.Warns = {}
TMW.Icons = {}

TELLMEWHEN_VERSION = "2.4.1"
TELLMEWHEN_VERSION_MINOR = ""
TELLMEWHEN_MAXGROUPS = 10 	--this is used by SetTheory (addon), so dont rename
TELLMEWHEN_MAXROWS = 7
TELLMEWHEN_MAXCONDITIONS = 1 --this is a default
TELLMEWHEN_ICONSPACING = 0	--this is a default
local UPDATE_INTERVAL = 0.05	--this is a default, local because i use it in onupdate functions

local oldp = print
local function print(...)
	if TMW.TestOn then
		oldp("|cffff0000TMW:|r ", ...)
	end
end

local L = LibStub("AceLocale-3.0"):GetLocale("TellMeWhen", true)
local LBF = LibStub("LibButtonFacade", true)

local GetSpellCooldown, GetSpellInfo, IsUsableSpell, IsSpellInRange, GetSpellTexture = GetSpellCooldown, GetSpellInfo, IsUsableSpell, IsSpellInRange, GetSpellTexture
local GetItemCooldown, IsItemInRange = GetItemCooldown, IsItemInRange
local GetInventorySlotInfo, GetWeaponEnchantInfo, GetTotemInfo = GetInventorySlotInfo, GetWeaponEnchantInfo, GetTotemInfo
local SetValue, SetTexCoord, SetStatusBarColor, SetMinMaxValues = SetValue, SetTexCoord, SetStatusBarColor, SetMinMaxValues
local SetVertexColor, SetAlpha, GetAlpha, GetTexture, SetTexture = SetVertexColor, SetAlpha, GetAlpha, GetTexture, SetTexture
local UnitIsEnemy, UnitAura, UnitReaction, UnitExists, UnitPower, UnitHealth, UnitIsDeadOrGhost = UnitIsEnemy, UnitAura, UnitReaction, UnitExists, UnitPower, UnitHealth, UnitIsDeadOrGhost
local GetPetHappiness, GetEclipseDirection, GetComboPoints = GetPetHappiness, GetEclipseDirection, GetComboPoints
local GetActionCooldown, GetActionInfo, IsActionInRange, IsUsableAction = GetActionCooldown, GetActionInfo, IsActionInRange, IsUsableAction
local tonumber, tostring, type, pairs, tinsert = tonumber, tostring, type, pairs, tinsert 
local strfind, strmatch, format, gsub, strsub, strlower = strfind, strmatch, format, gsub, strsub, strlower
local _G = _G
local _,pclass = UnitClass("Player")
local st, co, rc, mc, us, un, pr, ab, GCDSpell
local TMW_CNDT,TMW_OP,TMW_AO = {},{},{},{},{},{}
local SlotsToNumbers = {
	MainHandSlot = 1,
	SecondaryHandSlot = 4,
	RangedSlot = 7,
}

TMW.Icon_Defaults = { --NEVER EVER EVER CHANGE ANY OF THESE OR ALL USER'S SETTINGS GET OWNED
	BuffOrDebuff		= "HELPFUL",
	BuffShowWhen		= "present",
	CooldownShowWhen	= "usable",
	CooldownType		= "spell",
	Enabled				= false,
	Name				= "",
	OnlyMine			= false,
	ShowTimer			= false,
	ShowTimerText		= true,
	ShowPBar			= false,
	ShowCBar			= false,
	InvertBars			= false,
	Type				= "",
	Unit				= "player",
	WpnEnchantType		= "MainHandSlot",
	Conditions			= {},
	Icons				= {},
	Alpha				= 1,
	UnAlpha				= 1,
	ConditionAlpha		= 0,
	RangeCheck			= false,
	ManaCheck			= false,
	CooldownCheck		= false,
	StackAlpha			= 0,
	StackMin			= 0,
	StackMax			= 100,
	StackMinEnabled		= false,
	StackMaxEnabled		= false,
	DurationMin			= 0,
	DurationMax			= 50,
	DurationMinEnabled	= false,
	DurationMaxEnabled	= false,
	DurationAlpha		= 0,
	FakeHidden			= false,
	HideUnequipped		= false,
	Interruptible		= false,
}

TMW.RelevantIconSettings = {
	all = {
		Enabled = true,
		Name = true,
		ShowTimer = true,
		ShowTimerText = true,
		ShowPBar = true,
		ShowCBar = true,
		InvertBars = true,
		Type = true,
		Conditions = true,
		Alpha = true,
		UnAlpha = true,
		ConditionAlpha = true,
		DurationMin = true,
		DurationMax = true,
		DurationMinEnabled = true,
		DurationMaxEnabled = true,
		DurationAlpha = true,
		FakeHidden = true,
	},
	cooldown = {
		CooldownShowWhen = true,
		CooldownType = true,
		RangeCheck = true,
		ManaCheck = true,
	},
	buff = {
		BuffOrDebuff = true,
		BuffShowWhen = true,
		OnlyMine = true,
		Unit = true,
		StackAlpha = true,
		StackMin = true,
		StackMax = true,
		StackMinEnabled = true,
		StackMaxEnabled = true,
	},
	reactive = {
		CooldownShowWhen = true,
		RangeCheck = true,
		ManaCheck = true,
		CooldownCheck = true,
	},
	wpnenchant = {
		HideUnequipped = true,
		WpnEnchantType = true,
		BuffShowWhen = true,
	},
	totem = {
		BuffShowWhen = true,
	},
	multistatecd = {
		CooldownShowWhen = true,
		RangeCheck = true,
		ManaCheck = true,
	},
	cast = {
		BuffShowWhen = true,
		Interruptible = true,
		Unit = true,
	},
	meta = {
		Icons = true,
	}
}

TMW.Condition_Defaults = {
	AndOr = "AND",
	Type = "HEALTH",
	Icon = "",
	Operator = "==",
	Level = 0,
	Unit = "player",
}

TMW.Icon_DeletedSettings = { --Add obsolete settings here and run TellMeWhen_CondenseSettings()
	OORColor = true,
	OOMColor = true,
	Color = true,
	ColorOverride = true,
	UnColor = true,
	DurationAndCD = true,
	Shapeshift = true, -- i used this one during some initial testing for shapeshifts
}

TMW.Group_Defaults = {
	Enabled			= false,
	Scale			= 2.0,
	Rows			= 1,
	Columns			= 4,
	Icons			= {},
	OnlyInCombat	= false,
	NotInVehicle	= false,
	PrimarySpec		= true,
	SecondarySpec	= true,
	Stance			= {},
	Point			= {},
	LBF				= {},
}

TMW.Defaults = {
	Version 		= 	TELLMEWHEN_VERSION,
	Locked 			= 	false,
	Groups 			= 	{},
	Interval		=	UPDATE_INTERVAL,
	CDCOColor 		= 	{r=0,g=1,b=0,a=1},
	CDSTColor 		= 	{r=1,g=0,b=0,a=1},
	USEColor		=	{r=1,g=1,b=1,a=1},
	UNUSEColor		=	{r=1,g=1,b=1,a=1},
	PRESENTColor	=	{r=1,g=1,b=1,a=1},
	ABSENTColor		=	{r=1,g=0.35,b=0.35,a=1},
	OORColor		=	{r=0.5,g=0.5,b=0.5,a=1},
	OOMColor		=	{r=0.5,g=0.5,b=0.5,a=1},
	Spacing			=	TELLMEWHEN_ICONSPACING,
	Texture			=	"Interface\\TargetingFrame\\UI-StatusBar",
	TextureName 	= 	"Blizzard",
	DrawEdge		=	false,
	TestOn 			= 	false,
	Font 			= 	{
							Path = "Fonts\\ARIALN.TTF",
							Name = "Arial Narrow",
							Size = 12,
							Outline = "THICK",
						},
}

TMW.BE = {	--Much of these are thanks to Malazee @ Petopia's chart: http://img204.imageshack.us/img204/4902/cataraiTellMeWhen_Settingsuffs.jpg and spreadsheet https://spreadsheets.google.com/ccc?key=0Aox2ZHZE6e_SdHhTc0tZam05QVJDU0lONnp0ZVgzdkE&hl=en#gid=18
	debuffs = {
		CrowdControl = "339;2637;33786;118;61305;28272;61721;61780;28271;1499;60192;19503;19386;20066;10326;9484;6770;2094;51514;76780;710;5782;6358", -- by calico0 of Curse
		Bleeding = "9007;1822;1079;33745;1943;703;94009;43104;89775",
		Incapacitated = "1776;20066;49203",
		Feared = "5782;5246;8122;10326;1513;5484;6789",
		Stunned = "1833;408;91800;5211;9005;22570;19577;56626;44572;82691;90337;853;2812;85388;64044;20549;46968;30283;20252;65929;7922;12809;50519",
		--DontMelee = "5277;871;Retaliation;Dispersion;Hand of Sacrifice;Hand of Protection;Divine Shield;Divine Protection;Ice Block;Icebound Fortitude;Cyclone;Banish",  --does somebody want to update these for me?
		--MovementSlowed = "Incapacitating Shout;Chains of Ice;Icy Clutch;Slow;Daze;Hamstring;Piercing Howl;Wing Clip;Ice Trap;Frostbolt;Cone of Cold;Blast Wave;Mind Flay;Crippling Poison;Deadly Throw;Frost Shock;Earthbind;Curse of Exhaustion",
		Disoriented = "19503;31661;2094;51514",
		Silenced = "47476;78675;34490;55021;18469;31935;15487;1330;19647;18498;25046;80483;50613;28730;69179",
		Disarmed = "51722;676;64058;50541;91644",
		Rooted = "122;23694;58373;64695;19185;64803;4167;54706;50245;90327;16979;83301;83302",
		PhysicalDmgTaken = "30070;58683;81326;50518;55749",
		SpellDamageTaken = "93068;1490;65142;85547;60433;34889;24844",
		SpellCritTaken = "17800;22959",
		BleedDamageTaken = "33878;33876;16511;46857;50271;35290;57386",
		ReducedAttackSpeed = "6343;55095;58180;68055;8042;90314;50285",
		ReducedCastingSpeed = "1714;5760;31589;73975;50274;50498",
		ReducedArmor = "8647;50498;35387;91565;7386",
		ReducedHealing = "12294;13218;56112;48301;82654;30213;54680",
		ReducedPhysicalDone = "1160;99;26017;81130;702;24423",
	},
	buffs = {
		ImmuneToStun = "642;45438;34471;19574;48792;1022;33786;710",
		ImmuneToMagicCC = "642;45438;34471;19574;33786;710",
		IncreasedStats = "79061;79063;90363",
		IncreasedDamage = "75447;82930",
		IncreasedCrit = "24932;29801;51701;51470;24604;90309",
		IncreasedAP = "79102;53138;19506;30808",
		IncreasedSPsix = "79058;52109",
		IncreasedSPten = "77747;53646",
		IncreasedPhysHaste = "55610;53290;8515",
		IncreasedSpellHaste = "2895;24907;49868",
		BurstHaste = "2825;32182;80353;90355",
		BonusAgiStr = "6673;8076;57330;93435",
		BonusStamina = "79105;469;6307;90364",
		BonusArmor = "465;8072",
		BonusMana = "79058;54424",
		ManaRegen = "54424;79102;5677",
		BurstManaRegen = "29166;16191;64901",
		PushbackResistance = "19746;87717",
		Resistances = "19891;8185",
	},
	casts = {
		Heals = "50464;5185;8936;740;2050;2060;2061;32546;596;64843;635;82326;19750;331;77472;8004;1064;73920",
		PvPSpells = "33786;339;20484;1513;982;64901;605;453;5782;5484;79268;10326;51514;118;12051",
		Tier11Interrupts = "43088;82752;82636;83070;79710;77908;77569;80734",
	},
}

TMW.GCDSpells = {
	ROGUE=1752, -- sinister strike
	PRIEST=139, -- renew
	DRUID=774, -- rejuvenation
	WARRIOR=772, -- rend
	MAGE=133, -- fireball
	WARLOCK=687, -- demon armor
	PALADIN=20154, -- seal of righteousness
	SHAMAN=324, -- lightning shield
	HUNTER=1978, -- serpent sting
	DEATHKNIGHT=47541, -- death coil
}
GCDSpell = TMW.GCDSpells[pclass]

TMW.Chakra = {
	{abid = 88685, buffid = 81206}, 	-- sanctuary, prayer of healing,mending
	{abid = 88684, buffid = 81208},		-- serenity, heal
	{abid = 88682, buffid = 81207},		-- aspire, renew
}

TMW.DS = { -- dispel types
	Magic = true,
	Curse = true,
	Disease = true,
	Poison = true,
}


-- --------------------------
-- EXECUTIVE FRAME/FUNCTIONS
-- --------------------------

if LBF then
	LBF:RegisterSkinCallback("TellMeWhen", TellMeWhen_SkinCallback, self)
end

function TellMeWhen_GetDefaults(group)
	local Defaults = CopyTable(TMW.Defaults)
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		Defaults["Groups"][groupID] = CopyTable({})
		for k,v in pairs(TMW.Group_Defaults) do
			if type(v) == "table" then
				Defaults["Groups"][groupID][k] = CopyTable(v)
			end
		end
		for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
			Defaults["Groups"][groupID].Icons[iconID] = {}
		end
		if group then return Defaults["Groups"][groupID] end
	end
	return Defaults
end

function TellMeWhen_CondenseSettings(t)
	t=t or 1
	if t==1 then
		TellMeWhen_Settings_Safe = CopyTable(TellMeWhen_Settings)
	end
	for k,v in pairs(TellMeWhen_Settings.Groups) do
		if k > TELLMEWHEN_MAXGROUPS then TellMeWhen_Settings.Groups[k] = nil end
		if TellMeWhen_Settings.Groups[k] then
			for d,f in pairs(TellMeWhen_Settings.Groups[k]) do
				if f == TMW.Group_Defaults[d] then
					TellMeWhen_Settings.Groups[k][d] = nil
				end
			end
			for z,x in pairs(TellMeWhen_Settings.Groups[k].Icons) do
				local number = 0
				for a,s in pairs(TellMeWhen_Settings.Groups[k].Icons[z]) do
					number = number+1
					if TMW.Icon_DeletedSettings[a] or (s == TMW.Icon_Defaults[a]) or (a == "Conditions" and #s == 0) or (a == "Icons" and #s == 0)then
						TellMeWhen_Settings.Groups[k].Icons[z][a] = nil
					end
				end
				if ((number == 1) or (number == 2)) then
					local wipeit = true
					for o,p in pairs(TellMeWhen_Settings.Groups[k].Icons[z]) do
						if not ((o =="Enabled") or (o == "ShowTimerText")) then
							wipeit = false
						end
					end
					if wipeit then
						TellMeWhen_Settings.Groups[k].Icons[z] = {}
					end
				end
			end
		end
	end
	if t==1 then return TellMeWhen_CondenseSettings(2) end --NEEDS to be run twice in order to completely do everything, i dont have the patience to make it work with one run through
	TellMeWhen_Settings.Condensed = true
end

function TellMeWhen_AddNewSettings(settings, defaults)
	for k, v in pairs(defaults) do
		if (not settings[k]) then
			if (type(v) == "table") then
				settings[k] = {}
				settings[k] = TellMeWhen_AddNewSettings(settings[k], defaults[k])
			else
				settings[k] = v
			end
		elseif (type(v) == "table") then
			settings[k] = TellMeWhen_AddNewSettings(settings[k], defaults[k])
		end
	end
	return settings
end


function TellMeWhen_VarsLoaded()
	SlashCmdList["TELLMEWHEN"] = TellMeWhen_SlashCommand
	SLASH_TELLMEWHEN1 = "/tellmewhen"
	SLASH_TELLMEWHEN2 = "/tmw"
	if (not TellMeWhen_Settings) then
		TellMeWhen_Settings = TellMeWhen_GetDefaults()
		TellMeWhen_Settings.Groups[1]["Enabled"] = true
	elseif (TellMeWhen_Settings["Version"] < TELLMEWHEN_VERSION) then
		TellMeWhen_SafeUpgrade()
	end
	TELLMEWHEN_ICONSPACING = TellMeWhen_Settings["Spacing"] or TELLMEWHEN_ICONSPACING
	if LBF then
		LBF:RegisterSkinCallback("TellMeWhen", TellMeWhen_SkinCallback, self)
	end
	TellMeWhen_Options_Compile()
end

function TellMeWhen_SafeUpgrade()
	if TellMeWhen_Settings.Version < "1.1.4" then
		TellMeWhen_Settings = TellMeWhen_GetDefaults()
		TellMeWhen_Settings.Groups[1]["Enabled"] = true
		TellMeWhen_Settings.Version = TELLMEWHEN_VERSION
	elseif TellMeWhen_Settings.Version < "1.2.0" then
		TellMeWhen_Settings = TellMeWhen_AddNewSettings(TellMeWhen_Settings, TMW.Defaults)
		for groupID = 1, 8 do
			if (groupID < 5) then
				TellMeWhen_Settings.Groups[groupID]["SecondarySpec"] = false
			else
				local temp_groupID = groupID-4
				TellMeWhen_Settings.Groups[groupID]["PrimarySpec"] = false
			end
			if (oldgroupSettings) then
				TellMeWhen_Settings.Groups[groupID]["Enabled"] = oldgroupSettings.Enabled
				TellMeWhen_Settings.Groups[groupID]["Scale"] = oldgroupSettings.Scale
				TellMeWhen_Settings.Groups[groupID]["Rows"] = oldgroupSettings.Rows
				TellMeWhen_Settings.Groups[groupID]["Columns"] = oldgroupSettings.Columns
				TellMeWhen_Settings.Groups[groupID]["OnlyInCombat"] = oldgroupSettings.OnlyInCombat
			end

			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if (oldgroupSettings) then
					oldiconSettings = oldgroupSettings["Icons"][iconID]
					if (oldiconSettings) then
						iconSettings = TellMeWhen_Settings.Groups[groupID].Icons[iconID]
						iconSettings.BuffOrDebuff = oldiconSettings.BuffOrDebuff
						iconSettings.BuffShowWhen = oldiconSettings.BuffShowWhen
						iconSettings.CooldownShowWhen = oldiconSettings.CooldownShowWhen
						iconSettings.CooldownType = oldiconSettings.CooldownType
						iconSettings.Enabled = oldiconSettings.Enabled
						iconSettings.Name = oldiconSettings.Name
						iconSettings.OnlyMine = oldiconSettings.OnlyMine
						iconSettings.ShowTimer = oldiconSettings.ShowTimer
						iconSettings.Type = oldiconSettings.Type
						iconSettings.Unit = oldiconSettings.Unit
						iconSettings.WpnEnchantType = oldiconSettings.WpnEnchantType
					end
				end
				if (iconSettings.Name == "" and iconSettings.type ~= "wpnenchant") then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Enabled"] = false
				end
			end
		end
		TellMeWhen_Settings["Spec"] = nil  -- Remove "Spec" {}
	end

	if TellMeWhen_Settings.Version < "1.3.0" then
		TellMeWhen_Settings["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar"
		TellMeWhen_Settings["TextureName"] = "Blizzard"
		for groupID = 1, 8 do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				TellMeWhen_Settings.Groups[groupID].Icons[iconID]["ShowPBar"] = false
				TellMeWhen_Settings.Groups[groupID].Icons[iconID]["ShowCBar"] = false
				TellMeWhen_Settings.Groups[groupID].Icons[iconID]["InvertBars"] = false
			end
		end
	end
	if TellMeWhen_Settings.Version < "1.4.0" then
		for groupID = 1, 8 do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				iconSettings = TellMeWhen_Settings.Groups[groupID].Icons[iconID]
				if iconSettings.Conditions == nil then
					iconSettings.Conditions = {}
				end
				if iconSettings.Alpha == nil then
					iconSettings.Alpha = 1
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "1.4.1" then
		TellMeWhen_Settings.Interval = UPDATE_INTERVAL
	end
	if TellMeWhen_Settings.Version < "1.4.3" then
		for groupID = 1, 8 do
			TellMeWhen_Settings.Groups[groupID]["Stance"] = {}
		end
	end
	if TellMeWhen_Settings.Version < "1.4.4" then
		TellMeWhen_Settings["CDCOColor"] = {r=0,g=1,b=0,a=1}
		TellMeWhen_Settings["CDSTColor"] = {r=1,g=0,b=0,a=1}
	end
	if TellMeWhen_Settings.Version < "1.4.5" then
		for groupID = 1, 8 do
			TellMeWhen_Settings.Groups[groupID]["Point"] = {}
			local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate", groupID)
			local p = TellMeWhen_Settings.Groups[groupID]["Point"]
			p.point,_,p.relativePoint,p.x,p.y = group:GetPoint(1)
			TellMeWhen_Settings.Groups[groupID]["Point"] = p
		end
	end
	if TellMeWhen_Settings.Version < "1.4.6" then
		for groupID = 1, 8 do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				TellMeWhen_Settings.Groups[groupID].Icons[iconID]["RangeCheck"] = false
				TellMeWhen_Settings.Groups[groupID].Icons[iconID]["ManaCheck"] = false
			end
		end
	end
	if TellMeWhen_Settings.Version < "1.4.7" then
		TellMeWhen_Settings["DrawEdge"] = false
	end
	if TellMeWhen_Settings.Version < "1.4.9.1" then
		TellMeWhen_Settings["OORColor"] = {r=0.5,g=0.5,b=0.5,a=1}
		TellMeWhen_Settings["OOMColor"] = {r=0.5,g=0.5,b=0.5,a=1}
	end
	if TellMeWhen_Settings.Version < "1.5.3" then
		for groupID = 1, 8 do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] > 1 then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] = (TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] / 100)
				else
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] = 1
				end
				TellMeWhen_Settings.Groups[groupID].Icons[iconID]["UnAlpha"] = 1
			end
		end
	end
	if TellMeWhen_Settings.Version < "1.5.4" then
		for groupID = 1, 8 do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] == 0.01 then TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Alpha"] = 1 end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.0.1" then
		TellMeWhen_Settings["USEColor"] 		= 	TellMeWhen_Settings["USEColor"]		or 	{r=1,g=1,b=1}
		TellMeWhen_Settings["UNUSEColor"] 	= 	TellMeWhen_Settings["UNUSEColor"]	or	{r=1,g=1,b=1}
		TellMeWhen_Settings["PRESENTColor"]	= 	TellMeWhen_Settings["PRESENTColor"]	or	{r=1,g=1,b=1}
		TellMeWhen_Settings["ABSENTColor"] 	= 	TellMeWhen_Settings["ABSENTColor"]	or	{r=1,g=0.35,b=0.35}
		local needtowarn = ""
		for groupID = 8,TELLMEWHEN_MAXGROUPS do
			local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate",groupID)
			TellMeWhen_Settings.Groups[groupID] = TellMeWhen_Settings.Groups[groupID] or TellMeWhen_GetDefaults(true)
			TellMeWhen_Settings.Groups[groupID]["Enabled"] = TellMeWhen_Settings.Groups[groupID]["Enabled"] or false
		end
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			TellMeWhen_Settings.Groups[groupID]["LBF"] = TellMeWhen_Settings.Groups[groupID]["LBF"] or {}
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] then
					for k,v in pairs(TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"]) do
						v.ConditionLevel = tonumber(v.ConditionLevel) or 0
						if ((v.ConditionType == "SOUL_SHARDS") or (v.ConditionType == "HOLY_POWER")) and (v.ConditionLevel > 3) then
							needtowarn = needtowarn .. (format(L["GROUPICON"],groupID,iconID)) .. ";  "
							v.ConditionLevel = ceil((v.ConditionLevel/100)*3)
						end
					end
				end
			end
		end
		if needtowarn ~= "" then
			tinsert(TMW.Warns,L["HPSSWARN"] .. " " .. needtowarn)
		end
	end
	if TellMeWhen_Settings.Version < "2.0.2.1" then
		local needtowarn = ""
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] then
					for k,v in pairs(TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"]) do
						local isgood = false
						for z,x in pairs(TMW.IconMenu_SubMenus.Unit) do
							if v.ConditionUnit and v.ConditionUnit == x.value then
								isgood = true
							end
						end
						if not isgood then
							needtowarn = needtowarn .. (format(L["GROUPICON"],groupID,iconID)) .. ";  "
							v.Unit = "player"
						end
					end
				end
			end
		end
		if needtowarn ~= "" then
			tinsert(TMW.Warns,"The following icons have had the unit that their conditions check changed/fixed. You may wish to check them: " .. needtowarn)
		end
	end
	if TellMeWhen_Settings.Version < "2.0.4" then
		TellMeWhen_Settings.Font = {
			["Path"] = "Fonts\\ARIALN.TTF",
			["Name"] = "Arial Narrow",
			["Size"] = 12,
			["Outline"] = "THICK"
		}
	end
	if TellMeWhen_Settings.Version < "2.1.0" then
		if TellMeWhen_Settings.Font.Path == "FontsARIALN.TTF" then TellMeWhen_Settings.Font.Path = "Fonts\\ARIALN.TTF" end --i screwed something up and only put a single slash in at first that just acted as an escape so it dissapeared
		TellMeWhen_CondenseSettings()
	end
	if TellMeWhen_Settings.Version < "2.1.2" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID]["WpnEnchantType"] == "thrown" then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["WpnEnchantType"] = "RangedSlot"
				elseif TellMeWhen_Settings.Groups[groupID].Icons[iconID]["WpnEnchantType"] == "offhand" then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["WpnEnchantType"] = "SecondaryHandSlot"
				elseif TellMeWhen_Settings.Groups[groupID].Icons[iconID]["WpnEnchantType"] == "mainhand" then --idk why this would happen, but you never know
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["WpnEnchantType"] = "MainHandSlot"
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.2.0" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] then
					for k,v in pairs(TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"]) do
						if ((v.ConditionType == "ICON") or (v.ConditionType == "EXISTS") or (v.ConditionType == "ALIVE")) then
							TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"][k]["ConditionLevel"] = 0
						end
					end
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.2.0.1" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] then
					for i in pairs(TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"]) do
						local temp = {}
						for k,v in pairs(TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"][i]) do
							temp[gsub(k,"Condition","")] = v
						end
						TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"][i] = CopyTable(temp)
					end
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.2.1" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["UnitReact"] and TellMeWhen_Settings.Groups[groupID].Icons[iconID]["UnitReact"] ~= 0 then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] = TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"] or {}
					tinsert(TellMeWhen_Settings.Groups[groupID].Icons[iconID]["Conditions"],{
						["AndOr"] = "AND",
						["Type"] = "REACT",
						["Icon"] = "",
						["Operator"] = "==",
						["Level"] = TellMeWhen_Settings.Groups[groupID].Icons[iconID]["UnitReact"],
						["Unit"] = "target",
					})
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.3.0" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID].StackMin and (TellMeWhen_Settings.Groups[groupID].Icons[iconID].StackMin ~= TMW.Icon_Defaults.StackMin) then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID].StackMinEnabled = true
				end
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID].StackMax and (TellMeWhen_Settings.Groups[groupID].Icons[iconID].StackMax ~= TMW.Icon_Defaults.StackMax) then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID].StackMaxEnabled = true
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.4.0" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID].Name then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID].Name = gsub(TellMeWhen_Settings.Groups[groupID].Icons[iconID].Name,"StunnedOrIncapacitated","Stunned;Incapacitated")
					TellMeWhen_Settings.Groups[groupID].Icons[iconID].Name = gsub(TellMeWhen_Settings.Groups[groupID].Icons[iconID].Name,"IncreasedSPboth","IncreasedSPsix;IncreasedSPten")
				end
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID].Type == "darksim" then
					TellMeWhen_Settings.Groups[groupID].Icons[iconID].Type = "multistatecd"
					TellMeWhen_Settings.Groups[groupID].Icons[iconID].Name = "77606"
				end
			end
		end
	end
	if TellMeWhen_Settings.Version < "2.4.1" then
		for groupID = 1, TELLMEWHEN_MAXGROUPS do
			for iconID = 1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
				if TellMeWhen_Settings.Groups[groupID].Icons[iconID].Type == "meta" and type(TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons) == "table" then
					for k,v in pairs(TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons) do
						tinsert(TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons,k)
						TellMeWhen_Settings.Groups[groupID].Icons[iconID].Icons[k] = nil
					end
				end
			end
		end
	end
	--All Upgrades Complete
	TellMeWhen_Settings["Version"] = TELLMEWHEN_VERSION
end

function TellMeWhen_Update()
	if not TMW.EnteredWorld then return end
	TellMeWhen_ColorUpdate()
	UPDATE_INTERVAL = TellMeWhen_Settings.Interval or UPDATE_INTERVAL
	TELLMEWHEN_ICONSPACING = TellMeWhen_Settings["Spacing"] or TELLMEWHEN_ICONSPACING
	for groupID = 1, TELLMEWHEN_MAXGROUPS do
		TellMeWhen_Group_Update(groupID)
	end
	TMW.Initd = true
	TellMeWhen_CopyPanel_Update()
end

function TellMeWhen_ColorUpdate()
	st = TellMeWhen_Settings.CDSTColor
	co = TellMeWhen_Settings.CDCOColor
	rc = TellMeWhen_Settings.OORColor
	mc = TellMeWhen_Settings.OOMColor
	us = TellMeWhen_Settings.USEColor
	un = TellMeWhen_Settings.UNUSEColor
	pr = TellMeWhen_Settings.PRESENTColor
	ab = TellMeWhen_Settings.ABSENTColor
end


function TellMeWhen_OnEvent(self, event,...)
	if event == "ADDON_LOADED" and ... == TMW[1] then
		TellMeWhen_VarsLoaded()
	elseif event == "PLAYER_ENTERING_WORLD" then
		TMW.EnteredWorld = true
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:SetScript("OnUpdate",TellMeWhen_OnUpdate)
		self.elapsed = 0
		TellMeWhen_Update()
	elseif event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		TMW.DoTalentUpdate = true
		self.talentelapsed = 0
	end
end

function TellMeWhen_OnUpdate(self,elapsed)
	if not TMW.Warned then
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 15 then
			for k,v in pairs(TMW.Warns) do
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000" .. L["ICON_TOOLTIP1"] .. " v" .. TELLMEWHEN_VERSION .. TELLMEWHEN_VERSION_MINOR .. ":|r ".. v)
			end
			TMW.Warns = {}
			TMW.Warned = true
		end
	end
	if TMW.DoTalentUpdate then
		self.talentelapsed = self.talentelapsed + elapsed
		if self.talentelapsed > 1 then
			TellMeWhen_Update()
			TMW.DoTalentUpdate = false
		end
	end
end

do --ef
	local ef = CreateFrame("Frame", "TellMeWhen_ExecutiveFrame")
	ef:SetScript("OnEvent", TellMeWhen_OnEvent)
	ef:RegisterEvent("ADDON_LOADED")
	ef:RegisterEvent("PLAYER_ENTERING_WORLD")
end


-- -----------
-- GROUP FRAME
-- -----------


function TellMeWhen_GetGroupSetting(group,groupID,setting)
	if type(group) == "number" then --allow omission of group
		setting = groupID
		groupID = group
	end
	if type(group) == "table" and type(groupID) == "string" then --allow omission of groupID
		setting = groupID
		groupID = group:GetID()
	end
	if (not group) and (not groupID) then
		error("Not enough information to get a setting!")
	end
	if not setting then
		error("No setting specified to get")
	end
	if TellMeWhen_Settings.Groups[groupID][setting] == nil then
		return TMW.Group_Defaults[setting]
	else
		return TellMeWhen_Settings.Groups[groupID][setting]
	end
end

local function TellMeWhen_Group_StanceCheck(group)
	if not group.correctspec then
		return
	end
	local groupID = group:GetID()
	local index = GetShapeshiftForm()

	if pclass == "WARLOCK" and index == 2 then  --UGLY HACK FOR METAMORPHOSIS, IT IS INDEX 2 FOR SOME REASON
		index = 1
	end
	if pclass == "ROGUE" and index >= 2 then	--UGLY FIX FOR ROGUES, VANISH AND SHADOW DANCE RETURN 3 WHEN ACTIVE, VANISH RETURNS 2 WHEN SHADOW DANCE ISNT LEARNED.
		index = 1
	end
	if index > GetNumShapeshiftForms() then --MANY CLASSES RETURN AN INVALID NUMBER ON LOGIN, BUT NOT ANYMORE!
		index = 0
	end
	if index == 0 then
		if not TellMeWhen_Settings.Groups[groupID]["Stance"][0] then
			group.correctstance = true
		else
			group.correctstance = false
		end
	elseif index then
		local texture, name, isActive, isCastable = GetShapeshiftFormInfo(index)
		if not name then error("Uh oh! Something happened to the stance checks! Please submit this error along with what you were doing at the time:" .. index .. ":" .. pclass .. ":") return end
		local _,_,ID = strfind(GetSpellLink(name), ":(%d+)")
		for k,v in pairs(TMW.CS) do
			if TMW.CS[k] == tonumber(ID) then
				if not TellMeWhen_Settings.Groups[groupID]["Stance"][k] then
					group.correctstance = true
				else
					group.correctstance = false
				end
			end
		end
	end
end

function TellMeWhen_Group_ShowHide(group)
	local combat = UnitAffectingCombat("player")
	local vehicle = UnitHasVehicleUI("player")
	
	if group.correctstance then
		if group.OnlyInCombat and group.NotInVehicle then
			if combat then
				if vehicle then
					group:Hide()
				else
					group:Show()
				end
			else
				group:Hide()
			end
		elseif group.OnlyInCombat then
			if combat then
				group:Show()
			else
				group:Hide()
			end
		elseif group.NotInVehicle then
			if vehicle then
				group:Hide()
			else
				group:Show()
			end
		else
			group:Show()
		end
	else
		group:Hide()
	end
end

function TellMeWhen_Group_OnEvent(group, event,...)
	if event == "UPDATE_SHAPESHIFT_FORM" or event == "UPDATE_SHAPESHIFT_FORMS" then
		TellMeWhen_Group_StanceCheck(group)
	end
	if (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and ... ~= "player" then return end
	TellMeWhen_Group_ShowHide(group)
end

function TellMeWhen_Group_Update(groupID)
	local group = _G["TellMeWhen_Group"..groupID] or CreateFrame("Frame","TellMeWhen_Group"..groupID, UIParent, "TellMeWhen_GroupTemplate",groupID)
	TellMeWhen_Settings.Groups = TellMeWhen_Settings.Groups or {}
	TellMeWhen_Settings.Groups[groupID] = TellMeWhen_Settings.Groups[groupID] or TellMeWhen_GetDefaults(true)
	group.groupName = "TellMeWhen_Group"..groupID
	group.correctstance = true
	
	for k,v in pairs(TMW.Group_Defaults) do
		if TellMeWhen_Settings.Groups[groupID][k] == nil then
			group[k] = TMW.Group_Defaults[k]
		else
			group[k] = TellMeWhen_Settings.Groups[groupID][k]
		end
	end

	local locked = TellMeWhen_Settings["Locked"]

	local currentSpec = GetActiveTalentGroup()
	group.correctspec = true

	if not group.Enabled then
		for row = 1, group.Rows do
			for column = 1, group.Columns do
				local iconID = (row-1)*group.Columns + column
				local iconName = group.groupName.."_Icon"..iconID
				for k,v in pairs(TMW.Icons) do
					if TMW.Icons[k] == iconName then
						TMW.Icons[k] = nil
					end
				end
			end
		end
	end
	if (currentSpec==1 and not group.PrimarySpec) or (currentSpec==2 and not group.SecondarySpec) then
		group.Enabled = false
		group.correctspec = false
	end
	if LBF then
		TMW.DontRun = true
		local lbfs = TellMeWhen_Settings.Groups[groupID]["LBF"]
		LBF:Group("TellMeWhen", L["GROUP"] .. groupID)
		if lbfs.SkinID then
			LBF:Group("TellMeWhen", L["GROUP"] .. groupID):Skin(lbfs.SkinID,lbfs.Gloss,lbfs.Backdrop,lbfs.Colors)
		end
	end
	if (group.Enabled) then
		for row = 1, group.Rows do
			for column = 1, group.Columns do
				local iconID = (row-1)*group.Columns + column
				local iconName = group.groupName.."_Icon"..iconID
				local icon = _G[iconName] or CreateFrame("Button", iconName, group, "TellMeWhen_IconTemplate",iconID)
				local powerbarname = iconName.."_PowerBar"
				local cooldownbarname = iconName.."_CooldownBar"
				icon.powerbar = icon.powerbar or CreateFrame("StatusBar",powerbarname,icon)
				icon.cooldownbar = icon.cooldownbar or CreateFrame("StatusBar",cooldownbarname,icon)
				icon:Show()
				if (column > 1) then
					icon:SetPoint("TOPLEFT", _G[group.groupName.."_Icon"..(iconID-1)], "TOPRIGHT", TELLMEWHEN_ICONSPACING, 0)
				elseif (row > 1) and (column == 1) then
					icon:SetPoint("TOPLEFT", _G[group.groupName.."_Icon"..(iconID-group.Columns)], "BOTTOMLEFT", 0, -TELLMEWHEN_ICONSPACING)
				elseif (iconID == 1) then
					icon:SetPoint("TOPLEFT", group, "TOPLEFT")
				end
				TellMeWhen_Icon_Update(icon, groupID, iconID)
			end
		end
		for iconID = group.Rows*group.Columns+1, TELLMEWHEN_MAXROWS*TELLMEWHEN_MAXROWS do
			local icon = _G[group.groupName.."_Icon"..iconID]
			if icon then
				icon:Hide()
				TellMeWhen_Icon_ClearScripts(icon)
			end
		end

		group:SetScale(group.Scale)
		local lastIcon = group.groupName.."_Icon"..(group.Rows*group.Columns)
		group.resizeButton:SetPoint("BOTTOMRIGHT", lastIcon, "BOTTOMRIGHT", 3, -3)
		if (locked) then
			group.resizeButton:Hide()
		else
			group.resizeButton:Show()
		end

		TellMeWhen_Group_StanceCheck(group)
		TellMeWhen_Group_ShowHide(group)
	end
	TellMeWhen_SetGroupPositions(group,groupID)

	if group.OnlyInCombat then
		group:RegisterEvent("PLAYER_REGEN_ENABLED")
		group:RegisterEvent("PLAYER_REGEN_DISABLED")
		group:RegisterEvent("PLAYER_ALIVE")
		group:RegisterEvent("PLAYER_DEAD")
		group:RegisterEvent("PLAYER_UNGHOST")
	end
	
	if group.NotInVehicle then
		group:RegisterEvent("UNIT_ENTERED_VEHICLE")
		group:RegisterEvent("UNIT_EXITED_VEHICLE")
	end
	
	if group.Enabled and locked then
		group:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		group:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
		TellMeWhen_Group_ShowHide(group)
	else
		group:UnregisterAllEvents()
		if (group.Enabled) then
			group:Show()
		else
			group:Hide()
		end
	end

	group:SetScript("OnEvent", TellMeWhen_Group_OnEvent)
end


-- -------------
-- ICON FUNCTIONS
-- -------------


function TellMeWhen_GetIconSetting(icon,groupID,iconID,setting)
	if type(icon) == "number" then --allow omission of icon
		setting = iconID
		iconID = groupID
		groupID = icon
	end
	if type(icon) == "table" and type(groupID) == "string" then --allow omission of group and icon IDs
		setting = groupID
		iconID = icon:GetID()
		groupID = icon:GetParent():GetID()
	end
	if not setting then
		error("No Setting to get!")
	end
	if ((not icon) and (not (groupID and iconID))) or TellMeWhen_Settings.Groups[groupID].Icons[iconID] == nil or TellMeWhen_Settings.Groups[groupID].Icons[iconID][setting] == nil then
		return TMW.Icon_Defaults[setting]
	else
		return TellMeWhen_Settings.Groups[groupID].Icons[iconID][setting]
	end
end

function TellMeWhen_Icon_Update(icon, groupID, iconID)
	for k in pairs(TMW.Icon_Defaults) do 	--lets clear any settings that might get left behind.
		icon[k] = nil
	end

	icon.Type = TellMeWhen_GetIconSetting(groupID,iconID,"Type")
	
	if not TMW.RelevantIconSettings[icon.Type] then
		for k in pairs(TMW.Icon_Defaults) do
			icon[k] = TellMeWhen_GetIconSetting(groupID,iconID,k)
		end
	else
		for k in pairs(TMW.RelevantIconSettings.all) do
			icon[k] = TellMeWhen_GetIconSetting(groupID,iconID,k)
		end
		for k in pairs(TMW.RelevantIconSettings[icon.Type]) do
			icon[k] = TellMeWhen_GetIconSetting(groupID,iconID,k)
		end
	end

	icon.Width				= icon.Width or 36
	icon.Height				= icon.Height or 36
	icon.UpdateTimer 		= UPDATE_INTERVAL
	icon.Start 				= 0
	icon.Duration 			= 0
	icon.CondtShown 		= 0
	
	icon.cooldown.noCooldownCount = not icon.ShowTimerText
	icon.cooldown:SetFrameLevel(icon:GetFrameLevel() + 1)
	icon.cooldown:SetDrawEdge(TellMeWhen_Settings["DrawEdge"])

	icon.countText:SetFont(TellMeWhen_Settings.Font.Path,TellMeWhen_Settings.Font.Size,TellMeWhen_Settings.Font.Outline)
	--LBF STUFF
	if LBF then
		TMW.DontRun = true -- TellMeWhen_Update() is ran in the LBF skin callback, which just causes an infinite loop. This tells it not to
		local lbfs = TellMeWhen_Settings.Groups[groupID]["LBF"]
		LBF:Group("TellMeWhen", L["GROUP"] .. groupID):AddButton(icon)
		local SkID = lbfs.SkinID or "Blizzard"
		local tab = LBF:GetSkins()
		if tab and SkID then
			if SkID == "Blizzard" then --blizzard needs custom overlay bar sizes because of the borders, other skins might like to use this too
				icon.Width = (tab[SkID].Icon.Width)*0.9
				icon.Height = (tab[SkID].Icon.Height)*0.9
			else
				icon.Width = tab[SkID].Icon.Width
				icon.Height = tab[SkID].Icon.Height
			end
		end
		icon.countText:SetFont(TellMeWhen_Settings.Font.Path,tab[SkID].Count.FontSize or TellMeWhen_Settings.Font.Size,TellMeWhen_Settings.Font.Outline)
	else
		icon.Width = 36*0.9
		icon.Height = 36*0.9
	end

	icon:UnregisterAllEvents()
	icon.countText:Hide()

	icon.ConditionPresent = false
	if #(icon.Conditions) > 0 then
		icon.ConditionPresent = true
	end

	TellMeWhen_Icon_ClearScripts(icon)
	if icon.Enabled and TellMeWhen_GetGroupSetting(groupID,"Enabled") then
		local isin = false
		for k in pairs(TMW.Icons) do
			if TMW.Icons[k] == icon:GetName() then
				isin = true
			end
		end
		if not isin then
			tinsert(TMW.Icons,icon:GetName())
		end
	else
		for k in pairs(TMW.Icons) do
			if TMW.Icons[k] == icon:GetName() then
				TMW.Icons[k] = nil
			end
		end
	end

	if not (TellMeWhen_Settings["Locked"] and not icon.Enabled) then
		-- used by both cooldown and reactive icons
		if icon.CooldownShowWhen == "usable" or icon.BuffShowWhen == "present" then
			icon.PresUsableAlpha = (1 * icon.Alpha)
			icon.AbsentUnUsableAlpha = 0
		elseif icon.CooldownShowWhen == "unusable" or  icon.BuffShowWhen == "absent" then
			icon.PresUsableAlpha = 0
			icon.AbsentUnUsableAlpha = (1 * icon.UnAlpha)
		elseif icon.CooldownShowWhen == "always" or icon.BuffShowWhen == "always" then
			icon.PresUsableAlpha = (1 * icon.Alpha)
			icon.AbsentUnUsableAlpha = (1 * icon.UnAlpha)
		else --then this isnt the right icon type.
			icon.PresUsableAlpha = 1
			icon.AbsentUnUsableAlpha = 1
		end

		if icon.DurationMinEnabled or icon.DurationMaxEnabled then
			icon.Duration = true
		else
			icon.Duration = false
		end
		
		if (icon.Type == "cooldown") then
-- --------------
-- SPELL COOLDOWN
-- --------------
			if (icon.CooldownType == "spell") then
				
				icon.IsChakra = false
				icon.ChakraActive = true
				icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
				icon.NameName = TellMeWhen_GetSpellNames(icon,icon.Name,1,true)

				icon.texture:SetTexture(GetSpellTexture(icon.NameFirst) or "Interface\\Icons\\INV_Misc_QuestionMark")
				icon:SetScript("OnUpdate", TellMeWhen_Icon_SpellCooldown_OnUpdate)
				TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
				icon:RegisterEvent("SPELL_UPDATE_USABLE")
				icon:RegisterEvent("SPELL_UPDATE_COOLDOWN")
				icon:SetScript("OnEvent", TellMeWhen_Icon_SpellCooldown_OnEvent)
				TellMeWhen_Icon_SpellCooldown_OnUpdate(icon,1)
				TellMeWhen_Icon_SpellCooldown_OnEvent(icon)

-- --------------
-- ITEM COOLDOWN
-- --------------
			elseif (icon.CooldownType == "item") then
				icon.NameFirst = TellMeWhen_GetItemIDs(icon,icon.Name,1)
				if icon.Slot and icon.Slot <= 19 then
					icon.NameFirst = icon.NameFirst or 0
					icon:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
				end
				icon.ShowPBar = false
				icon.powerbar:Hide()
				TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
				local itemName, itemLink, _, _, _, _, _, _, _, itemTexture = GetItemInfo(icon.NameFirst)
				icon:SetScript("OnUpdate", TellMeWhen_Icon_ItemCooldown_OnUpdate)
				if (itemName) then
					icon.texture:SetTexture(itemTexture)
					if icon.ShowTimer then
						icon:RegisterEvent("BAG_UPDATE_COOLDOWN")
					end
				else
					TellMeWhen_Icon_ClearScripts(icon)
					icon.LearnedTexture = false
					icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				end
				icon:SetScript("OnEvent", TellMeWhen_Icon_ItemCooldown_OnEvent)
				TellMeWhen_Icon_ItemCooldown_OnUpdate(icon,1)
				TellMeWhen_Icon_ItemCooldown_OnEvent(icon)
			end
			icon.cooldown:SetReverse(false)
-- --------------
-- BUFF
-- --------------
		elseif (icon.Type == "buff") then
			icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.NameName = TellMeWhen_GetSpellNames(icon,icon.Name,1,1)
			icon.NameList = TellMeWhen_GetSpellNames(icon,icon.Name)
			icon.NameNameList = TellMeWhen_GetSpellNames(icon,icon.Name,nil,1)

			icon.Filter = icon.BuffOrDebuff
			icon.Filterh = ((icon.BuffOrDebuff == "EITHER") and "HARMFUL")
			if icon.OnlyMine then
				icon.Filter = icon.Filter.."|PLAYER"
				if icon.Filterh then icon.Filterh = icon.Filterh.."|PLAYER" end
			end

			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			icon:SetScript("OnUpdate",TellMeWhen_Icon_Buff_OnUpdate)
			icon.countText:Show()
			if icon.StackMinEnabled or icon.StackMaxEnabled then
				icon.Stacks = true
			else
				icon.Stacks = false
			end
			if (icon.Name == "") then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			elseif (GetSpellTexture(icon.NameFirst)) then
				icon.texture:SetTexture(GetSpellTexture(icon.NameFirst))
			elseif (not icon.LearnedTexture) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
			end
			icon.cooldown:SetReverse(true)
			TellMeWhen_Icon_Buff_OnUpdate(icon,1)
-- --------------
-- REACTIVE
-- --------------
		elseif (icon.Type == "reactive") then
			icon.IsChakra = false
			icon.ChakraActive = true
			icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.NameName = TellMeWhen_GetSpellNames(icon,icon.Name,1,true)

			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			if (GetSpellTexture(icon.NameFirst)) then
				icon.texture:SetTexture(GetSpellTexture(icon.NameFirst))
				icon:SetScript("OnUpdate", TellMeWhen_Icon_Reactive_OnUpdate)
			else
				TellMeWhen_Icon_ClearScripts(icon)
				icon.LearnedTexture = false
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			end
		--	icon:RegisterEvent("PET_BAR_UPDATE")
			icon:RegisterEvent("SPELL_UPDATE_USABLE")
			icon:RegisterEvent("SPELL_UPDATE_COOLDOWN")
			icon:SetScript("OnEvent", TellMeWhen_Icon_SpellCooldown_OnEvent)
			TellMeWhen_Icon_Reactive_OnUpdate(icon,1)


-- --------------
-- WEP ENCHANT
-- --------------
		elseif (icon.Type == "wpnenchant") then
			icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)

			icon.ShowPBar = false
			icon.ShowCBar = false
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			icon:RegisterEvent("UNIT_INVENTORY_CHANGED")
			local slotID = GetInventorySlotInfo(icon.WpnEnchantType)
			icon.countText:Show()
			local wpnTexture = GetInventoryItemTexture("player", slotID)
			if (wpnTexture) then
				icon.texture:SetTexture(wpnTexture)
				icon:SetScript("OnEvent", TellMeWhen_Icon_WpnEnchant_OnEvent)
				icon:SetScript("OnUpdate", TellMeWhen_Icon_WpnEnchant_OnUpdate)
			else
				TellMeWhen_Icon_ClearScripts(icon)
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			end
			TellMeWhen_Icon_WpnEnchant_OnEvent(icon,nil,"player")
			TellMeWhen_Icon_WpnEnchant_OnUpdate(icon,1)
-- --------------
-- TOTEM
-- --------------
		elseif (icon.Type == "totem") then
			icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.NameName = TellMeWhen_GetSpellNames(icon,icon.Name,1,1)
			icon.NameNameList = TellMeWhen_GetSpellNames(icon,icon.Name,nil,1)
			if pclass == "DEATHKNIGHT" then
				icon.NameName = GetSpellInfo(46584)
			end
			icon.ShowPBar = false
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)

			icon:SetScript("OnUpdate", TellMeWhen_Icon_Totem_OnUpdate)
			if (icon.Name == "") then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				icon.LearnedTexture = false
			elseif (GetSpellTexture(icon.NameFirst)) then
				icon.texture:SetTexture(GetSpellTexture(icon.NameFirst))
			elseif (not icon.LearnedTexture) then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
			end
			TellMeWhen_Icon_Totem_OnUpdate(icon,1)

-- --------------
-- DARK SIM
-- --------------
		elseif (icon.Type == "multistatecd") then
			icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			
			if icon.NameFirst and icon.NameFirst ~= "" and GetSpellLink(icon.NameFirst) and not tonumber(icon.NameFirst) then
				_,_,icon.NameFirst = strfind(GetSpellLink(icon.NameFirst), ":(%d+)")
				icon.NameFirst = tonumber(icon.NameFirst)
			end
			icon.Slot = 0
			for i=1,120 do
				local type, spellID = GetActionInfo(i)
				if spellID == icon.NameFirst then
					icon.Slot = i
					break
				end
			end
			icon.texture:SetTexture(GetActionTexture(icon.Slot) or "Interface\\Icons\\INV_Misc_QuestionMark")
			icon:SetScript("OnUpdate", TellMeWhen_Icon_MultiStateCD_OnUpdate)
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			icon:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
			icon:SetScript("OnEvent", TellMeWhen_Icon_MultiStateCD_OnEvent)
			TellMeWhen_Icon_MultiStateCD_OnUpdate(icon,1)
			TellMeWhen_Icon_MultiStateCD_OnEvent(icon)
			
-- --------------
-- CAST
-- --------------		
		elseif (icon.Type == "cast") then
		
			icon.NameFirst = TellMeWhen_GetSpellNames(icon,icon.Name,1)
			icon.NameNameList = TellMeWhen_GetSpellNames(icon,icon.Name,nil,1)
			
			if (icon.Name == "") then
				icon.texture:SetTexture("Interface\\Icons\\Temp")
			elseif (GetSpellTexture(icon.NameFirst)) then
				icon.texture:SetTexture(GetSpellTexture(icon.NameFirst))
			elseif (not icon.LearnedTexture) then
				icon.texture:SetTexture("Interface\\Icons\\Temp")
			end
			
			icon:SetScript("OnUpdate", TellMeWhen_Icon_Cast_OnUpdate)
			icon.ShowPBar = false
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			TellMeWhen_Icon_Cast_OnUpdate(icon,1)
			
-- --------------
-- META
-- --------------				
		elseif (icon.Type == "meta") then
			icon.NameFirst = "" --need to set this to something for bars update
			
			icon.ShowPBar = true
			icon.ShowCBar = true
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			icon.cooldownbar:SetValue(0)
			icon.powerbar:SetValue(0)
			
			icon.texture:SetTexture("Interface\\Icons\\LevelUpIcon-LFD")
			
			for k,v in pairs(icon.Icons) do
				if not v then icon.Icons[k] = nil end
			end
			icon:SetScript("OnUpdate", TellMeWhen_Icon_Meta_OnUpdate)
			
		else
			icon.ShowPBar = false
			icon.ShowCBar = false
			TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
			TellMeWhen_Icon_ClearScripts(icon)
			if (icon.Name ~= "") then
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			else
				icon.texture:SetTexture(nil)
			end
		end
	end -- icon.Enabled CHECK

	icon.cooldown:Hide()
	if (icon.Enabled) then
		icon:SetAlpha(1.0)
	else
		icon:SetAlpha(0.4)
		TellMeWhen_Icon_ClearScripts(icon)
	end

	icon:Show()
	if TellMeWhen_Settings["Locked"] then
		icon:DisableDrawLayer("BACKGROUND")
		icon:EnableMouse(0)
		if (not icon.Enabled) then
			icon:Hide()
			icon.powerbar:Hide()
			icon.cooldownbar:Hide()
		elseif icon.Name == "" and icon.Type ~= "wpnenchant" and icon.Type ~= "cast" and icon.Type ~= "meta" then
			icon:Hide()
		end
		icon.powerbar:SetValue(0)
		icon.cooldownbar:SetValue(0)
		icon.powerbar:SetAlpha(.9)


	else
		if (not icon.texture:GetTexture()) then
			icon:EnableDrawLayer("BACKGROUND")
		else
			icon:DisableDrawLayer("BACKGROUND")
		end
		if not icon.cooldownbar.texture then
			icon.cooldownbar.texture = icon.cooldownbar:CreateTexture()
		end
		if not icon.powerbar.texture then
			icon.powerbar.texture = icon.powerbar:CreateTexture()
		end
		icon.cooldownbar:SetMinMaxValues(0,  1)
		icon.cooldownbar:SetValue(1)
		icon.cooldownbar:SetStatusBarColor(0, 1, 0, 0.5)
		icon.cooldownbar.texture:SetTexCoord(0, 1, 0, 1)
		icon.powerbar:SetValue(2000000)
		icon.powerbar:SetAlpha(.5)
		icon.powerbar.texture:SetTexCoord(0, 1, 0, 1)
		icon:EnableMouse(1)
		icon.texture:SetVertexColor(1, 1, 1, 1)
		TellMeWhen_Icon_ClearScripts(icon)
		if icon.Type == "meta" then
			icon.cooldownbar:SetValue(0)
			icon.powerbar:SetValue(0)
		end
	end
end

function TellMeWhen_Icon_Bars_Update(icon, groupID, iconID)
	if icon.ShowPBar or icon.ShowCBar then
		local groupName = "TellMeWhen_Group"..groupID
		local iconName = groupName.."_Icon"..iconID
		local Enabled = icon.Enabled
		local locked = TellMeWhen_Settings["Locked"]
		local OnlyInCombat = icon:GetParent().OnlyInCombat
		local width, height = icon:GetSize()
		local scale = icon:GetParent().Scale
		if not TellMeWhen_Settings["Texture"] then
			TellMeWhen_Settings["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar"
		end
		if not TellMeWhen_Settings["TextureName"] then
			TellMeWhen_Settings["TextureName"] = "Blizzard"
		end
		local tex = TellMeWhen_Settings["Texture"]
		if icon.ShowPBar then
			local _,_,_,cost,_,powerType = GetSpellInfo(icon.NameFirst)
			if cost == nil then cost = 0 end
			local powerbarname = iconName.."_PowerBar"
			if not icon.powerbar then
				icon.powerbar = CreateFrame("StatusBar",powerbarname,icon)
			end
			icon.powerbar:SetSize(width*(icon.Width/36), ((height / 2)*(icon.Height/36))-0.5)
			icon.powerbar:SetPoint("BOTTOM",icon,"CENTER",0,0.5)--(((height/2)*(icon.Height/36))-(icon.cooldownbar:GetHeight())))
			if cost then
				icon.powerbar:SetMinMaxValues(0, cost)
			end
			if not icon.powerbar.texture then
				icon.powerbar.texture = icon.powerbar:CreateTexture()
			end
			icon.powerbar.texture:SetTexture(tex)
			if powerType then
				local colorinfo = PowerBarColor[powerType]
				icon.powerbar:SetStatusBarColor(colorinfo.r, colorinfo.g, colorinfo.b, 0.9)
			end
			icon.powerbar:SetStatusBarTexture(icon.powerbar.texture)
			icon.powerbar:SetFrameLevel(icon:GetFrameLevel() + 2)
		end
		if icon.ShowCBar then
			local cooldownbarname = iconName.."_CooldownBar"
			icon.cooldownbar = icon.cooldownbar or CreateFrame("StatusBar",cooldownbarname,icon)
			icon.cooldownbar:SetSize(width*(icon.Width/36), ((height / 2)*(icon.Height/36))-0.5)
			icon.cooldownbar:SetPoint("TOP",icon,"CENTER",0,-0.5)---(((height/2)*(icon.Height/36))-(icon.cooldownbar:GetHeight())))
			icon.cooldownbar.texture = icon.cooldownbar.texture or icon.cooldownbar:CreateTexture()
			icon.cooldownbar.texture:SetTexture(tex)
			icon.cooldownbar:SetStatusBarTexture(icon.cooldownbar.texture)
			icon.cooldownbar:SetFrameLevel(icon:GetFrameLevel() + 2)
			icon.cooldownbar:SetMinMaxValues(0,  1)
		end
	end
	if not icon.ShowPBar then
		icon.powerbar:Hide()
	else
		icon.powerbar:Show()
	end
	if not icon.ShowCBar then
		icon.cooldownbar:Hide()
	else
		icon.cooldownbar:Show()
	end
end

function TellMeWhen_Icon_ClearScripts(icon)
	icon:SetScript("OnEvent", nil)
	icon:SetScript("OnUpdate", nil)
end


local function OnGCD(d)
	local _,r=GetSpellCooldown(GCDSpell)
	if r > 1.7 then return false end
	if d == 1 then return true end
	return r == d and d > 0
end

local function ConditionCheck(Cs)
	local retCode = TMW_CNDT[Cs[1].Type](Cs[1])
	for i=2,#Cs do
		local c = Cs[i]
		retCode = TMW_AO[c.AndOr](retCode,TMW_CNDT[c.Type](c))
	end
	return retCode
end

local function CDBarUpdate(icon,startTime,duration,buff)
	local bar = icon.cooldownbar
	local percentcomplete = 1
	if OnGCD(duration) and not buff and not TellMeWhen_Settings["BarGCD"] then
		duration = 0
	end
	if not icon.InvertBars then
		if (duration == 0) then
			bar:SetMinMaxValues(0,  1)
			bar:SetValue(0)
		else
			percentcomplete = ((GetTime() - startTime) / duration)
			bar:SetMinMaxValues(0,  duration)
			bar:SetValue(duration - (GetTime() - startTime))
			bar.texture:SetTexCoord(0, min((1-percentcomplete),1), 0, 1)
			bar:SetStatusBarColor(
				(co.r*percentcomplete) + (st.r * (1-percentcomplete)),
				(co.g*percentcomplete) + (st.g * (1-percentcomplete)),
				(co.b*percentcomplete) + (st.b * (1-percentcomplete)),
				(co.a*percentcomplete) + (st.a * (1-percentcomplete))
			)
		end
	else
		--inverted
		if (duration == 0) then
			bar:SetMinMaxValues(0,1)
			bar:SetValue(1)
			bar:SetStatusBarColor(co.r, co.g, co.b, co.a)
			bar.texture:SetTexCoord(0, 1, 0, 1)
		else
			percentcomplete = (((GetTime() - startTime) / duration))
			bar:SetMinMaxValues(0,  duration)
			bar:SetValue(GetTime() - startTime)
			bar.texture:SetTexCoord(0, min(percentcomplete,1), 0, 1)
			bar:SetStatusBarColor(
				(co.r*percentcomplete) + (st.r * (1-percentcomplete)),
				(co.g*percentcomplete) + (st.g * (1-percentcomplete)),
				(co.b*percentcomplete) + (st.b * (1-percentcomplete)),
				(co.a*percentcomplete) + (st.a * (1-percentcomplete))
			)
		end
	end
end

local function PwrBarUpdate(icon,name)
	local bar = icon.powerbar
	local _,_,_,cost,_,powerType = GetSpellInfo(name)
	cost = cost or 0
	bar:SetMinMaxValues(0, cost)
	if not icon.InvertBars then
		bar:SetValue(cost - UnitPower("player",powerType))
		bar.texture:SetTexCoord(0, max(0,min(((cost - UnitPower("player",powerType)) / cost),1)), 0, 1)
	else
		bar:SetValue(UnitPower("player",powerType))
		bar.texture:SetTexCoord(0, max(0,min((UnitPower("player",powerType) / cost),1)), 0, 1)
	end
end

local function SetCD(icon, start, duration)
	icon.Start = start
	icon.Duration = duration
	if ( start and start > 0 and duration > 0) then
		local cd = icon.cooldown
		cd:SetCooldown(start, duration);
		cd:Show();
	else
		icon.cooldown:Hide();
	end
end

-- -------------
-- ICON SCRIPTS
-- -------------


function TellMeWhen_Icon_SpellCooldown_OnEvent(icon)
	local startTime, duration = GetSpellCooldown(icon.NameFirst)
	if (not icon.ShowTimer) or ((not TellMeWhen_Settings["ClockGCD"]) and OnGCD(duration)) then SetCD(icon, 0, 0) return end
	if duration then
		SetCD(icon, startTime, duration)
	end
end

function TellMeWhen_Icon_SpellCooldown_OnUpdate(icon, elapsed)
	icon.UpdateTimer = icon.UpdateTimer - elapsed
	local Name = icon.NameFirst
	local NameName = icon.NameName
	local startTime, duration = GetSpellCooldown(Name)
	if duration and NameName then
		if icon.ShowPBar then
			PwrBarUpdate(icon,Name)
		end
		if icon.ShowCBar then
			CDBarUpdate(icon,startTime,duration)
		end
		if (icon.UpdateTimer <= 0) then
			icon.UpdateTimer = UPDATE_INTERVAL
			if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
				local a = icon.ConditionAlpha
				icon:SetAlpha(a)
				icon.CondtShown = a
				return
			end
			if duration and icon.Duration then
				local remaining = duration - (GetTime() - startTime)
				if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
					local a = icon.DurationAlpha
					icon:SetAlpha(a)
					icon.CondtShown = a
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
			end
			if icon.IsChakra then
				if UnitAura("player",GetSpellInfo(TMW.Chakra[icon.IsChakra]["buffid"])) then
					icon.ChakraActive = true
				else
					icon.ChakraActive = false
				end
			end
			local inrange = IsSpellInRange(NameName, "target")
			local _, nomana = IsUsableSpell(Name)
			if not icon.RangeCheck or not inrange then
				inrange = 1
			end
			if not icon.ManaCheck then
				nomana = nil
			end

			if ((duration == 0 or OnGCD(duration)) and inrange == 1 and not nomana and icon.ChakraActive) then
				icon.texture:SetVertexColor(1, 1, 1, 1)
				icon:SetAlpha(icon.PresUsableAlpha)
			elseif (icon.PresUsableAlpha ~= 0 and icon.ChakraActive) then
				if inrange ~= 1 then
					icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha*rc.a)
				elseif nomana then
					icon.texture:SetVertexColor(mc.r, mc.g, mc.b, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha*mc.a)
				elseif not icon.ShowTimer then
					icon.texture:SetVertexColor(0.5, 0.5, 0.5, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha)
				else
					icon.texture:SetVertexColor(1, 1, 1, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha)
				end
			else
				icon.texture:SetVertexColor(1, 1, 1, 1)
				icon:SetAlpha(icon.AbsentUnUsableAlpha)
			end
			icon.CondtShown = icon:GetAlpha()
			if icon.FakeHidden then
				icon:SetAlpha(0)
			end
		end
	elseif (not NameName) and duration and icon:GetScript("OnEvent") then
		TellMeWhen_Icon_ClearScripts(icon)
		if TMW.Warned then
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000" .. L["ICON_TOOLTIP1"] .. " v" .. TELLMEWHEN_VERSION .. TELLMEWHEN_VERSION_MINOR .. ":|r ".. icon:GetName() .. " disabled to prevent massive error spam. Type /tmw and change the name of the icon to a spellID to fix this.")
		else
			TMW.Warns[tonumber(icon:GetID() .. icon:GetParent():GetID())] = icon:GetName() .. " disabled to prevent massive error spam. Type /tmw and change the name of the icon to a spellID to fix this."
		end
	end
end

function TellMeWhen_Icon_ItemCooldown_OnEvent(icon,event,...)
	if event == "PLAYER_EQUIPMENT_CHANGED" then
		local slot, has = ...
		if (icon.Slot == slot) and has then
			icon.NameFirst = TellMeWhen_GetItemIDs(icon,icon.Name,1)
			local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(icon.NameFirst)
			if (itemTexture) then
				icon.texture:SetTexture(itemTexture)
				if icon.ShowTimer then
					icon:RegisterEvent("BAG_UPDATE_COOLDOWN")
				end
			else
				icon.LearnedTexture = false
				icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
			end
		elseif (icon.Slot == slot) then
			icon.NameFirst = 0
			icon.LearnedTexture = false
			icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		end
		return
	end
	local startTime, duration = GetItemCooldown(icon.NameFirst)
	if (not TellMeWhen_Settings["ClockGCD"]) and OnGCD(duration) then SetCD(icon, 0, 0) return end
	if duration then
		SetCD(icon, startTime, duration)
	end
end

function TellMeWhen_Icon_ItemCooldown_OnUpdate(icon, elapsed)
	icon.UpdateTimer = icon.UpdateTimer - elapsed
	local NameFirst = icon.NameFirst
	local startTime, duration = GetItemCooldown(NameFirst)
	if icon.ShowCBar then
		CDBarUpdate(icon,startTime,duration)
	end
	if (icon.UpdateTimer <= 0) and duration then
		icon.UpdateTimer = UPDATE_INTERVAL
		if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
			local a = icon.ConditionAlpha
			icon:SetAlpha(a)
			icon.CondtShown = a
			if icon.FakeHidden then icon:SetAlpha(0) end
			return
		end
		if duration and icon.Duration then
			local remaining = duration - (GetTime() - startTime)
			if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
				local a = icon.DurationAlpha
				icon:SetAlpha(a)
				icon.CondtShown = a
				if icon.FakeHidden then icon:SetAlpha(0) end
				return
			end
		end
		local inrange = IsItemInRange(NameFirst, "target")
		if (not icon.RangeCheck or inrange == nil) then
			inrange = 1
		end
		if (duration == 0 or OnGCD(duration)) and inrange == 1 then
			icon.texture:SetVertexColor(1, 1, 1, 1)
			icon:SetAlpha(icon.PresUsableAlpha)
		elseif (icon.PresUsableAlpha ~= 0) then
			if inrange ~= 1 then
				icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1)
				icon:SetAlpha(icon.AbsentUnUsableAlpha*rc.a)
			elseif not icon.ShowTimer then
				icon.texture:SetVertexColor(0.5, 0.5, 0.5, 1)
				icon:SetAlpha(icon.AbsentUnUsableAlpha)
			else
				icon.texture:SetVertexColor(1, 1, 1, 1)
				icon:SetAlpha(icon.AbsentUnUsableAlpha)
			end
		else
			icon.texture:SetVertexColor(1, 1, 1, 1)
			icon:SetAlpha(icon.AbsentUnUsableAlpha)
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

function TellMeWhen_Icon_Buff_OnUpdate(icon, elapsed)
	if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
		local a = icon.ConditionAlpha
		icon:SetAlpha(a)
		icon.CondtShown = a
		if icon.FakeHidden then icon:SetAlpha(0) end
		return
	end
	local unit,filter,filterh,nnl = icon.Unit,icon.Filter,icon.Filterh,icon.NameNameList
	local texture = icon.texture
	local us,un = icon.PresUsableAlpha,icon.AbsentUnUsableAlpha
	for i, iName in pairs(icon.NameList) do
		local buffName, _, iconTexture, count, dispelType, duration, expirationTime,_,_,_,id = UnitAura(unit, nnl[i], nil, filter)
		if TMW.DS[iName] then
			for z=1,60 do --60 because i can and it breaks when there are no more buffs anyway
				buffName, _, iconTexture, count, dispelType, duration, expirationTime,_,_,_,id = UnitAura(unit, z, filter)
				if (not buffName) or (dispelType == iName) then
					break
				end
			end
			if filterh and not buffName then
				for z=1,60 do
					buffName, _, iconTexture, count, dispelType, duration, expirationTime,_,_,_,id = UnitAura(unit, z, filterh)
					if (not buffName) or (dispelType == iName) then
						break
					end
				end
			end
		end
		if filterh and not buffName then
			buffName, _, iconTexture, count, dispelType, duration, expirationTime,_,_,_,id = UnitAura(unit, nnl[i], nil, filterh)
		end
		if buffName and not (id == iName) and tonumber(iName) then
			for z=1,60 do
				buffName, _, iconTexture, count, dispelType, duration, expirationTime,_,_,_,id = UnitAura(unit, z, filter)
				if (not id) or (id == iName) then
					break
				end
			end
			if filterh and not id then
				for z=1,60 do --60 because i can and it breaks when there are no more buffs anyway
					buffName, _, iconTexture, count, dispelType, duration, expirationTime,_,_,_,id = UnitAura(unit, z, filterh)
					if (not id) or (id == iName) then
						break
					end
				end
			end
		end
		if icon.ShowPBar then
			PwrBarUpdate(icon,iName)
		end
		if buffName then
			if count > 1 then
				icon.countText:SetText(count)
			else
				icon.countText:SetText(nil)
			end
			
			texture:SetTexture(iconTexture)
			icon.LearnedTexture = true
			icon:SetAlpha(us)

			if us ~= 0 and un ~= 0 then
				texture:SetVertexColor(pr.r, pr.g, pr.b, 1)
			else
				texture:SetVertexColor(1, 1, 1, 1)
			end
			
			if icon.ShowTimer then  -- and not UnitIsDead(icon.Unit)
				SetCD(icon, expirationTime - duration, duration)
			end
			if icon.ShowCBar then
				CDBarUpdate(icon, expirationTime - duration, duration,true)
			end
			if count and icon.Stacks then
				if (icon.StackMinEnabled and not (icon.StackMin <= count)) or  (icon.StackMaxEnabled and not (count <= icon.StackMax)) then
					local a = icon.StackAlpha
					icon:SetAlpha(a)
					icon.CondtShown = a
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
			end
			if expirationTime ~= 0 and icon.Duration then
				local remaining = expirationTime - GetTime()
				if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
					local a = icon.DurationAlpha
					icon:SetAlpha(a)
					icon.CondtShown = a
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
			end
			icon.CondtShown = icon:GetAlpha()
			if icon.FakeHidden then
				icon:SetAlpha(0)
			end
			return
		end
	end

	icon.cooldownbar:SetValue(-1)
	icon:SetAlpha(un)
	if us ~= 0 and un ~= 0 then
		texture:SetVertexColor(ab.r, ab.g, ab.b, 1)
	else
		texture:SetVertexColor(1, 1, 1, 1)
	end
	
	if icon.NameFirst then
		local t = GetSpellTexture(icon.NameFirst)
		if t then
			texture:SetTexture(t)
		end
	end
	icon.countText:SetText("")
	if icon.ShowTimer then
		SetCD(icon, 0, 0)
	end
	icon.CondtShown = icon:GetAlpha()
	if icon.FakeHidden then
		icon:SetAlpha(0)
	end
end

function TellMeWhen_Icon_Reactive_OnUpdate(icon,elapsed)
	icon.UpdateTimer = icon.UpdateTimer - elapsed
	local name = icon.NameFirst
	local startTime, duration = GetSpellCooldown(name)
	if duration then
		if icon.ShowPBar then
			PwrBarUpdate(icon,name)
		end
		if icon.ShowCBar then
			CDBarUpdate(icon,startTime,duration)
		end
		if (icon.UpdateTimer <= 0) and duration then
			icon.UpdateTimer = UPDATE_INTERVAL
			if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
				local a = icon.ConditionAlpha
				icon:SetAlpha(a)
				icon.CondtShown = a
				if icon.FakeHidden then icon:SetAlpha(0) end
				return
			end
			if duration and icon.Duration then
				local remaining = duration - (GetTime() - startTime)
				if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
					local a = icon.DurationAlpha
					icon:SetAlpha(a)
					icon.CondtShown = a
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
			end
			local usable, nomana = IsUsableSpell(name)
			if icon.IsChakra then
				if UnitAura("player",GetSpellInfo(TMW.Chakra[icon.IsChakra]["buffid"])) then
					usable = true
				else
					usable = false
				end
			end
			local inrange = IsSpellInRange(icon.NameName, "target")
			if (not icon.RangeCheck or inrange == nil) then
				inrange = 1
			end
			if not icon.ManaCheck then
				nomana = nil
			end
			local CD = false
			if icon.CooldownCheck then
				if not (duration == 0 or OnGCD(duration)) then
					CD = true
				end
			end
			if (usable and not CD) then
				if(inrange == 1 and not nomana) then
					icon.texture:SetVertexColor(1,1,1,1)
					icon:SetAlpha(icon.PresUsableAlpha)
				elseif (inrange ~= 1 or nomana) then
					if inrange ~= 1 then
						icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1)
						icon:SetAlpha(icon.PresUsableAlpha*rc.a)
					elseif nomana then
						icon.texture:SetVertexColor(mc.r, mc.g, mc.b, 1)
						icon:SetAlpha(icon.PresUsableAlpha*mc.a)
					end
				else
					icon.texture:SetVertexColor(1,1,1,1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha)
				end
			else
				icon.texture:SetVertexColor(0.5,0.5,0.5,1)
				icon:SetAlpha(icon.AbsentUnUsableAlpha)
			end
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

function TellMeWhen_Icon_WpnEnchant_OnEvent(icon, event, r)
	if (r == "player") then
		local slotID = GetInventorySlotInfo(icon.WpnEnchantType)
		if (not GetInventoryItemID("player",slotID)) and icon.HideUnequipped then
			icon:SetAlpha(0)
			icon:SetScript("OnUpdate", nil)
		else
			icon:SetScript("OnUpdate", TellMeWhen_Icon_WpnEnchant_OnUpdate)
		end
		local wpnTexture = GetInventoryItemTexture("player", slotID)
		if (wpnTexture) then
			icon.texture:SetTexture(wpnTexture)
		else
			icon.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
		end
	end
end

function TellMeWhen_Icon_WpnEnchant_OnUpdate(icon, elapsed)
	icon.UpdateTimer = icon.UpdateTimer - elapsed
	if (icon.UpdateTimer <= 0) then
		icon.UpdateTimer = UPDATE_INTERVAL
		if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
			local a = icon.ConditionAlpha
			icon:SetAlpha(a)
			icon.CondtShown = a
			if icon.FakeHidden then icon:SetAlpha(0) end
			return
		end
		local i = SlotsToNumbers[icon.WpnEnchantType] or 1
		local has, expiration, charges = select(i,GetWeaponEnchantInfo())
		if has then
			expiration = expiration/1000
			if (icon.PresUsableAlpha~= 0) and (icon.AbsentUnUsableAlpha~= 0) then
				icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1)
			else
				icon.texture:SetVertexColor(1, 1, 1, 1)
			end
			icon:SetAlpha(icon.PresUsableAlpha)
			if (charges > 1) then
				icon.countText:SetText(charges)
			else
				icon.countText:SetText("")
			end
			if icon.ShowTimer then
				SetCD(icon, GetTime(), expiration)
			end
			if icon.Duration then
				if (icon.DurationMinEnabled and not (icon.DurationMin <= expiration)) or  (icon.DurationMaxEnabled and not (expiration <= icon.DurationMax)) then
					local a = icon.DurationAlpha
					icon:SetAlpha(a)
					icon.CondtShown = a
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
			end
		else
			if (icon.PresUsableAlpha~= 0) and (icon.AbsentUnUsableAlpha~= 0) then
				icon.texture:SetVertexColor(ab.r, ab.g, ab.b, 1)
			else
				icon.texture:SetVertexColor(1, 1, 1, 1)
			end
			icon:SetAlpha(icon.AbsentUnUsableAlpha)
			SetCD(icon, 0, 0)
		end
		icon.CondtShown = icon:GetAlpha()
		if icon.FakeHidden then
			icon:SetAlpha(0)
		end
	end
end

function TellMeWhen_Icon_Totem_OnUpdate(icon, event, ...)
	if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
		local a = icon.ConditionAlpha
		icon:SetAlpha(a)
		icon.CondtShown = a
		if icon.FakeHidden then icon:SetAlpha(0) end
		return
	end
	for iSlot=1, 4 do
		local _, totemName, startTime, totemDuration, totemIcon = GetTotemInfo(iSlot)
		for i, iName in pairs(icon.NameNameList) do
			if totemName and strfind(strlower(totemName),strlower(iName)) then
				if icon.ShowPBar then
					PwrBarUpdate(icon,iName)
				end
				if icon.ShowCBar then
					CDBarUpdate(icon,startTime,totemDuration,1)
				end
				if (icon.PresUsableAlpha~= 0) and (icon.AbsentUnUsableAlpha~= 0) then
					icon.texture:SetVertexColor(pr.r, pr.g, pr.b, 1)
				else
					icon.texture:SetVertexColor(1, 1, 1, 1)
				end
				icon:SetAlpha(icon.PresUsableAlpha)

				if (icon.texture:GetTexture() ~= totemIcon) then
					icon.texture:SetTexture(totemIcon)
					icon.LearnedTexture = true
				end

				if (icon.ShowTimer) then
					SetCD(icon, startTime, totemDuration)
				end
				if duration and icon.Duration then
					local remaining = duration - (GetTime() - startTime)
					if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
						local a = icon.DurationAlpha
						icon:SetAlpha(a)
						icon.CondtShown = a
						if icon.FakeHidden then icon:SetAlpha(0) end
						return
					end
				end
				
				icon.CondtShown = icon:GetAlpha()
				if icon.FakeHidden then
					icon:SetAlpha(0)
				end
				return
			end
		end
	end
	icon.texture:SetTexture(GetSpellTexture(icon.NameName))
	if (icon.PresUsableAlpha~= 0) and (icon.AbsentUnUsableAlpha~= 0) then
		icon.texture:SetVertexColor(ab.r, ab.g, ab.b, 1)
	else
		icon.texture:SetVertexColor(1, 1, 1, 1)
	end
	icon:SetAlpha(icon.AbsentUnUsableAlpha)
	SetCD(icon, 0, 0)
	icon.CondtShown = icon:GetAlpha()
	if icon.FakeHidden then
		icon:SetAlpha(0)
	end
end

function TellMeWhen_Icon_MultiStateCD_OnEvent(icon,event,...)
	local _, spellID = GetActionInfo(icon.Slot) -- check the current slot first, because it probably didnt change
	if spellID == icon.NameFirst then
		return
	end
	for i=1,120 do
		_, spellID = GetActionInfo(i)
		if spellID == icon.NameFirst then
			icon.Slot = i
			return
		end
	end
end

function TellMeWhen_Icon_MultiStateCD_OnUpdate(icon, elapsed)
	icon.UpdateTimer = icon.UpdateTimer - elapsed
	local startTime, duration = GetActionCooldown(icon.Slot)
	local Name = icon.NameFirst
	if duration then
		if (not icon.ShowTimer) or ((not TellMeWhen_Settings["ClockGCD"]) and OnGCD(duration)) then
			SetCD(icon, 0, 0)
		else
			SetCD(icon, startTime, duration)
		end
		if icon.ShowPBar then
			PwrBarUpdate(icon,Name)
		end
		if icon.ShowCBar then
			CDBarUpdate(icon,startTime,duration)
		end
		if (icon.UpdateTimer <= 0) then
			icon.UpdateTimer = UPDATE_INTERVAL
			icon.texture:SetTexture(GetActionTexture(icon.Slot) or "Interface\\Icons\\INV_Misc_QuestionMark")
			if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
				local a = icon.ConditionAlpha
				icon:SetAlpha(a)
				icon.CondtShown = a
				if icon.FakeHidden then icon:SetAlpha(0) end
				return
			end
			if duration and icon.Duration then
				local remaining = duration - (GetTime() - startTime)
				if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
					local a = icon.DurationAlpha
					icon:SetAlpha(a)
					icon.CondtShown = a
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
			end
			local inrange = IsActionInRange(icon.Slot, "target")
			local _, nomana = IsUsableAction(icon.Slot)
			if not icon.RangeCheck or not inrange then
				inrange = 1
			end
			if not icon.ManaCheck then
				nomana = nil
			end
			if ((duration == 0 or OnGCD(duration)) and inrange == 1 and not nomana) then
				icon.texture:SetVertexColor(1, 1, 1, 1)
				icon:SetAlpha(icon.PresUsableAlpha)
			elseif (icon.PresUsableAlpha ~= 0) then
				if inrange ~= 1 then
					icon.texture:SetVertexColor(rc.r, rc.g, rc.b, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha*rc.a)
				elseif nomana then
					icon.texture:SetVertexColor(mc.r, mc.g, mc.b, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha*mc.a)
				elseif not icon.ShowTimer then
					icon.texture:SetVertexColor(0.5, 0.5, 0.5, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha)
				else
					icon.texture:SetVertexColor(1, 1, 1, 1)
					icon:SetAlpha(icon.AbsentUnUsableAlpha)
				end
			else
				icon.texture:SetVertexColor(1, 1, 1, 1)
				icon:SetAlpha(icon.AbsentUnUsableAlpha)
			end
			icon.CondtShown = icon:GetAlpha()
			if icon.FakeHidden then
				icon:SetAlpha(0)
			end
		end
	end
end

function TellMeWhen_Icon_Cast_OnUpdate(icon, elapsed)
	if (icon.ConditionPresent and not ConditionCheck(icon.Conditions)) then
		local a = icon.ConditionAlpha
		icon:SetAlpha(a)
		icon.CondtShown = a
		if icon.FakeHidden then icon:SetAlpha(0) end
		return
	end
	local unit = icon.Unit
	local us,un = icon.PresUsableAlpha,icon.AbsentUnUsableAlpha
	local name, _, _, iconTexture, startTime, endTime, _, _, notInterruptible = UnitCastingInfo(unit)
	if not name then
		name, _, _, iconTexture, startTime, endTime, _, notInterruptible = UnitChannelInfo(unit)
	end
	if name then
		for i, iName in pairs(icon.NameNameList) do
			if strfind(strlower(name),strlower(iName)) or iName == "" then
				startTime, endTime = startTime/1000, endTime/1000
				if notInterruptible and icon.Interruptible then
					icon:SetAlpha(0)
					icon.CondtShown = 0
					if icon.FakeHidden then icon:SetAlpha(0) end
					return
				end
				local duration = endTime - startTime
				local texture = icon.texture
				texture:SetTexture(iconTexture)
				icon.LearnedTexture = true
				icon:SetAlpha(us)

				if us ~= 0 and un ~= 0 then
					texture:SetVertexColor(pr.r, pr.g, pr.b, 1)
				else
					texture:SetVertexColor(1, 1, 1, 1)
				end
				
				if icon.ShowTimer then
					SetCD(icon, startTime, duration)
				end
				if icon.ShowCBar then
					CDBarUpdate(icon, startTime, duration, true)
				end
				if icon.Duration then
					local remaining = endTime - GetTime()
					if (icon.DurationMinEnabled and not (icon.DurationMin <= remaining)) or  (icon.DurationMaxEnabled and not (remaining <= icon.DurationMax)) then
						local a = icon.DurationAlpha
						icon:SetAlpha(a)
						icon.CondtShown = a
						if icon.FakeHidden then icon:SetAlpha(0) end
						return
					end
				end
				icon.CondtShown = icon:GetAlpha()
				if icon.FakeHidden then
					icon:SetAlpha(0)
				end
				return
			end
		end
	end

	icon.cooldownbar:SetValue(-1)

	icon:SetAlpha(un)
	if us ~= 0 and un ~= 0 then
		icon.texture:SetVertexColor(ab.r, ab.g, ab.b, 1)
	else
		icon.texture:SetVertexColor(1, 1, 1, 1)
	end

	icon.countText:SetText("")
	if (icon.ShowTimer) then
		SetCD(icon, 0, 0)
	end
	icon.CondtShown = icon:GetAlpha()
	if icon.FakeHidden then
		icon:SetAlpha(0)
	end
end

function TellMeWhen_Icon_Meta_OnUpdate(icon,elapsed)
	for k,i in pairs(icon.Icons) do
		local ic = _G[i]
		if ic then
			local shown = ic:IsShown() and ic:GetParent():IsShown() and ic.CondtShown > 0
			if shown then
				icon.cooldown.noCooldownCount = ic.cooldown.noCooldownCount
				local icont, ict = icon.texture, ic.texture
				icont:SetTexture(ict:GetTexture())
				icont:SetVertexColor(ict:GetVertexColor())
				local a = ic.CondtShown
				icon:SetAlpha(a)
				icon.CondtShown = a
				SetCD(icon,ic.Start,ic.Duration)
				icon.cooldown:SetReverse(ic.cooldown:GetReverse())
				icon.countText:SetText(ic.countText:GetText())
				if ic.ShowPBar then
					local iconpb, icpb = icon.powerbar, ic.powerbar
					iconpb:SetMinMaxValues(icpb:GetMinMaxValues())
					iconpb:SetValue(icpb:GetValue())
					iconpb:SetStatusBarColor(icpb:GetStatusBarColor())
					iconpb.texture:SetTexCoord(icpb.texture:GetTexCoord())
				end
				if ic.ShowCBar then
					local iconcb, iccb = icon.cooldownbar, ic.cooldownbar
					iconcb:SetMinMaxValues(iccb:GetMinMaxValues())
					iconcb:SetValue(iccb:GetValue())
					iconcb:SetStatusBarColor(iccb:GetStatusBarColor())
					iconcb.texture:SetTexCoord(iccb.texture:GetTexCoord())
				end
				return
			end
		end
	end
	icon:SetAlpha(0)
	icon.CondtShown = 0
end


do --Condition functions
	TMW_CNDT.HEALTH = function(condition)
		local percent = 100 * UnitHealth(condition.Unit)/UnitHealthMax(condition.Unit)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.DEFAULT = function(condition)
		local percent = 100 * UnitPower(condition.Unit)/UnitPowerMax(condition.Unit)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.MANA = function(condition)
		local percent = 100 * UnitPower(condition.Unit,0)/UnitPowerMax(condition.Unit,0)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.RAGE = function(condition)
		local percent = 100 * UnitPower(condition.Unit,1)/UnitPowerMax(condition.Unit,1)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.FOCUS = function(condition)
		local percent = 100 * UnitPower(condition.Unit,2)/UnitPowerMax(condition.Unit,2)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.ENERGY = function(condition)
		local percent = 100 * UnitPower(condition.Unit,3)/UnitPowerMax(condition.Unit,3)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.RUNIC_POWER = function(condition)
		local percent = 100 * UnitPower(condition.Unit,6)/UnitPowerMax(condition.Unit,6)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.HAPPINESS = function(condition)
		local number = GetPetHappiness() or 0
		return TMW_OP[condition.Operator](condition.Level, number)
	end
	TMW_CNDT.SOUL_SHARDS = function(condition)
		local number = UnitPower("player",7)
		return TMW_OP[condition.Operator](condition.Level, number)
	end
	TMW_CNDT.ECLIPSE = function(condition)
		local percent = 100 * UnitPower(condition.Unit,8)/UnitPowerMax(condition.Unit,8)
		return TMW_OP[condition.Operator](condition.Level, percent)
	end
	TMW_CNDT.HOLY_POWER = function(condition)
		local number = UnitPower("player",9)
		return TMW_OP[condition.Operator](condition.Level, number)
	end
	TMW_CNDT.ECLIPSE_DIRECTION = function(condition)
		if condition.Level <= 0 then return GetEclipseDirection() == "moon"  --  (<=) because it used to be -1 and i dont want to upgrade it
		elseif condition.Level == 1 then return GetEclipseDirection() == "sun"
		else return false end
	end
	TMW_CNDT.ICON = function(condition)
		local icon = _G[condition.Icon]
		if icon and icon:GetParent():IsShown() then
			if condition.Level == 0 then return ((icon.CondtShown or 0) > 0)
			elseif condition.Level == 1 then return ((icon.CondtShown or 0) == 0)
			else return false end
		else return false end
	end
	TMW_CNDT.COMBO = function(condition)
		local number = GetComboPoints("player",condition.Unit)
		return TMW_OP[condition.Operator](condition.Level, number)
	end
	TMW_CNDT.EXISTS = function(condition)
		return ((condition.Level == 1) == not UnitExists(condition.Unit)) --the not turns it into a true/false instead of 1/nil (instead of ((condition.Level == 0) == UnitExists(condition.Unit)) )
	end
	TMW_CNDT.ALIVE = function(condition)
		return (((condition.Level == 0) == (not UnitIsDeadOrGhost(condition.Unit))) and UnitExists(condition.Unit))
	end
	TMW_CNDT.SPEC = function(condition)
		return (condition.Level == GetActiveTalentGroup())
	end
	TMW_CNDT.REACT = function(condition)
		if (UnitIsEnemy("player", condition.Unit)) or ((UnitReaction("player", condition.Unit) or 5) <= 4) then
			return condition.Level == 1
		else
			return condition.Level == 2
		end
	end
	TMW_CNDT.COMBAT = function(condition)
		return (condition.Level == 1) == not UnitAffectingCombat(condition.Unit)
	end

	TMW_OP["=="] = function(a, b)
		return b == a
	end
	TMW_OP["<"] = function(a, b)
		return b < a
	end
	TMW_OP["<="] = function(a, b)
		return b <= a
	end
	TMW_OP[">"] = function(a, b)
		return b > a
	end
	TMW_OP[">="] = function(a, b)
		return b >= a
	end
	TMW_OP["~="] = function(a, b)
		return b ~= a
	end

	TMW_AO["OR"] = function(a,b)
		return a or b
	end
	TMW_AO["AND"] = function(a,b)
		return a and b
	end
end


-- -------------
-- NAME FUNCTIONS
-- -------------

function TellMeWhen_EquivToTable(name)
	local names, tab
	for k,v in pairs(TMW.BE) do
		if TMW.BE[k][name] then
			names = TMW.BE[k][name]
			break
		end
	end
	if not names then return false end
	if strfind(names,";") then
		tab = { strsplit(";", names) }
	else
		tab =  { names }
	end
	for a,b in pairs(tab) do
		local new = strtrim(tostring(b))
		tab[a] = tonumber(new) or tostring(new)
	end
	return tab
end

function TellMeWhen_GetSpellNames(icon,setting,firstOnly,toname)
	local buffNames,buffNamesNames = {},{}
	local settings = TellMeWhen_SplitNames(setting)
	for k,v in pairs(settings) do
		local eqtt = TellMeWhen_EquivToTable(v)
		if eqtt then
			for z,x in pairs(eqtt) do
				tinsert(buffNames,x)
			end
		else
			tinsert(buffNames,v)
		end
	end
	for k,v in pairs(TMW.Chakra) do
		if GetSpellInfo(v.abid) == buffNames[1] then
			buffNames[1] = v.abid
			icon.IsChakra = k
		end
		if v.abid == tonumber(buffNames[1]) then
			icon.IsChakra = k
		end
	end
	if toname then
		if (firstOnly) then
			return GetSpellInfo(buffNames[1])
		else
			for k,v in pairs(buffNames) do
				buffNamesNames[k] = GetSpellInfo(buffNames[k]) or buffNames[k]
			end
			return buffNamesNames
		end
	end
	if (firstOnly) then
		return buffNames[1]
	end
	return buffNames
end

function TellMeWhen_GetItemIDs(icon,item,firstOnly)
	item = strtrim(tostring(item))
	local itemID = tonumber(item)
	if (not itemID) then
		local _,itemLink = GetItemInfo(item)
		if itemLink then
			_, _, itemID = strfind(itemLink, ":(%d+)")
		end
	elseif (itemID <= 19) then
		icon.Slot = itemID
		itemID = GetInventoryItemID("player",itemID)
	end
	return tonumber(itemID) or 0
end

function TellMeWhen_CleanString(text)
	text = strtrim(text,"; \t\r\n")
	while strfind(text," ;") do
		text = gsub(text," ;","; ")
	end
	while strfind(text,";  ") do
		text = gsub(text,";  ","; ")
	end
	while strfind(text,";;") do
		text = gsub(text,";;",";")
	end
	return text
end

function TellMeWhen_SplitNames(input)
	local buffNames = {}
	-- If input contains one or more semicolons, split the list into parts
	if strfind(input,";") then
		buffNames = { strsplit(";", input) }
	else
		buffNames = { input }
	end
	for a,b in pairs(buffNames) do --remove spaces from the beginning and end of each name
		local new = strtrim(tostring(b)) or error("Error removing spaces from:" .. a .. ":" .. b ..":.")
		buffNames[a] = tonumber(new) or tostring(new)
	end
	return buffNames
end


function TellMeWhen_SkinCallback(arg, SkinID, Gloss, Backdrop, Group, Button, Colors)
	if Group and SkinID then
		local groupID = tonumber(strmatch(Group,"%d+")) --Group is a string like "Group 5", so cant use :GetID()
		TellMeWhen_Settings.Groups[groupID]["LBF"]["SkinID"] = SkinID
		TellMeWhen_Settings.Groups[groupID]["LBF"]["Gloss"] = Gloss
		TellMeWhen_Settings.Groups[groupID]["LBF"]["Backdrop"] = Backdrop
		TellMeWhen_Settings.Groups[groupID]["LBF"]["Colors"] = Colors
	end
	if not TMW.DontRun then
		TellMeWhen_Update()
	else
		TMW.DontRun = false
	end
end














