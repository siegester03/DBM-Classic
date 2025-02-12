local mod	= DBM:NewMod("GeneralDrakkisath", "DBM-Party-Vanilla", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(10363)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 16805",
	"SPELL_AURA_REMOVED 16805"
)

local warnConflagration		= mod:NewTargetNoFilterAnnounce(16805, 2)

local timerConflagration	= mod:NewTargetTimer(10, 16805, nil, nil, nil, 3)

do
	local Conflagration = DBM:GetSpellInfo(16805)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 16805 then
		if args.spellName == Conflagration then
			warnConflagration:Show(args.destName)
			timerConflagration:Start(args.destName)
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args.spellId == 16805 then
		if args.spellName == Conflagration then
			timerConflagration:Stop(args.destName)
		end
	end
end
