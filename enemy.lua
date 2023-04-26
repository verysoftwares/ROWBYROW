function enemyturn()
    for i,q in ipairs(prequeue) do
        queue[i]=q
    end
    prequeue={}
    --local old_queue=#queue
    while #queue>0 do
        local q=queue[#queue]
        --local inc=false
        q()
        --if #queue~=old_queue then
        --    old_queue=#queue
        --    inc=true
        --end
        rem(queue,#queue)
        --if inc then
        --    old_queue=old_queue-1
        --    i=i+1
        --end
    end
    if #reflectshout>0 and #prequeue==0 then for i=#reflectshout,1,-1 do if not reflectshout[i].orig.reflect then shout(reflectshout[i][1]); rem(reflectshout,#reflectshout) end end reflectshout={} end
    
    -- these are here (rather than in resolve_turn) just to not mess up shout order
    if turni==1 and t-sc_t==0 then
    if plr.buff and not plr.done2 then plr.buff=plr.buff-1; if plr.buff==0 then plr.buff=nil; shout('Your Buff wears out!') end end
    if plr.taunt and not plr.done3 then plr.taunt=plr.taunt-1; if plr.taunt==0 then plr.taunt=nil; shout('Your Taunt wears out!') end end
    if plr.ice and not plr.done4 then plr.ice=plr.ice-1; if plr.ice==0 then plr.ice=nil; plr.icestack=0; shout('Your Ice melts!') end end
    if plr.spore and not plr.done5 then plr.spore=plr.spore-1; if plr.spore==0 then plr.spore=nil; plr.sporestack=0; shout('Your Spore wears out!') end end
    if plr.poison and not plr.done6 then plr.poison=plr.poison-1; if plr.poison==0 then plr.poison=nil; plr.poisonstack=0; plr.poisonself=nil; shout('Your Poison wears out!') end end
    if plr.flame and not plr.done19 then plr.flame=plr.flame-1; if plr.flame==0 then plr.flame=nil; plr.flamestack=0; shout('Your Flame wears out!') end end
    end
    -- after spell
    if turni>1 and t-sc_t==0 then
    end
        --[[if ((plrspells[active] and active~='SmolHeal' and active~='Buff') or picross[active] or active=='Attack') and turni==1 and (enemyi or active=='Lightning') and t-sc_t==0 then
        if enemies[enemyi].type=='AcroBat' then pal(8,12); pal(9,12); pal(10,12) end    
        if enemies[enemyi].type=='MunSlime' then pal(1,12); pal(5,12); pal(6,12); pal(7,12) end   
        if enemies[enemyi].type=='Maneki' then pal(2,12); pal(4,12); pal(5,12); pal(13,12) end    
        if enemies[enemyi].type=='Rival' then pal(3,12); pal(4,12); end   
    end
    if turni==enemyi and t-sc_t==12 then
        pal()
    end]]--
    if t-sc_t==0 and cur_encounter==encounters['56:43'] then
    if turni==1 then
    TIC=turn_boss
    bossfade=0
    bmx=44; bmy=0
    bmw=7; bmh=7; bgrid=8
    bcx=80; bcy=80
    sb_cam.oldy=sb_cam.y
    sb_cam.y=0
    TIC()
    return
    end
    if turni==2 then
        turni=1
        buffshout=nil; tauntshout=nil; iceshout=nil; sporeshout=nil; poisonshout=nil; flameshout=nil
        if enemies[turni].buff and not enemies[turni].done2 then enemies[turni].buff=enemies[turni].buff-1; if enemies[turni].buff==0 then buffshout=true end end
    if enemies[turni].taunt and not enemies[turni].done3 then enemies[turni].taunt=enemies[turni].taunt-1; if enemies[turni].taunt==0 then tauntshout=true end end
    if enemies[turni].ice and not enemies[turni].done4 then enemies[turni].ice=enemies[turni].ice-1; if enemies[turni].ice==0 then enemies[turni].icestack=0; iceshout=true end end
        if enemies[turni].spore and not enemies[turni].done5 then enemies[turni].spore=enemies[turni].spore-1; if enemies[turni].spore==0 then enemies[turni].sporestack=0; sporeshout=true end end
        if enemies[turni].poison and not enemies[turni].done6 then enemies[turni].poison=enemies[turni].poison-1; if enemies[turni].poison==0 then enemies[turni].poisonstack=0; poisonshout=true end end
    if enemies[turni].flame and not enemies[turni].done19 then enemies[turni].flame=enemies[turni].flame-1; if enemies[turni].flame==0 then enemies[turni].flamestack=0; flameshout=true end end
        if buffshout and enemies[turni].buff==0 then enemies[turni].buff=nil; shout(fmt('%s\'s Buff wears out!',enemy_name(enemies[turni]))) end
        if tauntshout and enemies[turni].taunt==0 then enemies[turni].taunt=nil; shout(fmt('%s\'s Taunt wears out!',enemy_name(enemies[turni]))) end
        if iceshout and enemies[turni].ice==0 then enemies[turni].ice=nil; shout(fmt('%s\'s Ice melts!',enemy_name(enemies[turni]))) end
        if sporeshout and enemies[turni].spore==0 then enemies[turni].spore=nil; shout(fmt('%s\'s Spore wears out!',enemy_name(enemies[turni]))) end
        if poisonshout and enemies[turni].poison==0 then enemies[turni].poison=nil; shout(fmt('%s\'s Poison wears out!',enemy_name(enemies[turni]))) end
        if flameshout and enemies[turni].flame==0 then enemies[turni].flame=nil; shout(fmt('%s\'s Flame wears out!',enemy_name(enemies[turni]))) end
        buffshout=nil; tauntshout=nil; iceshout=nil; sporeshout=nil; poisonshout=nil; flameshout=nil
        turni=2
    end
    end
    
    if t-sc_t==90 then 
      labels={} 
    end 
    if t-sc_t>=90 and header.t==0 and #prequeue==0 then
        sc_t=t+1

        ::retry::
        if turni<=#enemies then
        if enemies[turni].hp>0 then 
                buffshout=nil; tauntshout=nil; iceshout=nil; sporeshout=nil; poisonshout=nil; flameshout=nil
                if enemies[turni].buff and not enemies[turni].done2 then enemies[turni].buff=enemies[turni].buff-1; if enemies[turni].buff==0 then buffshout=true end end
            if enemies[turni].taunt and not enemies[turni].done3 then enemies[turni].taunt=enemies[turni].taunt-1; if enemies[turni].taunt==0 then tauntshout=true end end
            if enemies[turni].ice and not enemies[turni].done4 then enemies[turni].ice=enemies[turni].ice-1; if enemies[turni].ice==0 then enemies[turni].icestack=0; iceshout=true end end
                if enemies[turni].spore and not enemies[turni].done5 then enemies[turni].spore=enemies[turni].spore-1; if enemies[turni].spore==0 then enemies[turni].sporestack=0; sporeshout=true end end
                if enemies[turni].poison and not enemies[turni].done6 then enemies[turni].poison=enemies[turni].poison-1; if enemies[turni].poison==0 then enemies[turni].poisonstack=0; poisonshout=true end end
            if enemies[turni].flame and not enemies[turni].done19 then enemies[turni].flame=enemies[turni].flame-1; if enemies[turni].flame==0 then enemies[turni].flamestack=0; flameshout=true end end

                if enemies[turni].ai then 
                generic_ai()
                if TIC==enemyturn then
                enemies[turni].ai()
                end
                generic_ai2()
                else enemyatk='default'; local max=enemies[turni].maxatk; if enemies[turni].taunt then max=max-2 end plrdmg(math.random(enemies[turni].minatk,max)) end
            if TIC~=pass then enemies[turni].nudge=60 end
        
            elseif enemies[turni].hp==0 then turni=turni+1; goto retry end
            
            if buffshout and enemies[turni].buff==0 then enemies[turni].buff=nil; shout(fmt('%s\'s Buff wears out!',enemy_name(enemies[turni]))) end
            if tauntshout and enemies[turni].taunt==0 then enemies[turni].taunt=nil; shout(fmt('%s\'s Taunt wears out!',enemy_name(enemies[turni]))) end
            if iceshout and enemies[turni].ice==0 then enemies[turni].ice=nil; shout(fmt('%s\'s Ice melts!',enemy_name(enemies[turni]))) end
            if sporeshout and enemies[turni].spore==0 then enemies[turni].spore=nil; shout(fmt('%s\'s Spore wears out!',enemy_name(enemies[turni]))) end
            if poisonshout and enemies[turni].poison==0 then enemies[turni].poison=nil; shout(fmt('%s\'s Poison wears out!',enemy_name(enemies[turni]))) end
            if flameshout and enemies[turni].flame==0 then enemies[turni].flame=nil; shout(fmt('%s\'s Flame wears out!',enemy_name(enemies[turni]))) end
            buffshout=nil; tauntshout=nil; iceshout=nil; sporeshout=nil; poisonshout=nil; flameshout=nil

            -- ai might have changed TIC
        -- it takes care of turni
        if TIC==enemyturn or TIC==pass then TIC=enemyturn; turni=turni+1 end
        --if turni>#enemies then TIC=turn end
        else
        if plr.hp==0 then
            TIC=gameover
        elseif enemyclear() then
            gain_exp()
            TIC=victory
        else

        TIC=turn

        local nmypsn=0
        for i,e in ipairs(enemies) do
            if not plr.poison and e.poison then
                nmypsn=nmypsn+1
            end 
        end
        if nmypsn>0 then --[[if nmypsn>1 then shout('Enemies take poison damage!') else shout('Enemy takes poison damage!') end;]] TIC=poisondmg; turni=1 
        elseif plr.poison then if plr.poisonstack>=0 then sfx(8,12*6,6,3); shout('You take poison damage!') else shout('You are healed by the AntiPsn in your veins!') end; plr.poisonself=plr.poisonself or self; plrdmg(plr.poisonstack,plr.poisonself) TIC=poisondmg; turni=1 end

        -- these are important globals,
        -- so they're reset last.
        if enemyi and enemies[enemyi].hp==0 then enemyi=nil end
        if plr.force then
            if active=='Attack' or picross[active] then active=nil end
            if plrspells[active] and find(plr.force,active) then
            active=nil
            end
        end
        if plrspells[active] and plrspells[active].cooldown>0 then active=nil end
        if plr.atk_cooldown and plr.atk_cooldown>0 and active=='Attack' then active=nil end
        end
        end
    end
    
    cls(args.bg)
    draw_bg()
    draw_board(args)
    
    -- pretty sus code,
    -- but it works.
    if turni==1 or (turni-1>0 and ((not enemies[turni-1].nudge) or (enemies[turni-1].nudge and enemies[turni-1].nudge<30))) then
    if turni-1>0 and enemies[turni-1].nudge and enemies[turni-1].nudge==30-3 then 
    sfx(8,12*6,6,3) 
    end
    draw_labels()
    end
    
    draw_header()
    
    t=t+1
end

function any_enemy_done(n)
    for i,e in ipairs(enemies) do
    if e['done'..tostring(n)] then return true end
    end
    return false
end

function enemy_adapt(sp)
  for i,e in ipairs(enemies) do
      if e.adaptor and e.spells and not find(e.spells,sp) then
          shout(fmt('%s learned %s!',enemy_name(e),sp))
          ins(e.spells,sp)
         e.spells[sp]=register_spell(sp)
      end
  end
end

