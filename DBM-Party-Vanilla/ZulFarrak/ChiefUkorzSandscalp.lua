local mod	= DBM:NewMod(489, "DBM-Party-Vanilla", 20, 241)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(7267)--7797/ruuzlu
mod:SetEncounterID(600)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 8269"
)

--TODO, Add cleave timer?
local warningEnrage			= mod:NewTargetNoFilterAnnounce(8269, 2)

do
	local Enrage = DBM:GetSpellInfo(8269)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 8269 then
		if args.spellName == Enrage and args:IsDestTypePlayer() then
			warningEnrage:Show(args.destName)
		end
	end
end
