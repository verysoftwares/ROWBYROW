function turn()
    if cur_encounter==encounters['56:43'] then
    clip(240-bossfade,0,bossfade,136)
    end

    cls(2)

    if peek(0x13FFC)~=5 and cur_encounter~=encounters['38:37'] and cur_encounter~=encounters['56:43'] then music(5) end
    --spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
    --print("HELLO WORLD!",84,84)

    clip()

    draw_bg() 

    if cur_encounter==encounters['56:43'] then
    clip(240-bossfade,0,bossfade,136)
    if bossfade<240 then bossfade=bossfade+3 end
    end

    leftheld=left
    rightheld=right
    mox,moy,left,_,right,_,mwv=mouse()
    args={ax=239-mw+1,ay=135-mh+1,
       bx=239-mw*2+1,by=135-mh+1,
              cx=239-mw+1,cy=135-mh*2+1,
              mx=mx,my=my,mw=mw,mh=mh,
              mox=mox,moy=moy,left=left,right=right,leftheld=leftheld,rightheld=rightheld,
              state=state,select=select,firsttile=firsttile,intent=intent,rintent=rintent,
              grid=grid,
              who=plr,
              bg=2
              }

    draw_board(args)

    click_board(args)
    state=args.state
    select=args.select
    firsttile=args.firsttile
    intent=args.intent
    rintent=args.rintent

    draw_sidebar()

    resolve_turn(args)

    --[[if key(63) and keyp(19) then
      savedata()
      shout('Game saved!')
    end
    ]]
    if key(63) and keyp(12) then
      loaddata()
      --shout('Game loaded!')
    end

    clip()

    draw_footer()

    draw_header()

    --debug_grid()

    t=t+1
end

function resolve_turn(args)
    -- turn end
    local alcnew,_=count_new(nil,args)
    if (enemyi~=nil or find(autotargeting(),active) or all_cool()) and (active~=nil or (all_cool() and alcnew==0)) and ((((state=='rowselect' or state=='firstclick') and not picross[active]) or (picross[active] and ((plr.sporestack<0 and alcnew==-plr.sporestack) or (plr.sporestack>=0 and alcnew==0)))) or (active=='Attack' and plr.minatk<=0) or (plrspells[active] and plrspells[active].minsq<=0) or all_cool()) then
        rect(120+13*2+6+6,68+13*4-3,24,16,13)
        print('Done',120+13*2+6+6+4,68+13*4-3+5,12,false,1,true)
        rectb(120+13*2+6+6,68+13*4-3,24,16,t*FLASH_SPD)
        -- press 'done' button
        if left and not leftheld then
            if AABB(mox,moy,1,1,120+13*2+6+6,68+13*4-3,24,16) then
                sfx(8,12*6,6,3)

                --[[if plr.spore then 
                    plr.minatk=plr.minatk-2
                    plr.maxatk=plr.maxatk-2
                    if plr.minatk<0 then plr.minatk=0 end
                    for i,s in ipairs(plrspells) do
                        plrspells[s].minsq=plrspells[s].minsq-2
                        plrspells[s].maxsq=plrspells[s].maxsq-2
                        if plrspells[s].minsq<0 then plrspells[s].minsq=0 end
                    end
                end]]

                cool=all_cool()
                if cool then cool=170; shout('The player does an idle dance!') end

                rowguess=true
                for sqx=0,mw-1 do
                for sqy=0,mh-1 do
                    -- check if row is correct (for new squares only)
                    if rowguess and mget(239-mw*2+1+sqx,135-mh+1+sqy)==0 and mget(239-mw+1+sqx,135-mh+1+sqy)==16 and mget(mx+sqx,my+sqy)==0 then
                        --trace('fail')
                        rowguess=false
                    end
                end
                end
                -- determine damage by amount of new squares
                new=count_new(nil,args)
  
                self=false
                enemyatk=nil
                nmy_backfire=nil
  
                -- reset cooldowns
                for i,v in ipairs(plrspells) do
                    if plrspells[v].cooldown>0 then plrspells[v].cooldown=plrspells[v].cooldown-1 end
                end
                if plr.atk_cooldown then plr.atk_cooldown=plr.atk_cooldown-1 if plr.atk_cooldown<=0 then plr.atk_cooldown=nil end end
  
                if not rowguess then
                local msg='spell'
                if active=='Attack' then msg='attack' end 
                if picross[active] then msg='Picross' end
                if active=='Upgrade' then msg='Upgrade' end
                if active=='Flee' then shout('Can\'t escape: Incorrect Picross!') 
                else 
                if active=='Upgrade' then
                shout(fmt('The %s fizzled: Incorrect Picross!',msg)) 
                elseif active=='Query' then
                shout('The Query fizzled: Incorrect Picross!')
                else
                shout(fmt('The %s backfired: Incorrect Picross!',msg)) end
                end
                end

                local minatk,maxatk=plr.minatk,plr.maxatk
                if minatk<0 then minatk=0 end; if maxatk<0 then maxatk=0 end
                if active=='Attack' and (new<minatk or new>maxatk) then
                    rowguess=false
                    local msg
                    if new<minatk then msg='Too few squares!' end
                    if new>maxatk then msg='Too many squares!' end
                    
                    if #header.msg>0 then rem(header.msg,#header.msg) end
                    shout(fmt('The attack backfired: %s',msg))
                end

                local minsq,maxsq=0,0
                if plrspells[active] then minsq,maxsq=plrspells[active].minsq,plrspells[active].maxsq
                if minsq<0 then minsq=0 end; if maxsq<0 then maxsq=0 end end
                if plrspells[active] and (new<minsq or new>maxsq) then
                    rowguess=false
                    local msg
                    if new<minsq then msg='Too few squares!' 
                    elseif new>maxsq then msg='Too many squares!' end
                    
                    if #header.msg>0 then rem(header.msg,#header.msg) end
                    if active=='Flee' then shout(fmt('Can\'t escape: %s!',msg))
                    elseif active=='Query' then shout(fmt('The Query fizzled: %s!',msg))
                    else shout(fmt('The spell backfired: %s',msg)) end
                end

                local extra=0
                if plr.spore then extra=-plr.sporestack end
                if extra<0 then extra=0 end
                if picross[active] and (new>extra or new<extra) then
                    rowguess=false
                    if #header.msg>0 then rem(header.msg,#header.msg) end
                    if new>extra then 
                        if active=='Upgrade' then
                        shout(fmt('The Upgrade fizzled: Too many squares!')) 
                        else
                        shout(fmt('The Picross backfired: Too many squares!')) end
                    elseif new<extra then 
                        if active=='Upgrade' then
                        shout(fmt('The Upgrade fizzled: Too few squares!')) 
                        else
                        shout(fmt('The Picross backfired: Too few squares!')) end
                    end
                end
                
                if rowguess then 
                    if active=='Attack' then enemydmg(new)
                    if plr.icesword then enemies[enemyi].icestack=enemies[enemyi].icestack or 0; enemies[enemyi].icestack=enemies[enemyi].icestack+1; enemies[enemyi].ice=3; shout(fmt('Your IceSword increased %s\'s cooldowns by 1!',enemy_name(enemies[enemyi]))) end
                    if plr.ice or plr.flame then plr.atk_cooldown=plr.icestack-plr.flamestack end
                    elseif plrspells[active] then
                        plrspells[active].cooldown=plrspells[active].maxcool
                        if plr.ice or plr.flame then plrspells[active].cooldown=plrspells[active].cooldown+plr.icestack-plr.flamestack end
                        if active=='SmolHeal' then
                            --plrdmg(new*plrspells[active].mult)
                        elseif active=='Buff' then
                          -- set later
                            shout('You are Buff\'d for 3 turns!')
                        elseif active=='Taunt' then
                          shout(fmt('%s has Taunt for 3 turns!',enemy_name(enemies[enemyi])))
                        elseif active=='Ice' then
                          shout(fmt('%s is frozen for 3 turns!',enemy_name(enemies[enemyi])))
                        elseif active=='Spore' then
                            shout(fmt('%s has Spore for 3 turns!',enemy_name(enemies[enemyi])))
                        elseif active=='Poison' then
                            if enemies[enemyi].poison then shout(fmt('%s\'s poison damage increased by %d!',enemy_name(enemies[enemyi]),new))
                            else shout(fmt('%s is poisoned by %d for 4 turns!',enemy_name(enemies[enemyi]),new)) end
                        elseif active=='AntiPsn' then
                            --shout(fmt('%s is poisoned for 4 turns!',enemy_name(enemies[enemyi])))
                              if not plr.poison then shout('The AntiPsn fizzled: player not poisoned!')
                              else
                              shout(fmt('Poison damage reduced by %d! (now %d)',new,plr.poisonstack-new))
                              end
                        elseif active=='Leech' then
                            shout(fmt('Leeched health from %s!',enemy_name(enemies[enemyi])))
                        elseif active=='Mine' then
                            shout('Forced the use of an unseen spell!')
                        elseif active=='SoulLeech' then
                          shout(fmt('Player\'s and %s\'s hit points were swapped!',enemy_name(enemies[enemyi])))
                        elseif active=='AntiSpore' then
                            shout(fmt('Fill-in ranges increased by 2 for 3 turns! (total %s)', tolabel(-(plr.sporestack-2))))
                        elseif active=='Flame' then
                          shout(fmt('Cooldowns reduced by 2 for 3 turns! (total %s)',tolabel(plr.icestack-(plr.flamestack+2))))
                        elseif active=='Flee' then
                            shout('Player left the encounter.')
                        elseif active=='Summon' then
                            if live_ally()>=3 then shout('The Summon fizzled: Maximum squad is 3!')
                            else shout('Summon!') end
                        elseif active=='Reflect' then
                            if not plr.reflect then
                            shout('Reflecting damage once!')
                            else
                            shout(fmt('Reflecting damage %d times!',plr.reflect+1))
                            end
                        elseif active=='Query' then
                            shout('Select a keyword for Query!')
                            TIC=turn_query
                            sb_cam.y=0
                        else
                            --if active=='Lightning' then
                            --for i,e in ipairs(enemies) do
                            --enemydmg(new*plrspells[active].mult,i)
                            --end
                            --else
                            --enemydmg(new*plrspells[active].mult)
                            --end
                        end
                    elseif picross[active] then
                        if active=='Upgrade' then
                            clear_picross()
                            mw=mw+1; mh=mh+1;
                            if mw==6 then grid=10 
                            mx=20; my=0
                            end
                            shout(fmt('You now have a %dx%d board!',mw,mh))
                        else
                        enemydmg(picross[active].w*picross[active].h)
                        end
                    end
                else 
                -- reset new squares on failure
                    for sqxx=0,mw-1 do
                    for sqyy=0,mh-1 do
                        if mget(239-mw*2+1+sqxx,135-mh+1+sqyy)==0 and mget(239-mw+1+sqxx,135-mh+1+sqyy)==16 then
                            mset(239-mw+1+sqxx,135-mh+1+sqyy,0)
                        end
                    end
                    end
                if active=='Attack' then
                  plrdmg(new,true)
                    if plr.ice or plr.flame then plr.atk_cooldown=plr.icestack-plr.flamestack end
                elseif plrspells[active] then
                    plrspells[active].cooldown=plrspells[active].maxcool
                    if plr.ice or plr.flame then plrspells[active].cooldown=plrspells[active].cooldown+plr.icestack-plr.flamestack end

                    if active~='Flee' and active~='Query' then

                    self=true
                    TIC=_G['enemy_anim_'..string.lower(active)]
                    enemyatk=active
                    turni=enemyi
                    -- no target: pick random alive
                    while not turni or enemies[turni].hp==0 do
                    turni=math.random(#enemies)
                    end
                    
                    end
                        --enemydmg(new*plrspells[active].mult,turni)
                elseif picross[active] then
                    if active=='Upgrade' then
                    else
                    plrdmg(picross[active].w*picross[active].h,true)
                    end
                end 
                end
                for sqx=0,mw-1 do
                for sqy=0,mh-1 do
                    -- set old pic state
                    mset(239-mw*2+1+sqx,135-mh+1+sqy,mget(239-mw+1+sqx,135-mh+1+sqy))
                end
                end
                if TIC==turn then TIC=enemyturn; turni=1 end
                
                if (rowguess and active=='Attack') or (rowguess and picross[active]) then plr.cast=45 end
                if rowguess and plrspells[active] and active~='Query' then

                TIC=_G['attack_anim_'..string.lower(active)]
                plr.cast=cast[active]-10

                end
                
                for i=2,26 do plr['done'..tostring(i)]=nil end
                for i,e in ipairs(enemies) do for j=2,23 do e['done'..tostring(j)]=nil end end
                if plr.force then 
                --if plrspells[active] then 
                --ins(plr.force,active); shout(fmt('Enemy learned %s!',active)) 
                --plr.force[active]={maxcool=plrspells[active].maxcool,cooldown=0}
                --end
                plr.force=nil 
                end
                
                if picross[active] and not (active=='Upgrade' and not rowguess) then
                    rem(plrpicross,picrossactive_i)
                    sb_cam.y=sb_cam.y+7; if #plrpicross==0 then sb_cam.y=sb_cam.y+7 end; if sb_cam.y>0 then sb_cam.y=0 end
                    if picrossactive_i>#plrpicross then
                    picrossactive_i=#plrpicross
                    end
                    if picrossactive_i>0 then
                      active=plrpicross[picrossactive_i]
                    elseif picrossactive_i==0 then
                        active=nil
                        picrossactive_i=nil
                    end
                end               

                if solved() then
                    TIC=picross_unlock
                    plr.cast=45
                    tri_a=nil
                end
                state=nil
                sc_t=t+1
            end
        end
    end
    if plr.spore then 
        plr.minatk=plr.minatk+plr.sporestack
        plr.maxatk=plr.maxatk+plr.sporestack
        for i,s in ipairs(plrspells) do
            plrspells[s].minsq=plrspells[s].minsq+plr.sporestack
            plrspells[s].maxsq=plrspells[s].maxsq+plr.sporestack
        end
    end
    if TIC==enemyturn then
        allyi=2
        TIC=allyturn
    end
end

sb_cam={y=0}
function draw_sidebar()
    -- spells & attacks
    
    -- spore ranges are reset at the end of resolve_turn
    --if plr.spore then trace(fmt('spore %d',plr.spore)) end
    --trace(fmt('stack %d',plr.sporestack))
    if plr.spore then 
        plr.minatk=plr.minatk-plr.sporestack
        plr.maxatk=plr.maxatk-plr.sporestack
        for i,s in ipairs(plrspells) do
            plrspells[s].minsq=plrspells[s].minsq-plr.sporestack
            plrspells[s].maxsq=plrspells[s].maxsq-plr.sporestack
        end
    end

    if sb_cam.y<0 then 
    rect(6,6*8+4,56-4,7,12) 
    tri(6+(56-4)/2,6*8+4,6+(56-4)/2+4,6*8+4+7,6+(56-4)/2-4,6*8+4+7,13)
    end
    if (sb_cam.y<0 and left and not leftheld and AABB(mox,moy,1,1,6,6*8+4,56-4,7)) or (sb_cam.y<0 and mwv>0 and AABB(mox,moy,1,1,4,6*8+4,56,64+8+8)) then
        sb_cam.y=sb_cam.y+7
        if sb_cam.y==-1 then sb_cam.y=sb_cam.y+1 end
        if sb_cam.y>0 then sb_cam.y=0 end
        leftheld=true
    end
    local sh=0
    sh=sh+(1+1)*7
    sh=sh+(#plrspells+1)*7
    if #plrpicross>0 then
    sh=sh+(#plrpicross+1)*7
    end
    --trace(-sb_cam.y)
    --trace(sh)
    if sh>64+8+8 and -sb_cam.y+6*8+4+24+7-7<sh then
    rect(6,6*8+4+64+8+8-7,56-4,7,12)
    tri(6+(56-4)/2,6*8+4+64+8+8-7+7-1,6+(56-4)/2+4,6*8+4+64+8+8-7-1,6+(56-4)/2-4,6*8+4+64+8+8-7-1,13)
    if (left and not leftheld and AABB(mox,moy,1,1,6,6*8+4+64+8+8-7,56-4,7)) or (mwv<0 and AABB(mox,moy,1,1,4,6*8+4,56,64+8+8)) then
        if sb_cam.y==0 then sb_cam.y=sb_cam.y-8
        else sb_cam.y=sb_cam.y-7 end
        leftheld=true
    end
    end
    
    rectb(4,6*8+4,56,64+8+8,13)
    
    if sb_cam.y+6*8+4+2>6*8+4+1 then
    rect(6,sb_cam.y+6*8+4+2,56-4,6+1,1)
    print('Attack',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
    end
    if sb_cam.y+6*8+7+4+2>6*8+4+2 then
    if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7+4+2,56-4,7) then
      local msg='Attack with a wooden sword.'
      if (plr.ice or plr.flame) and plr.icestack-plr.flamestack>0 then local sc=plr.icestack-plr.flamestack; if sc<0 then sc=0 end
      msg=msg..fmt(' Cooldown: %d turn(s)',sc) end
      describe(msg)
      if left and not leftheld and not plr.atk_cooldown and not plr.force then
          active='Attack'
          sfx(8,12*6,6,3)
      end
      rect(6,sb_cam.y+6*8+7+4+2,56-4,7,4)
    end
    if active=='Attack' then
      rect(6,sb_cam.y+6*8+7+4+2,56-4,7,5)
    end
    if plr.atk_cooldown or plr.force then
      rect(6,sb_cam.y+6*8+7+4+2,56-4,7,13)
    end
    local minatk=plr.minatk
    local maxatk=plr.maxatk
    if minatk<0 then minatk=0 end
    if maxatk<0 then maxatk=0 end
    if minatk==0 and maxatk==0 then
    print(fmt('Attack (%d)',minatk),6+1,sb_cam.y+6*8+7+4+2+1,12,false,1,true)
    else
    print(fmt('Attack (%d-%d)',minatk,maxatk),6+1,sb_cam.y+6*8+7+4+2+1,12,false,1,true)
    end
    end
    
    if sb_cam.y+6*8+7*2+4+2>6*8+4+2 then
    rect(6,sb_cam.y+6*8+7*2+4+2,56-4,6+1,1)
    print('Spell',6+1,sb_cam.y+6*8+7*2+4+2+1,13,false,1,true)
    end
    local ty

    forced={}
    if plr.force then
    for i,sp in ipairs(plrspells) do
        if not find(plr.force,sp) then ins(forced,sp) end
    end
    end

    for i,v in ipairs(plrspells) do
        --trace(ty)
        --if 6*8+7*3+7*(i-1)+7>=6*8+4+64+8+8-7 then return end
        if sb_cam.y+6*8+7*3+7*(i-1)+6>6*8+4+2 and (sb_cam.y+6*8+7*3+7*(i-1)+6<6*8+4+64+8+8-7-1-1 or -sb_cam.y+6*8+4+24+7-7+1>=sh) then
        if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7) then
          rect(6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7,4)
          if (left and not leftheld and plrspells[v].cooldown<=0) and (not plr.force or (plr.force and find(forced,v))) then
              active=v
              sfx(8,12*6,6,3)
          end
          local maxcool=plrspells[v].maxcool
          if plr.ice or plr.flame then maxcool=maxcool+plr.icestack-plr.flamestack end
          if maxcool<0 then maxcool=0 end
          if find({'Buff','Taunt','Poison'},v) then 
          local msg=plrspells[v].desc
          if t%240<120 then msg=fmt('Cooldown: %d turn(s)',maxcool) end
          describe(msg)
          elseif find({'Ice','Spore','AntiPsn','Mine','AntiSpore','SoulLeech','Flame','Flee','Reflect','Query'},v) then describe(fmt('%s Cooldown: %d turns',plrspells[v].desc,maxcool))
          else describe(fmt('%sCooldown: %d turn(s), multiplier %.1fx',plrspells[v].desc,maxcool,plrspells[v].mult)) end
        end
        if active==v then 
        rect(6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7,5)
        end
    
        if plrspells[v].cooldown>0 or (plr.force and not find(forced,v)) then
       rect(6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7,13)
        end
  
        local minsq=plrspells[v].minsq
        if minsq<0 then minsq=0 end
        local maxsq=plrspells[v].maxsq
        if maxsq<0 then maxsq=0 end
        local msg=fmt('%s (%d-%d)',v,minsq,maxsq)
        if minsq==maxsq then
        msg=fmt('%s (%d)',v,minsq)
        end
        print(msg,6+1,sb_cam.y+6*8+7*3+7*(i-1)+7,12,false,1,true)
        end
        ty=6*8+7*3+7*(i-1)+7
    end
    
    if #plrpicross>0 then
    ty=ty+7
    if sb_cam.y+ty-1>6*8+4+2 and sb_cam.y+ty-1<6*8+4+64+8+8-7-1-1 then
    rect(6,sb_cam.y+ty-1,56-4,6+1,1)
    print('Picross',6+1,sb_cam.y+ty+1-1,13,false,1,true)
    end
    ty=ty+6
    for i,p in ipairs(plrpicross) do
        if sb_cam.y+ty>6*8+4+2 and (sb_cam.y+ty<6*8+4+64+8+8-7-1-1 or -sb_cam.y+6*8+4+24+7-7+1+1>=sh) then
        if AABB(mox,moy,1,1,6,sb_cam.y+ty,56-4,7) then
          rect(6,sb_cam.y+ty,56-4,7,4)
          if left and not leftheld and not plr.force then
              active=p
              picrossactive_i=i
              sfx(8,12*6,6,3)
          end
          if p=='Upgrade' then
          describe(fmt('Clears board and upgrades to %dx%d.',mw+1,mh+1))
          else
          describe(fmt('Deals %dx%d damage.',picross[p].w,picross[p].h))
          end
        end
  
        if picrossactive_i==i and picross[active] then 
        rect(6,sb_cam.y+ty,56-4,7,5)
        end
        if plr.force then
        rect(6,sb_cam.y+ty,56-4,7,13)
        end
        
        local extra=0
        if plr.spore then extra=-plr.sporestack end
        if extra<0 then extra=0 end
        local msg=fmt('%s (%d)',p,extra)
        print(msg,6+1,sb_cam.y+ty+1,12,false,1,true)
        
        end
        ty=ty+7
    end
    end

    --[[if plr.spore then 
        plr.minatk=plr.minatk+2
        plr.maxatk=plr.maxatk+2
        --if plr.minatk<0 then plr.minatk=0 end
        for i,s in ipairs(plrspells) do
            plrspells[s].minsq=plrspells[s].minsq+2
            plrspells[s].maxsq=plrspells[s].maxsq+2
            --if plrspells[s].minsq<0 then plrspells[s].minsq=0 end
        end
    end]]

    
    -- targets
    
    rectb(240-56-4,6*8+4,56,64-3,13)
    rect(240-56-4+2,6*8+4+2,56-4,6+1,1)
    print('Targets',240-56-4+2+1,6*8+4+2+1,13,false,1,true)
    for i,e in ipairs(enemies) do
        -- can click the enemy to target
        local nmytgt=AABB(mox,moy,1,1,160-30+(i-1)*40,6*8-24-6,24,24)
        if e.type=='Schwobly' then nmytgt=AABB(mox,moy,1,1,160-30-40+20,4,8*8,8*5) end
        if enemies[i].hp>0 and (nmytgt 
                            or AABB(mox,moy,1,1,240-56-4+2,6*8+4+2+i*7,56-4,7)) then
            if nmytgt then
            spr(255,mox-8+(t*0.18%3),moy-8+(t*0.18%3),0)
            spr(255,mox+4-(t*0.18%3),moy-8+(t*0.18%3),0,1,0,1)
            spr(255,mox-8+(t*0.18%3),moy+4-(t*0.18%3),0,1,0,3)
            spr(255,mox+4-(t*0.18%3),moy+4-(t*0.18%3),0,1,0,2)
            end

            if e.type=='AcroBat' then describe('A rowdy bat who likes to dance.') end
            if e.type=='MunSlime' then describe('Has a terrible odor, but can\'t shower.') end
            if e.type=='Maneki' then describe('The luckiest cat. Well, until it met you.') end
            if e.type=='Rival' then describe('Your rival. Talk about a love-hate relationship.') end
            if e.type=='Burr' then describe('Little panicky mole.') end
            rect(240-56-4+2,6*8+4+2+i*7,56-4,7,4)

            if left and not leftheld then 
            enemyi=i
            sfx(8,12*6,6,3)
            end
        end
        if enemyi==i or active=='Lightning' then
          rect(240-56-4+2,6*8+4+2+i*7,56-4,7,5)
        end
        if enemies[i].hp==0 then 
          rect(240-56-4+2,6*8+4+2+i*7,56-4,7,13)
        end
        
        if e.type=='Schwobly' then
        spr(161,240-56-4+2+1,6*8+4+2+1+i*7,0)
        print(enemy_name(e),240-56-4+2+1+6,6*8+4+2+1+i*7,12,false,1,true)
        else
        print(enemy_name(e),240-56-4+2+1,6*8+4+2+1+i*7,12,false,1,true)
        end
    end
end

function player_adapt(sp)
    if not find(plrspells,sp) then
    shout(fmt('Learned %s!',sp))
    ins(plrspells,sp)
    plrspells[sp]=register_spell(sp)
    end
end
