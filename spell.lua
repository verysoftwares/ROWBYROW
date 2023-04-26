require('spell_data')

plrspells={
'SmolHeal','Meteor','Lightning',--'Flee','Reflect',--'Taunt',
--'Flee','Reflect','Leech','Mine','Buff','Taunt',
--'Mine','Buff','Taunt','Ice','Spore','Poison','AntiPsn','Leech','AntiSpore','SoulLeech','Flame',
--'AntiPsn',
}

--plr.atk_cooldown=2

function register_spell(sp)
    return {desc=spells[sp].desc,maxcool=spells[sp].maxcool,cooldown=0,mult=spells[sp].mult,minsq=spells[sp].minsq,maxsq=spells[sp].maxsq}
end

for i,sp in ipairs(plrspells) do 
    plrspells[sp]=register_spell(sp)
end

