PHB = PHB or {}
PHB.name = "PetHealthBars"
PHB.version = "1.0"
PHB.savedVars = {}
PHB.default = {
	width = 100,
	height = 40,
	x = 400,
	y = 400,
	mov = false,
	fontsize = 19,
	barcolor = {0.7, 0.2, 0.7, 0.7},
	
}

PHB.UIUtil = {}
PHB.UI = {}
PHB.UI.bars = {}


function PHB.OnLoaded(_, addonName)
    if addonName ~= PHB.name then return end
	PHB.savedVars = ZO_SavedVars:NewAccountWide("PHBVars", 2, nil, PHB.default)
	zo_callLater(PHB.InitUI, 400)
	PHB.CreateSettings()
    EVENT_MANAGER:UnregisterForEvent(PHB.name, EVENT_ADD_ON_LOADED)
end

function PHB.InitUI()
	PHB.UI.topWindow = PHB.UI.topWindow or WINDOW_MANAGER:CreateTopLevelWindow("PHBTopWindow")
	PHB.UI.topBackdrop = PHB.UI.topWindow:CreateControl("PHBTopWindowBack", CT_BACKDROP)
	for i=1,7 do
		PHB.UI.bars[i] = PHB.UIUtil.bar(i, PHB.UI.topWindow, PHB.savedVars.width, PHB.savedVars.height, {0, (PHB.savedVars.height*2+10)*(i-1)})
	end
	
	PHB.LoadUI()
end

function PHB.LoadUI()
	PHB.UI.topWindow:SetDimensions(PHB.savedVars.width, #PHB.UI.bars*(PHB.savedVars.height*2+10)+10)
	PHB.UI.topWindow:ClearAnchors()
	PHB.UI.topWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PHB.savedVars.x, PHB.savedVars.y)
	PHB.UI.topWindow:SetMovable(PHB.savedVars.mov)
	PHB.UI.topWindow:SetMouseEnabled(PHB.savedVars.mov)
	
	PHB.UI.topBackdrop:SetDimensions(PHB.savedVars.width, #PHB.UI.bars*(PHB.savedVars.height*2+10))
	PHB.UI.topBackdrop:ClearAnchors()
	PHB.UI.topBackdrop:SetAnchor(TOPLEFT, PHB.UI.topWindow, TOPLEFT, -1, -1)
	PHB.UI.topBackdrop:SetEdgeTexture("", 8,1,0)
	--PHB.UI.topBackdrop:SetEdgeColor(0.8, 0.2, 0.8, 0.6)
	--PHB.UI.topBackdrop:SetCenterColor(0.9, 0.9, 0.9, 0.2)
	PHB.UI.topBackdrop:SetEdgeColor(0.8, 0.2, 0.8, 0)
	PHB.UI.topBackdrop:SetCenterColor(0.9, 0.9, 0.9, 0)
	
	for i,v in pairs (PHB.UI.bars) do
		v:SetWidth(PHB.savedVars.width)
		v:SetHeight(PHB.savedVars.height)
		v:SetFontSize(PHB.savedVars.fontsize)
		v:SetBarColor(PHB.savedVars.barcolor)
	end
	
	
	
	PHB.UpdateBars()
end

function PHB.UpdateBars()
	for i,v in pairs(PHB.UI.bars) do
		v:Update(-1)
	end
end

function PHB.SetHidden(b)
	for i, v in pairs(PHB.UI.bars) do
		v:SetHidden(b)
	end
end

function PHB.Preview()
	PHB.LoadUI()
	for i, v in pairs(PHB.UI.bars) do
		v:SetHidden(b)
		v:Demo()
	end
end

-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED listener.
function PHB.Shield1(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        PHB.UI.bars[id]:Update(value)
    end
end

-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED listener.
function PHB.Shield2(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        PHB.UI.bars[id]:Update(0)
    end
end

-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED listener.
function PHB.Shield3(eventCode, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue)
	if unitTag:sub(1, 9) ~= "playerpet" then return end
	local id = unitTag:sub(-1, -1)+0
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        PHB.UI.bars[id]:Update(newValue)
    end
end

function PHB.OnSceneChange(sceneName, oldState, newState)
	if newState == SCENE_SHOWN then --all scenes closed
		PHB.SetHidden(false)
	elseif newState == SCENE_HIDDEN then --a scene opened
		PHB.SetHidden(false)
	end
end

function PHB.CreateSettings()
	
	local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")
	
	local panelData = {
			type = "panel",
			name = PHB.name,
			displayName = "Pet Health Bars",
			author = "Acer",
			version = PHB.version,
			registerForRefresh = true,
			slashCommand = "/phb",
		}
		
	LAM2:RegisterAddonPanel("PetHealthBars", panelData)
	
	local optionsData = {
		{
			type = "header",
			name = "Pet Health Bar Settings",
		},
		{
			type = "description",
			text = "When changing height or font size, the gaps between bars will not update until the next ReloadUI.",
		},
		{
            type = "checkbox",
            name = "Window Unlocked",
            tooltip = "Unlock window",
			getFunc = function() return PHB.savedVars.mov end,
            setFunc = function(t)
				if not t then
					PHB.savedVars.x = PHB.UI.topWindow:GetLeft()
					PHB.savedVars.y = PHB.UI.topWindow:GetTop()
				end
				PHB.savedVars.mov = t
				PHB.LoadUI()
				if t then
					PHB.Preview()
				end
			end,
        },
		{
			type = "slider",
			name = "Width",
			tooltip = "Width of the health bars",
			min = 100,
			max = 300,
			step = 10,
			getFunc = function() return PHB.savedVars.width end,
			setFunc = function(x) 
				PHB.savedVars.width = x
				PHB.Preview()
			end,
		},
		{
			type = "slider",
			name = "Height",
			tooltip = "Height of the health bars",
			min = 20,
			max = 100,
			step = 10,
			getFunc = function() return PHB.savedVars.height end,
			setFunc = function(x) 
				PHB.savedVars.height = x
				PHB.Preview()
			end,
		},
		{
			type = "slider",
			name = "Font Size",
			tooltip = "Font size of the health bars",
			min = 12,
			max = 24,
			step = 1,
			getFunc = function() return PHB.savedVars.fontsize end,
			setFunc = function(x) 
				PHB.savedVars.fontsize = x
				PHB.Preview()
			end,
		},
		{
			type = "colorpicker",
			name = "Bar Colour",
			tooltip = "Colour of the health bars",
			getFunc = function() return unpack(PHB.savedVars.barcolor) end,
			setFunc = function(r, g, b, a) 
				PHB.savedVars.barcolor = {r, g, b, a}
				PHB.Preview()
			end,
		},
		{
			type = "button",
			name = "Stop Preview",
			tooltip =  "Stop showing the preview shown when editing any settings",
			func = function() PHB.LoadUI() end,
		}
	}
	
	
	LAM2:RegisterOptionControls("PetHealthBars", optionsData)

end

SLASH_COMMANDS["/rl"] = function(a) ReloadUI() end

EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_ADD_ON_LOADED, PHB.OnLoaded)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_COMBAT_EVENT, PHB.UpdateBars)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, PHB.Shield1)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, PHB.Shield2)
EVENT_MANAGER:RegisterForEvent(PHB.name, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, PHB.Shield3)
SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", PHB.OnSceneChange)