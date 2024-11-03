CreateFrame('FRAME', 'VPUD_Frm', UIParent)
VPUD_Frm:SetBackdrop({
	bgFile = 'Interface/DialogFrame/UI-DialogBox-Background', 
	edgeFile = 'Interface/Tooltips/UI-Tooltip-Border', 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
VPUD_Frm:SetPoint('CENTER', UIParent)
VPUD_Frm:SetWidth(216)
VPUD_Frm:SetHeight(240)
VPUD_Frm:SetMovable(true)
VPUD_Frm:EnableMouse(true)
VPUD_Frm:RegisterForDrag('LeftButton')
VPUD_Frm:SetScript('OnDragStart', function() this:StartMoving() end)
VPUD_Frm:SetScript('OnDragStop',  function() this:StopMovingOrSizing() end)

VPUD_Frm:CreateFontString('VPUD_FrmStr1', 'OVERLAY' , 'GameFontNormalSmall')
getglobal('VPUD_FrmStr1'):SetPoint('TOPLEFT', VPUD_Frm, 8, -8)

for i = 2, 16 do
    VPUD_Frm:CreateFontString('VPUD_FrmStr' .. i, 'OVERLAY' , 'GameFontNormalSmall')
    getglobal('VPUD_FrmStr' .. i):SetPoint('TOPLEFT', 'VPUD_FrmStr' .. (i - 1), 'BOTTOMLEFT', 0, -4)
end

VPUD_Frm:CreateFontString('VPUD_FrmStr17', 'OVERLAY' , 'GameFontNormalSmall')
getglobal('VPUD_FrmStr17'):SetPoint('TOPLEFT', VPUD_Frm, 108, -8)

for i = 18, 32 do
    VPUD_Frm:CreateFontString('VPUD_FrmStr' .. i, 'OVERLAY' , 'GameFontNormalSmall')
    getglobal('VPUD_FrmStr' .. i):SetPoint('TOPLEFT', 'VPUD_FrmStr' .. (i - 1), 'BOTTOMLEFT', 0, -4)
end

local queue = {}
local debuffs = {}

VPUD_Frm:RegisterEvent('PLAYER_TARGET_CHANGED')
VPUD_Frm:RegisterEvent('CHAT_MSG_SPELL_AURA_GONE_OTHER')
VPUD_Frm:RegisterEvent('CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE')
VPUD_Frm:SetScript('OnEvent', function() this[event]() end)

VPUD_Frm.PLAYER_TARGET_CHANGED = function()
	tinsert(queue, {0, 0})
end

VPUD_Frm.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = function()
	local r = {string.find(arg1, '^(.+) is afflicted by (.+)%.$')}
	if r[4] then
		tinsert(queue, {1, r[4]})
		SELECTED_CHAT_FRAME:AddMessage('begin ' .. r[4])
	end
end

VPUD_Frm.CHAT_MSG_SPELL_AURA_GONE_OTHER = function()
	local r = {string.find(arg1, '^(.+) fades from (.+)%.$')}
	if r[3] then
		tinsert(queue, {2, r[3]})
		SELECTED_CHAT_FRAME:AddMessage('end ' .. r[3])
	end
end

VPUD_Frm:SetScript('OnUpdate', function()
    if getn(queue) then
		for i = 1, getn(queue) do
			if queue[1][1] == 0 then
				debuffs = {}
				queue = {}
				break
			elseif queue[1][1] == 1 then
				tinsert(debuffs, queue[1][2])
				tremove(queue, 1)
			elseif queue[1][1] == 2 then
				for i = 1, getn(debuffs) do
					if debuffs[i] == queue[1][2] then
						tremove(debuffs, i)
						tremove(queue, 1)
						break
					end
				end
				tremove(queue, 1)
			end
		end

        for i = 1, 32 do
			getglobal('VPUD_FrmStr' .. i):SetText(i .. ' - ' .. (debuffs[i] or ''))
        end
    end
end)
