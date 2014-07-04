require "Window"
require "GameLib"
 
-----------------------------------------------------------------------------------------------
-- InstanceTimer Module Definition
-----------------------------------------------------------------------------------------------
local InstanceTimer = {}
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local anchorOffsets = nil
local countTo = nil
local currentInstance = nil
local alertSound = 212
local timers = {
	["Sanctuary of the Swordmaiden"] = 75 * 60,
	["Skullcano Island"] = 45 * 60,
	["Ruins of Kel Voreth"] = 40 * 60,
	["Stormtalon's Lair"] = 30 * 60
}
local shown = false -- initial state of the countdown timer window
local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:GetLocale("InstanceTimer", true)

 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function InstanceTimer:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	o.tItems = {} -- keep track of all the list items
	o.wndSelectedListItem = nil -- keep track of which list item is currently selected

    return o
end

function InstanceTimer:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- InstanceTimer OnLoad
-----------------------------------------------------------------------------------------------
function InstanceTimer:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("InstanceTimer.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- InstanceTimer OnDocLoaded
-----------------------------------------------------------------------------------------------
function InstanceTimer:OnDocLoaded()
	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.timerWindow = Apollo.LoadForm(self.xmlDoc, "MedalTimer", nil, self)
		if self.timerWindow == nil then
			Apollo.AddAddonErrorText(self, L["loadError"])
			return
		end
		
		if anchorOffsets ~= nil then
			self.timerWindow:SetAnchorOffsets(unpack(anchorOffsets))
		end
		
		self.countDownTimeText = self.timerWindow:FindChild("cdTime")
	    self.timerWindow:Show(shown, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.CreateTimer("count", 1.0, true)
		Apollo.RegisterTimerHandler("count", "onCount", self)
		Apollo.RegisterSlashCommand("instancetime", "onTimeRequest", self)
		Apollo.RegisterEventHandler("MatchEntered", "onMatch", self)
		Apollo.RegisterEventHandler("Group_Left", "onLeave", self)
	end
end

-----------------------------------------------------------------------------------------------
-- InstanceTimerForm Functions
-----------------------------------------------------------------------------------------------
-- General Functions
function interp(s, tab)
	return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

function SecondsToClock(nSeconds, stringFormat, interpolate)
	if nSeconds <= 0 then
		return L["onFail"];
	else
		nHours = math.floor(nSeconds/3600);
		nMins = math.floor(nSeconds/60 - (nHours*60));
		nSecs = math.floor(nSeconds - nHours*3600 - nMins *60);
		if interpolate then
			return interp(stringFormat, { h = nHours, m = nMins, s = nSecs })
		else
			return string.format(stringFormat, nHours, nMins, nSecs)
		end
	end
end

function getZone()
	return GameLib.GetCurrentZoneMap()["strName"]
end

function PrintSystem(s)
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_System, s, L["prefix"])
end

-- when the Close button is clicked
function InstanceTimer:TimerClose()
	countTo = nil
	self.timerWindow:Close() -- hide the window
	shown = false
end

function InstanceTimer:onCount()
	if countTo == nil then return; end
	if not shown then
		shown = true;
		self.timerWindow:Show(shown, true)
	end
	
	difference = countTo - os.time()
	self.countDownTimeText:SetText(SecondsToClock(difference, L["countdownFormat"], false))
	if difference <= 0 then
		self:onFail()
		countTo = nil
	end
end

function InstanceTimer:onMatch()
	-- Leave/Enter detection
	if currentInstance ~= nil then return end
	
	self.countDownTimeText:SetText("Started")
	currentInstance = {
		enterTime = os.time(),
		name = getZone(),
		finished = false
	}
	if timers[currentInstance.name] ~= nil then
		countTo = os.time() + timers[currentInstance.name]
	else countTo = nil; end
end

function InstanceTimer:onFail()
	Sound.Play(alertSound)
	PrintSystem(interp(L["failedMessage"], { instance = currentInstance.name }))
end

function InstanceTimer:onLeave()
	self:TimerClose()
	currentInstance = nil
end

function InstanceTimer:onTimeRequest()
	if currentInstance == nil then PrintSystem(L["notInInstance"]); return; end
	PrintSystem(interp(L["spentResponse"], { instance = currentInstance.name, timeSpent = SecondsToClock(os.time() - currentInstance.enterTime, L["spentFormat"], true) }))
end

-----------------------------------------------------------------------------------------------
-- InstanceTimerForm Restore/Save
-----------------------------------------------------------------------------------------------

function InstanceTimer:OnSave(eLevel)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return nil
    end
	
	local tSaveData = {}
	tSaveData.currentInstance = currentInstance
	tSaveData.countTo = countTo
	tSaveData.l, tSaveData.t, tSaveData.r, tSaveData.b = self.timerWindow:GetAnchorOffsets()
	return tSaveData
end

function InstanceTimer:OnRestore(eLevel, tData)
	if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character then
        return
    end	

	if tData then
		if tData.r then
			anchorOffsets = { tData.l, tData.t, tData.r, tData.b }
		end
		
		if tData.currentInstance ~= nil and getZone() == tData.currentInstance.name then
			currentInstance = tData.currentInstance
			countTo = tData.countTo
		end
	end
end


-------------------------------------------
----------------------------------------------------
-- InstanceTimer Instance
-----------------------------------------------------------------------------------------------
local InstanceTimerInst = InstanceTimer:new()
InstanceTimerInst:Init()
