local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local L = LibStub("AceLocale-3.0"):GetLocale("SpartanUI", true);
local Artwork_Core = spartan:GetModule("Artwork_Core");
local module = spartan:GetModule("Style_Transparent");
----------------------------------------------------------------------------------------------------
local anchor, frame = Transparent_AnchorFrame, Transparent_SpartanUI, CurScale

function module:updateViewport() -- handles viewport offset based on settings
	if not InCombatLockdown() and (Transparent_SpartanUI_Base5:GetHeight() ~= 0) then
		WorldFrame:ClearAllPoints();
		WorldFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0);
		if Transparent_SpartanUI_Base5:IsVisible() then
			WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);
		else
			WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0);
		end
	end
end;

function module:updateScale() -- scales SpartanUI based on setting or screen size
	if (not DB.scale) then -- make sure the variable exists, and auto-configured based on screen size
		local width, height = string.match(GetCVar("gxResolution"),"(%d+).-(%d+)");
		if (tonumber(width) / tonumber(height) > 4/3) then DB.scale = 0.92;
		else DB.scale = 0.78; end
	end
	if DB.scale ~= CurScale then
		module:updateViewport();
		if (DB.scale ~= Artwork_Core:round(Transparent_SpartanUI:GetScale())) then
			frame:SetScale(DB.scale);
		end
		if DB.scale <= .75 then
			Transparent_SpartanUI_Base3:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT");
			Transparent_SpartanUI_Base5:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT");
		else
			Transparent_SpartanUI_Base3:ClearAllPoints();
			Transparent_SpartanUI_Base5:ClearAllPoints();
			Transparent_SpartanUI_Base3:SetPoint("RIGHT", Transparent_SpartanUI_Base2, "LEFT");
			Transparent_SpartanUI_Base5:SetPoint("LEFT", Transparent_SpartanUI_Base4, "RIGHT");
		end
		CurScale = DB.scale
	end
end;

function module:updateAlpha() -- scales SpartanUI based on setting or screen size
	if DB.alpha then
		Transparent_SpartanUI_Base1:SetAlpha(DB.alpha);
		Transparent_SpartanUI_Base2:SetAlpha(DB.alpha);
		Transparent_SpartanUI_Base3:SetAlpha(DB.alpha);
		Transparent_SpartanUI_Base4:SetAlpha(DB.alpha);
		Transparent_SpartanUI_Base5:SetAlpha(DB.alpha);
	end
end;

function module:updateOffset() -- handles SpartanUI offset based on setting or fubar / titan
	local fubar,ChocolateBar,titan,offset = 0,0,0;

	if not DB.yoffsetAuto then
		offset = max(DB.yoffset,1);
	else
		for i = 1,4 do -- FuBar Offset
			if (_G["FuBarFrame"..i] and _G["FuBarFrame"..i]:IsVisible()) then
				local bar = _G["FuBarFrame"..i];
				local point = bar:GetPoint(1);
				if point == "BOTTOMLEFT" then fubar = fubar + bar:GetHeight(); end
			end
		end
		for i = 1,100 do -- Chocolate Bar Offset
			if (_G["ChocolateBar"..i] and _G["ChocolateBar"..i]:IsVisible()) then
				local bar = _G["ChocolateBar"..i];
				local point = bar:GetPoint(1);
				--if point == "TOPLEFT" then ChocolateBar = ChocolateBar + bar:GetHeight(); 	end--top bars
				if point == "RIGHT" then ChocolateBar = ChocolateBar + bar:GetHeight(); 	end-- bottom bars
			end
		end
		TitanBarOrder = {[1]="AuxBar2", [2]="AuxBar"} -- Bottom 2 Bar names
		for i=1,2 do -- Titan Bar Offset
			if (_G["Titan_Bar__Display_"..TitanBarOrder[i]] and TitanPanelGetVar(TitanBarOrder[i].."_Show")) then
				local PanelScale = TitanPanelGetVar("Scale") or 1
				local bar = _G["Titan_Bar__Display_"..TitanBarOrder[i]]
				titan = titan + (PanelScale * bar:GetHeight());
			end
		end
		
		offset = max(fubar + titan + ChocolateBar,1);
	end
	if (Artwork_Core:round(offset) ~= Artwork_Core:round(anchor:GetHeight())) then anchor:SetHeight(offset); end
	DB.yoffset = offset
end;

function module:updateXOffset() -- handles SpartanUI offset based on setting or fubar / titan
	if not DB.xOffset then return 0; end
	local offset = DB.xOffset
	if Artwork_Core:round(offset) <= -300 then
		Transparent_SpartanUI_Base5:ClearAllPoints();
		Transparent_SpartanUI_Base5:SetPoint("LEFT", Transparent_SpartanUI_Base4, "RIGHT");
		Transparent_SpartanUI_Base5:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT");
	elseif Artwork_Core:round(offset) >= 300 then
		Transparent_SpartanUI_Base3:ClearAllPoints();
		Transparent_SpartanUI_Base3:SetPoint("RIGHT", Transparent_SpartanUI_Base2, "LEFT");
		Transparent_SpartanUI_Base3:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT");
	end
	Transparent_SpartanUI:SetPoint("LEFT", Transparent_AnchorFrame, "LEFT", offset, 0)
	if (Artwork_Core:round(offset) ~= Artwork_Core:round(anchor:GetWidth())) then anchor:SetWidth(offset); end
	DB.xOffset = offset
end;

----------------------------------------------------------------------------------------------------

function module:InitFramework()
	do -- default interface modifications
		SUI_FramesAnchor:SetFrameStrata("BACKGROUND");
		SUI_FramesAnchor:SetFrameLevel(1);
		SUI_FramesAnchor:SetParent(Transparent_SpartanUI);
		SUI_FramesAnchor:ClearAllPoints();
		SUI_FramesAnchor:SetPoint("BOTTOMLEFT", "Transparent_AnchorFrame", "TOPLEFT", 0, 0);
		SUI_FramesAnchor:SetPoint("TOPRIGHT", "Transparent_AnchorFrame", "TOPRIGHT", 0, 155);
		
		Artwork_Core:MoveTalkingHeadUI()
		
		MainMenuBarVehicleLeaveButton:HookScript("OnShow", function() 
			MainMenuBarVehicleLeaveButton:ClearAllPoints()
			MainMenuBarVehicleLeaveButton:SetPoint("BOTTOM",Transparent_SpartanUI,"TOP",0,20)
		end)
		
		FramerateText:ClearAllPoints();
		FramerateText:SetPoint("BOTTOM", "Transparent_SpartanUI_Base1", "TOP", 0, 0);
		
		MainMenuBar:Hide();
		hooksecurefunc(Transparent_SpartanUI,"Hide",function() module:updateViewport(); end);
		hooksecurefunc(Transparent_SpartanUI,"Show",function() module:updateViewport(); end);
		--Transparent_SpartanUI:SetAlpha(.5);
		--Transparent_SpartanUI:SetVertexColor(0,.8,.9,.1)
		
		hooksecurefunc("UpdateContainerFrameAnchors",function() -- fix bag offsets
			local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column
			local screenWidth = GetScreenWidth()
			local containerScale = 1
			local leftLimit = 0
			if ( BankFrame:IsShown() ) then
				leftLimit = BankFrame:GetRight() - 25
			end
			while ( containerScale > CONTAINER_SCALE ) do
				screenHeight = GetScreenHeight() / containerScale
				-- Adjust the start anchor for bags depending on the multibars
				xOffset = 1 / containerScale
				yOffset = 155;
				-- freeScreenHeight determines when to start a new column of bags
				freeScreenHeight = screenHeight - yOffset
				leftMostPoint = screenWidth - xOffset
				column = 1
				local frameHeight
				for index, frameName in ipairs(ContainerFrame1.bags) do
					frameHeight = getglobal(frameName):GetHeight()
					if ( freeScreenHeight < frameHeight ) then
						-- Start a new column
						column = column + 1
						leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset
						freeScreenHeight = screenHeight - yOffset
					end
					freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING
				end
				if ( leftMostPoint < leftLimit ) then
					containerScale = containerScale - 0.01
				else
					break
				end
			end
			if ( containerScale < CONTAINER_SCALE ) then
				containerScale = CONTAINER_SCALE
			end
			screenHeight = GetScreenHeight() / containerScale
			-- Adjust the start anchor for bags depending on the multibars
			xOffset = 1 / containerScale
			yOffset = 154
			-- freeScreenHeight determines when to start a new column of bags
			freeScreenHeight = screenHeight - yOffset
			column = 0
			for index, frameName in ipairs(ContainerFrame1.bags) do
				frame = getglobal(frameName)
				frame:SetScale(containerScale)
				if ( index == 1 ) then
					-- First bag
					frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, (yOffset + (DB.yoffset or 1)) * (DB.scale or 1) )
				elseif ( freeScreenHeight < frame:GetHeight() ) then
					-- Start a new column
					column = column + 1
					freeScreenHeight = screenHeight - yOffset
					frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset )
				else
					-- Anchor to the previous bag
					frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING)
				end
				freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING
			end
		end);
	end
end

function module:TooltipLoc(self, parent)
	if (parent == "UIParent") then
		tooltip:ClearAllPoints();
		tooltip:SetPoint("BOTTOMRIGHT","Transparent_SpartanUI","TOPRIGHT",0,10);
	end
end

function module:BuffLoc(self, parent)
	BuffFrame:ClearAllPoints();
	BuffFrame:SetPoint("TOPRIGHT",-13,-13-(DB.BuffSettings.offset));
	-- ConsolidatedBuffs:ClearAllPoints();
	-- ConsolidatedBuffs:SetPoint("TOPRIGHT",-13,-13-(DB.BuffSettings.offset));
	-- if (ConsolidatedBuffs:IsVisible()) then
		-- TemporaryEnchantFrame:SetPoint("TOPRIGHT","ConsolidatedBuffs","TOPLEFT",-5,0);
	-- else
		-- TemporaryEnchantFrame:SetPoint("TOPRIGHT","ConsolidatedBuffs","TOPLEFT",30,0);
	-- end
end

function module:SetupVehicleUI()
	if DBMod.Artwork.VehicleUI then
		RegisterStateDriver(Transparent_SpartanUI, "visibility", "[petbattle][overridebar][vehicleui] hide; show");
	end
end

function module:RemoveVehicleUI()
	if DBMod.Artwork.VehicleUI then
		UnRegisterStateDriver(Transparent_SpartanUI, "visibility");
	end
end

function module:EnableFramework()
	for i = 1,5 do
		_G["Transparent_SpartanUI_Base" ..i]:SetVertexColor(0,.8,.9,.7)
	end
	--Transparent_Popup1Mask:SetVertexColor(0,.8,.9,.7)
	--Transparent_Popup2Mask:SetVertexColor(0,.8,.9,.7)
	
	anchor:SetFrameStrata("BACKGROUND"); anchor:SetFrameLevel(1);
	frame:SetFrameStrata("BACKGROUND"); frame:SetFrameLevel(1);
	
	-- hooksecurefunc("AchievementAlertFrame_ShowAlert",function() -- achivement alerts
		-- if (AchievementAlertFrame1) then AchievementAlertFrame1:SetPoint("BOTTOM",Transparent_SpartanUI,"TOP",0,100); end
	-- end);
	hooksecurefunc("UIParent_ManageFramePositions",function()
		TutorialFrameAlertButton:SetParent(Minimap);
		TutorialFrameAlertButton:ClearAllPoints();
		TutorialFrameAlertButton:SetPoint("CENTER",Minimap,"TOP",-2,30);
		CastingBarFrame:ClearAllPoints();
		CastingBarFrame:SetPoint("BOTTOM",frame,"TOP",0,90);
	end);
	
	module:SetupVehicleUI();

	module:updateScale();
	module:updateOffset();
	module:updateXOffset();
	module:updateViewport();
	module:updateAlpha();
	
	-- Limit updates via interval
	anchor.UpdateInterval = 5 --Seconds
	anchor.TimeSinceLastUpdate = 0
	anchor:SetScript("OnUpdate",function(self,...)
		local elapsed = select(1,...)
		self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed; 
		if (self.TimeSinceLastUpdate > self.UpdateInterval) then
			if (InCombatLockdown()) then return; end
			
			module:updateScale();
			module:updateOffset();
			module:updateXOffset();
			module:updateViewport();
			self.TimeSinceLastUpdate = 0
			
			if DB.OpenOptions then
				spartan:ChatCommand()
				DB.OpenOptions = false;
			end
		end
	end);
	
	do
		function My_VehicleSeatIndicatorButton_OnClick(self, button)
			local seatIndex = self.virtualID;
			local controlType, occupantName = UnitVehicleSeatInfo("player", seatIndex);
			if ( button == "RightButton" and ( CanEjectPassengerFromSeat(seatIndex) or (CanExitVehicle() and ( occupantName == UnitName("player") )))) then
				ToggleDropDownMenu(1, seatIndex, VehicleSeatIndicatorDropDown, self:GetName(), 0, -5);
				if ( CanEjectPassengerFromSeat(seatIndex) ) then
					UIDropDownMenu_DisableButton(1,2);
					UIDropDownMenu_EnableButton(1,1);
				else
					UIDropDownMenu_DisableButton(1,1);
					UIDropDownMenu_EnableButton(1,2);
				end
			else
				UnitSwitchToVehicleSeat("player", seatIndex);
			end
		end
		
		local old_VehicleSeatIndicatorButton_OnClick = VehicleSeatIndicatorButton_OnClick
		VehicleSeatIndicatorButton_OnClick = My_VehicleSeatIndicatorButton_OnClick
		
		function My_VehicleSeatIndicatorDropDown_Initialize()
			local info = UIDropDownMenu_CreateInfo();
			info.text = EJECT_PASSENGER;
			info.disabled = nil;
			info.func = VehicleSeatIndicatorDropDown_OnClick;
			UIDropDownMenu_AddButton(info);
			info.text = VEHICLE_LEAVE;
			info.disabled = nil;
			info.func = VehicleSeatLeaveVehicleDropDown_OnClick;
			UIDropDownMenu_AddButton(info);
		end
		
		function VehicleSeatLeaveVehicleDropDown_OnClick()
			VehicleExit();
			PlaySound("UChatScrollButton");
		end
		
		local old_VehicleSeatIndicatorDropDown_Initialize = VehicleSeatIndicatorDropDown_Initialize()
		VehicleSeatIndicatorDropDown_Initialize = My_VehicleSeatIndicatorDropDown_Initialize
		
		UIDropDownMenu_Initialize( VehicleSeatIndicatorDropDown, VehicleSeatIndicatorDropDown_Initialize, "MENU");
	end
end
