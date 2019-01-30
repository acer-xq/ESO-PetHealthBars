function PHB.UIUtil.bar(id, parent, width, height, offset)
	if parent == nil then return end
	if (id < 1 or id > 7 ) then return end
	local bar = {}
	bar = {
		hp = 0,
		hpmax  = 0,
		shield = 0,
		id = id,
		unitTag = "playerpet"..id,
		
		_back = PHB.UIUtil._backdrop("PHBBar"..id.."Back", parent, {offset[1],offset[2]+height}, width, height, {0.1,0.1,0.1,0.7}, {0.1,0.1,0.1,1}),
		_bar = PHB.UIUtil._bar("PHBBar"..id.."Bar", parent, {offset[1],offset[2]+height}, width-2, height-2, {0.7, 0.2, 0.7}, 0.7),
		_label1 = PHB.UIUtil._label("PHBBar"..id.."Label1", parent, {offset[1],offset[2]+height}, width, height, "$(BOLD_FONT)|$(KB_19)|soft-shadow-thin", 1),
		_label2 = PHB.UIUtil._label("PHBBar"..id.."Label2", parent, offset, width, height, "$(BOLD_FONT)|$(KB_22)|soft-shadow-thick", 1),
		
		Update = function(self, s)
			self.hp, self.hpmax, _ = GetUnitPower(self.unitTag, -2)
			
			self:SetHidden(self.hpmax < 1)
			if s > -1 then self.shield = s end
			if self.hp == 0 then self.shield = 0 end
			
			self:SetMax(self.hpmax)
			self:SetVal(self.hp)
			local str1 = self.hp..""
			if self.shield > 0 then str1 = str1.." + "..self.shield end
			local str2 = self.hpmax..""
			self._label1:SetText(str1.."/"..str2)
			self._label2:SetText(GetUnitName(self.unitTag))
		end,
		
		Demo = function(self)
			self:SetMax(7)
			self:SetVal(self.id)
			local d = {
				"99999/99999", "12345/67890", "0/0", "10 + 10/20", "50000 + 10000/50000"
			}
			self._label1:SetText(d[self.id%6])
			self._label2:SetText(self.unitTag)
		end,
		
		SetWidth = function(self, w)
			self._back:SetWidth(w)
			self._bar:SetWidth(w-2)
			self._label1:SetWidth(w)
			self._label2:SetWidth(w)
		end,
		
		SetHeight = function(self, h)
			self._back:SetHeight(h)
			self._bar:SetHeight(h-2)
			self._label1:SetHeight(h)
			self._label2:SetHeight(h)
		end,
		
		SetBarColor = function(self, c)
			self._bar:SetColor(c[1], c[2], c[3])
			self._bar:SetAlpha(c[4])
		end,
		
		SetFontSize = function(self, f)
			self._label1:SetFont("$(BOLD_FONT)|$(KB_"..f..")|soft-shadow-thin")
			self._label2:SetFont("$(BOLD_FONT)|$(KB_"..(f+3)..")|soft-shadow-thick")
		end,
		
		SetMax = function(self, max)
			self._bar:SetMinMax(0, max)
		end,
		
		
		SetVal = function(self, val)
			--self._bar:SetValue(val)
			ZO_StatusBar_SmoothTransition(self._bar, val, self:GetMax(), false, nil, 150)
		end,
		
        SetHidden = function(self, state)
            self._back:SetHidden(state)
            self._bar:SetHidden(state)
            self._label1:SetHidden(state)
			self._label2:SetHidden(state)
        end,
		
		GetMax = function(self)
			min, max = self._bar:GetMinMax()
			return max
		end,
	}
	
	return bar
end

function PHB.UIUtil.backdrop(name, parent, offset, width, height, centerColor, edgeColor)
	if parent == nil then return end
	local bd = {}
	bd = {
		back = PHB.UIUtil._backdrop(name, parent, offset, width, height, centerColor, edgeColor),
		
		SetHeight = function(self, x)
			self.back:SetHeight(x)
		end,
		
		SetWidth = function(self, x)
			self.back:SetWidth(x)
		end,
		
		GetHeight = function(self)
			return self.back:GetHeight()
		end,
		
		GetWidth = function(self)
			return self.back:GetWidth()
		end,
	}
	return bd
end

function PHB.UIUtil._bar(name, parent, offset, width, height, color, alpha)
	if parent == nil then return end
	local b = parent:CreateControl(name, CT_STATUSBAR)
	b:SetDimensions(width, height)
	b:SetAnchor(TOPLEFT, parent, TOPLEFT, offset[1], offset[2])
	b:SetColor(unpack(color))
	b:SetAlpha(alpha)
	return b
end

function PHB.UIUtil._label(name, parent, offset, width, height, font, valign)
	if parent == nil then return end
	local l = parent:CreateControl(name, CT_LABEL)
	l:SetDimensions(width, height)
	l:SetAnchor(TOPLEFT, parent, TOPLEFT, offset[1], offset[2])
	l:SetAlpha(1)
	l:SetFont(font)
	l:SetDrawLayer(DL_TEXT)
	l:SetVerticalAlignment(valign)
	return l
end

function PHB.UIUtil._backdrop(name, parent, offset, width, height, centerColor, edgeColor)
	if parent == nil then return end
	local back = parent:CreateControl(name, CT_BACKDROP)
	back:SetDimensions(width, height)
    back:ClearAnchors()
    back:SetAnchor( TOPLEFT, parent, TOPLEFT, offset[1]-1, offset[2]-1 )
    back:SetEdgeTexture("", 8,1,0)
    back:SetEdgeColor(unpack(edgeColor))
    back:SetCenterColor(unpack(centerColor))
	return back
end