local mod	= DBM:NewMod("Geddon", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(12056)
mod:SetEncounterID(668)
mod:SetModelID(12129)
mod:SetUsedIcons(1, 2, 3)
mod:SetHotfixNoticeRev(20220122000000)
mod:SetMinSyncRevision(20220122000000)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 20475 19659",
	"SPELL_AURA_REMOVED 20475",
	"SPELL_CAST_SUCCESS 19695 19659 20478 20475"
)

--[[
(ability.id = 19695 or ability.id = 19659 or ability.id = 20478 or ability.id = 20475) and type = "cast"
--]]
local warnInferno		= mod:NewSpellAnnounce(19695, 3)
local warnBomb			= mod:NewTargetNoFilterAnnounce(20475, 4)
local warnArmageddon	= mod:NewSpellAnnounce(20478, 3)

local specWarnBomb		= mod:NewSpecialWarningYou(20475, nil, nil, nil, 3, 2)
local yellBomb			= mod:NewYell(20475)
local yellBombFades		= mod:NewShortFadesYell(20475)
local specWarnInferno	= mod:NewSpecialWarningRun(19695, "Melee", nil, nil, 4, 2)
local specWarnIgnite	= mod:NewSpecialWarningDispel(19659, "RemoveMagic", nil, nil, 1, 2)

local timerInfernoCD	= mod:NewCDTimer(21, 19695, nil, nil, nil, 2)--21-27.9
local timerInferno		= mod:NewBuffActiveTimer(8, 19695, nil, nil, nil, 2)
local timerIgniteManaCD	= mod:NewCDTimer(27, 19659, nil, nil, nil, 2)--27-33
local timerBombCD		= mod:NewCDTimer(13.3, 20475, nil, nil, nil, 3)--13.3-18.3
local timerBomb			= mod:NewTargetTimer(8, 20475, nil, nil, nil, 3)
local timerArmageddon	= mod:NewCastTimer(8, 20478, nil, nil, nil, 2)

mod:AddSetIconOption("SetIconOnBombTarget", 20475, true, false, {1, 2, 3})

mod.vb.bombIcon = 1

function mod:OnCombatStart(delay)
	self.vb.bombIcon = 1
	--timerIgniteManaCD:Start(7-delay)--7-19, too much variation for first
	timerBombCD:Start(11-delay)
end

do
	local Inferno, Ignite, Armageddon, LivingBomb = DBM:GetSpellInfo(19695), DBM:GetSpellInfo(19659), DBM:GetSpellInfo(20478), DBM:GetSpellInfo(20475)
	function mod:SPELL_AURA_APPLIED(args)
		local spellName = args.spellName
		--if args.spellId == 20475 then
		if spellName == LivingBomb then
			timerBomb:Start(args.destName)
			if self.Options.SetIconOnBombTarget then
				self:SetIcon(args.destName, self.vb.bombIcon)
			end
			self.vb.bombIcon = self.vb.bombIcon + 1
			if args:IsPlayer() then
				specWarnBomb:Show()
				specWarnBomb:Play("runout")
				if self:IsDifficulty("event40") or not self:IsTrivial(75) then
					yellBomb:Yell()
					yellBombFades:Countdown(20475)
				end
			elseif not self:IsSeasonal() then--Only one bomb
				warnBomb:Show(args.destName)
			end
			if self:IsSeasonal() then--3 bombs, aggregate
				warnBomb:CombinedShow(0.5, args.destName)
			end
		elseif spellName == Ignite and self:CheckDispelFilter("magic") then
			specWarnIgnite:CombinedShow(0.3, args.destName)
			specWarnIgnite:ScheduleVoice(0.3, "helpdispel")
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args.spellId == 20475 then
		if args.spellName == LivingBomb then
			timerBomb:Stop(args.destName)
			if self.Options.SetIconOnBombTarget then
				self:SetIcon(args.destName, 0)
			end
			if args:IsPlayer() then
				yellBombFades:Cancel()
			end
		end
	end

	function mod:SPELL_CAST_SUCCESS(args)
		--local spellId = args.spellId
		local spellName = args.spellName
		--if spellId == 19695 then
		if spellName == Inferno then
			if self:IsDifficulty("event40") or not self:IsTrivial(75) then
				specWarnInferno:Show()
				specWarnInferno:Play("aesoon")
			else
				warnInferno:Show()
			end
			timerInferno:Start()
			timerInfernoCD:Start()
		--elseif spellId == 19659 then
		elseif spellName == Ignite and args:IsSrcTypeHostile() then
			--warnIgnite:Show()
			timerIgniteManaCD:Start()
		--elseif spellId == 20478 then
		elseif spellName == Armageddon then
			warnArmageddon:Show()
			timerArmageddon:Start()
		elseif spellName == LivingBomb then
			self.vb.bombIcon = 1
			timerBombCD:Start(self:IsSeasonal() and 11.3 or 13.3)
		end
	end
end
