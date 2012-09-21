local spartan = LibStub("AceAddon-3.0"):GetAddon("SpartanUI");
local addon = spartan:GetModule("RaidFrames");
----------------------------------------------------------------------------------------------------
oUF:SetActiveStyle("Spartan_RaidFrames");

if DBMod.RaidFrames.mode == "name" then
	raid = oUF:SpawnHeader("SUI_RaidFrameHeader", nil, 'raid',
		'showPlayer', true,
		'showRaid', true,
		'showParty', false,
		'showSolo', false,
		'xoffset', 3,
		'yOffset', -5,
		'point', 'TOP',
		'groupFilter', '1,2,3,4,5,6,7,8',
		'groupBy', 'ROLE',
		'groupingOrder', '1,2,3,4,5,6,7,8',
		'sortMethod', 'name',
		'maxColumns', 8,
		'unitsPerColumn', 5,
		'columnSpacing', 5,
		'columnAnchorPoint', 'LEFT'
	)
else
	raid = oUF:SpawnHeader("SUI_RaidFrameHeader", nil, 'raid',
		'showPlayer', true,
		'showRaid', true,
		'showParty', false,
		'showSolo', false,
		'xoffset', 3,
		'yOffset', 0,
		'point', 'LEFT',
		'groupFilter', '1,2,3,4,5,6,7,8',
		'groupBy', 'ROLE',
		'groupingOrder', '1,2,3,4,5,6,7,8',
		'sortMethod', 'name',
		'maxColumns', 8,
		'unitsPerColumn', 5,
		'columnSpacing', 5,
		'columnAnchorPoint', 'TOP'
	)
end
raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -40)
	
do -- raid header configuration
--	raid:SetPoint("TOPLEFT", 0, -26)
	raid:SetParent("SpartanUI");
	raid:SetClampedToScreen(false);
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()
	CompactRaidFrameContainer:UnregisterAllEvents()
	CompactRaidFrameContainer:Hide()
end

do -- scripts to make it movable
	raid.mover = CreateFrame("Frame");
	if DBMod.RaidFrames.FrameStyle == "large" then
		--self:SetSize(140, 50);
		raid.mover:SetSize(205, 332);
	elseif DBMod.RaidFrames.FrameStyle == "medium" then
		--self:SetSize(140, 35);
		raid.mover:SetSize(205, 332);
	elseif DBMod.RaidFrames.FrameStyle == "small" then
		--self:SetSize(90, 30);
		raid.mover:SetSize(205, 332);
	end
	raid.mover:SetPoint("TOPLEFT",raid,"TOPLEFT");
	raid.mover:EnableMouse(true);
	
	raid.bg = raid.mover:CreateTexture(nil,"BACKGROUND");
	raid.bg:SetAllPoints(raid.mover);
	raid.bg:SetTexture(1,1,1,0.5);
	
	raid.mover:SetScript("OnEvent",function()
		addon.locked = 1;
		raid.mover:Hide();
	end);
	raid.mover:RegisterEvent("VARIABLES_LOADED");
	raid.mover:RegisterEvent("PLAYER_REGEN_DISABLED");
	
	function addon:UpdateRaidPosition()
		addon.offset = DB.yoffset
		if DBMod.RaidFrames.moved then
			raid:SetMovable(true);
			raid:SetUserPlaced(false);
		else
			raid:SetMovable(false);
		end
		if not DBMod.RaidFrames.moved then
			raid:ClearAllPoints();
			if spartan:GetModule("PartyFrames",true) then
				raid:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-140-(addon.offset));
			else
				raid:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-20-(addon.offset));
			end
		else
			local Anchors = {}
			for k,v in pairs(DBMod.RaidFrames.Anchors) do
				Anchors[k] = v;
			end
			raid:ClearAllPoints();
			raid:SetPoint(Anchors.point, nil, Anchors.relativePoint, Anchors.xOfs, Anchors.yOfs);
		end
	end
end

do	-- Hide Frame
	function addon:UpdateRaid(event,...)
		raid:SetAttribute('showRaid',DBMod.RaidFrames.showRaid);
		if DBMod.RaidFrames.showRaid and IsInRaid() then
			raid:Show();
		else
			raid:Hide();
		end
		addon:UpdateRaidPosition()
		raid:SetScale(DBMod.RaidFrames.scale);
	end
	
	local raidWatch = CreateFrame("Frame");
	raidWatch:RegisterEvent('PLAYER_LOGIN');
	raidWatch:RegisterEvent('PLAYER_ENTERING_WORLD');
	raidWatch:RegisterEvent('RAID_ROSTER_UPDATE');
	raidWatch:RegisterEvent('PARTY_LEADER_CHANGED');
	raidWatch:RegisterEvent('PARTY_MEMBERS_CHANGED');
	raidWatch:RegisterEvent('PARTY_CONVERTED_TO_RAID');
	raidWatch:RegisterEvent('CVAR_UPDATE');
	raidWatch:RegisterEvent('FORCE_UPDATE');

	raidWatch:SetScript('OnEvent',function(self,event,...)
		if InCombatLockdown() then
			self:RegisterEvent('PLAYER_REGEN_ENABLED')
			return;
		end
		if (event == 'PLAYER_REGEN_ENABLED') then
			-- we aren't in combat
			self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end
		addon:UpdateRaid(event)
	end);
end