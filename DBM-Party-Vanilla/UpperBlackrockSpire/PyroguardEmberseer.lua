local mod	= DBM:NewMod("PyroguardEmberseer", "DBM-Party-Vanilla", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(9816)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_EMOTE"
)

local timerCombatStart	= mod:NewCombatTimer(64)

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L.Pull or msg:find(L.Pull) then
		timerCombatStart:Start()
	end
end
