function generic_ai()
    for i,s in ipairs(enemies[turni].spells) do
        if enemies[turni].spells[s].cooldown>0 then enemies[turni].spells[s].cooldown=enemies[turni].spells[s].cooldown-1; if enemies[turni].spells[s].cooldown==0 then enemies[turni].spells[s].justcooled=true end end
    end

    if enemies[turni].force then
    local allgone=true
    for i,s in ipairs(enemies[turni].spells) do
        if not find(enemies[turni].force,s) and enemies[turni].spells[s].cooldown<=0 and not enemies[turni].spells[s].justcooled then
        allgone=false; break
        end
    end
    if allgone then TIC=pass; shout(fmt('%s can\'t do anything this turn!',enemy_name(enemies[turni])))
    enemies[turni].force=nil
    return
    end
    end

    if enemies[turni].force then
        local allowed={}
        for i,s in ipairs(enemies[turni].spells) do
            if not find(enemies[turni].force,s) and enemies[turni].spells[s].cooldown<=0 and not enemies[turni].spells[s].justcooled then ins(allowed,s) end
        end
        local sp=allowed[math.random(#allowed)]
        shout(sp..'!')
        enemyatk=sp
        TIC=_G['enemy_anim_'..string.lower(sp)]
        sp=enemies[turni].spells[sp]
        sp.cooldown=sp.maxcool
        if enemies[turni].ice or enemies[turni].flame then sp.cooldown=sp.cooldown+enemies[turni].icestack-enemies[turni].flamestack end
        return
    end

end

function enemy_attack_calc()
    enemies[turni].sporestack=enemies[turni].sporestack or 0
    local minatk=enemies[turni].minatk-enemies[turni].sporestack
    local maxatk=enemies[turni].maxatk-enemies[turni].sporestack
    if enemies[turni].taunt and maxatk>2 then maxatk=2 end
    if enemies[turni].buff then minatk=minatk+2; if minatk>maxatk then minatk=maxatk end end
    if maxatk<minatk then maxatk=minatk end
    if minatk<0 then minatk=0 end
    if maxatk>=1 and minatk==0 then minatk=1 end
    if maxatk<0 then maxatk=0 end
    return minatk,maxatk
end

function enemy_attack()
    local minatk,maxatk=enemy_attack_calc()
    enemyatk='default'
    allydmg(math.random(minatk,maxatk),math.random(1,#allies))
end

function enemy_spell_range(sp)
    local minatk,maxatk=enemy_attack_calc()
    if maxatk>=spells[sp].minsq-enemies[turni].sporestack and minatk<=spells[sp].maxsq-enemies[turni].sporestack then
    if maxatk>spells[sp].maxsq-enemies[turni].sporestack then maxatk=spells[sp].maxsq-enemies[turni].sporestack end
    if minatk<spells[sp].minsq-enemies[turni].sporestack then minatk=spells[sp].minsq-enemies[turni].sporestack end
    if maxatk<minatk then maxatk=minatk end
    if minatk<0 then minatk=0 end
    if maxatk>=1 and minatk==0 then minatk=1 end
    if maxatk<0 then maxatk=0 end
    return math.random(minatk,maxatk) 
    end
    return 0
end

function generic_ai2()
    for i,s in ipairs(enemies[turni].spells) do enemies[turni].spells[s].justcooled=nil end
    enemies[turni].force=nil
end

function enemy_cast(sp)
    local minatk,maxatk=enemy_attack_calc()
    enemies[turni].sporestack=enemies[turni].sporestack or 0
    
    if enemies[turni].spells[sp].cooldown<=0 and not enemies[turni].spells[sp].justcooled and maxatk>=spells[sp].minsq-enemies[turni].sporestack and (minatk<=spells[sp].maxsq-enemies[turni].sporestack or spells[sp].maxsq-enemies[turni].sporestack<=0) then
        if sp=='Query' then 
           if enemies[turni].type=='MercRat' then
                if enemies[turni].phase==1 then
                    shout('Query: [you]')
                end
                if enemies[turni].phase==2 then
                    shout('Query: [Picross magic]')
                end
                if enemies[turni].phase==3 then
                    shout('Query: [quest]')
                end
            elseif enemies[turni].type=='Mimic' then
                shout('Query: [hidden path]')
            end
        else
        shout(sp..'!')
        end
        enemyatk=sp
        TIC=_G['enemy_anim_'..string.lower(sp)]
        enemies[turni].spells[sp].cooldown=enemies[turni].spells[sp].maxcool
        if enemies[turni].ice or enemies[turni].flame then enemies[turni].flamestack=enemies[turni].flamestack or 0; enemies[turni].icestack=enemies[turni].icestack or 0; enemies[turni].spells[sp].cooldown=enemies[turni].spells[sp].cooldown+enemies[turni].icestack-enemies[turni].flamestack end
        return true
    end
    return false
end
