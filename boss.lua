require('boss_ai')

function turn_boss()
    clip(240-bossfade,0,bossfade,136)

    cls(6)

    clip()

    draw_bg()

    clip(240-bossfade,0,bossfade,136)
    if bossfade<240 then bossfade=bossfade+3 end

    args={ax=0,ay=135-bmh+1,
       bx=bmw,by=135-bmh+1,
              cx=0,cy=135-bmh*2+1,
              mx=bmx,my=bmy,mw=bmw,mh=bmh,
              mox=bcx,moy=bcy,left=bcl,right=bcr,leftheld=nil,rightheld=nil,
              state=bstate,select=bselect,firsttile=bfirsttile,intent=bintent,rintent=brintent,
              grid=bgrid,
              who=enemies[turni],
              bg=6
              }

    draw_board(args)

    click_board(args)
    bstate=args.state
    bselect=args.select
    bfirsttile=args.firsttile
    bintent=args.intent
    brintent=args.rintent

    draw_sidebar_boss()

    if bossfade==240 then
      boss1_ai()
    end

    resolve_turn_boss(args)

    pal(12,0)
    spr(144,bcx-1,bcy,1)
    spr(144,bcx+1,bcy,1)
    spr(144,bcx,bcy-1,1)
    spr(144,bcx,bcy+1,1)
    pal()
    spr(144,bcx,bcy,1)

    draw_labels()
    if t-sc_t==90 then labels={} end

    clip()

    draw_footer()

    draw_header()

    t=t+1
end

function draw_sidebar_boss()
    -- spells & attacks
    
    -- spore ranges are reset at the end of resolve_turn
    --if plr.spore then trace(fmt('spore %d',plr.spore)) end
    --trace(fmt('stack %d',plr.sporestack))
    --[[if plr.spore then 
        plr.minatk=plr.minatk-plr.sporestack
        plr.maxatk=plr.maxatk-plr.sporestack
        for i,s in ipairs(plrspells) do
            plrspells[s].minsq=plrspells[s].minsq-plr.sporestack
            plrspells[s].maxsq=plrspells[s].maxsq-plr.sporestack
        end
    end]]

    if enemies[turni].spore then 
        enemies[turni].minatk=enemies[turni].minatk-enemies[turni].sporestack
        enemies[turni].maxatk=enemies[turni].maxatk-enemies[turni].sporestack
        for i,s in ipairs(enemies[turni].spells) do
            enemies[turni].spells[s].minsq=enemies[turni].spells[s].minsq-enemies[turni].sporestack
            enemies[turni].spells[s].maxsq=enemies[turni].spells[s].maxsq-enemies[turni].sporestack
        end
    end

    mox,moy=bcx,bcy
    left=bcl

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
    sh=sh+(#enemies[turni].spells+1)*7
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
      --local msg='Attack with a wooden sword.'
      --describe(msg)
      if left and not leftheld and not plr.atk_cooldown and not plr.force then
          bactive='Attack'
          sfx(8,12*6,6,3)
      end
      rect(6,sb_cam.y+6*8+7+4+2,56-4,7,4)
    end
    if bactive=='Attack' then
      rect(6,sb_cam.y+6*8+7+4+2,56-4,7,5)
    end
    if enemies[turni].atk_cooldown or enemies[turni].force then
      rect(6,sb_cam.y+6*8+7+4+2,56-4,7,13)
    end
    local minatk=enemies[turni].minatk
    local maxatk=enemies[turni].maxatk
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

    for i,v in ipairs(enemies[turni].spells) do
        --trace(ty)
        --if 6*8+7*3+7*(i-1)+7>=6*8+4+64+8+8-7 then return end
        if sb_cam.y+6*8+7*3+7*(i-1)+6>6*8+4+2 and (sb_cam.y+6*8+7*3+7*(i-1)+6<6*8+4+64+8+8-7-1-1 or -sb_cam.y+6*8+4+24+7-7+1>=sh) then
        if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7) then
          rect(6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7,4)
          if (left and not leftheld and enemies[turni].spells[v].cooldown<=0) and (not plr.force or (plr.force and find(forced,v))) then
              bactive=v
              sfx(8,12*6,6,3)
          end
          local maxcool=enemies[turni].spells[v].maxcool
          if enemies[turni].ice or enemies[turni].flame then maxcool=maxcool+enemies[turni].icestack-enemies[turni].flamestack end
          if maxcool<0 then maxcool=0 end
          if find({'Buff','Taunt','Poison'},v) then 
          local msg=enemies[turni].spells[v].desc
          if t%240<120 then msg=fmt('Cooldown: %d turn(s)',maxcool) end
          describe(msg)
          elseif find({'Ice','Spore','AntiPsn','Mine','AntiSpore','SoulLeech','Flame','Flee','Reflect','Query','Summon'},v) then describe(fmt('%s Cooldown: %d turns',enemies[turni].spells[v].desc,maxcool))
          else describe(fmt('%sCooldown: %d turn(s), multiplier %.1fx',enemies[turni].spells[v].desc,maxcool,enemies[turni].spells[v].mult)) end
        end
        if bactive==v then 
        rect(6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7,5)
        end
    
        if enemies[turni].spells[v].cooldown>0 or (enemies[turni].force and find(enemies[turni].force,v)) then
       rect(6,sb_cam.y+6*8+7*3+7*(i-1)+6,56-4,7,13)
        end
  
        local minsq=enemies[turni].spells[v].minsq
        if minsq<0 then minsq=0 end
        local maxsq=enemies[turni].spells[v].maxsq
        if maxsq<0 then maxsq=0 end
        local msg=fmt('%s (%d-%d)',v,minsq,maxsq)
        if minsq==maxsq then
        msg=fmt('%s (%d)',v,minsq)
        end
        print(msg,6+1,sb_cam.y+6*8+7*3+7*(i-1)+7,12,false,1,true)
        end
        ty=6*8+7*3+7*(i-1)+7
    end
    
    if #bosspicross>0 then
    ty=ty+7
    if sb_cam.y+ty-1>6*8+4+2 and sb_cam.y+ty-1<6*8+4+64+8+8-7-1-1 then
    rect(6,sb_cam.y+ty-1,56-4,6+1,1)
    print('Picross',6+1,sb_cam.y+ty+1-1,13,false,1,true)
    end
    ty=ty+6
    for i,p in ipairs(bosspicross) do
        if sb_cam.y+ty>6*8+4+2 and (sb_cam.y+ty<6*8+4+64+8+8-7-1-1 or -sb_cam.y+6*8+4+24+7-7+1+1>=sh) then
        if AABB(mox,moy,1,1,6,sb_cam.y+ty,56-4,7) then
          rect(6,sb_cam.y+ty,56-4,7,4)
          if left and not leftheld and not plr.force then
              bactive=p
              bpicrossactive_i=i
              sfx(8,12*6,6,3)
          end
          if p=='Upgrade' then
          describe(fmt('Clears board and upgrades to %dx%d.',mw+1,mh+1))
          else
          describe(fmt('Deals %dx%d damage.',picross[p].w,picross[p].h))
          end
        end
  
        if bpicrossactive_i==i and picross[bactive] then 
        rect(6,sb_cam.y+ty,56-4,7,5)
        end
        if enemies[turni].force then
        rect(6,sb_cam.y+ty,56-4,7,13)
        end
        
        local extra=0
        if enemies[turni].spore then extra=-enemies[turni].sporestack end
        if extra<0 then extra=0 end
        local msg=fmt('%s (%d)',p,extra)
        print(msg,6+1,sb_cam.y+ty+1,12,false,1,true)
        
        end
        ty=ty+7
    end
    end
    
    -- targets
    
    rectb(240-56-4,6*8+4,56,64-3,13)
    rect(240-56-4+2,6*8+4+2,56-4,6+1,1)
    print('Targets',240-56-4+2+1,6*8+4+2+1,13,false,1,true)
    for i,e in ipairs(allies) do
        -- can click the enemy to target
        local plrtgt=AABB(mox,moy,1,1,56+5-(i-1)*30,6*8-24-6,24,24)
        if plr.hp>0 and (plrtgt 
                         or AABB(mox,moy,1,1,240-56-4+2,6*8+4+2+i*7,56-4,7)) then
            if plrtgt then
            spr(255,mox-8+(t*0.18%3),moy-8+(t*0.18%3),0)
            spr(255,mox+4-(t*0.18%3),moy-8+(t*0.18%3),0,1,0,1)
            spr(255,mox-8+(t*0.18%3),moy+4-(t*0.18%3),0,1,0,3)
            spr(255,mox+4-(t*0.18%3),moy+4-(t*0.18%3),0,1,0,2)
            end

            rect(240-56-4+2,6*8+4+2+i*7,56-4,7,4)

            if left and not leftheld then 
            plri=i
            sfx(8,12*6,6,3)
            end
        end
        if plri==i then
          rect(240-56-4+2,6*8+4+2+i*7,56-4,7,5)
        end
        
        print(e.type,240-56-4+2+1,6*8+4+2+1+i*7,12,false,1,true)
    end

end

function boss_all_cool()
    if enemies[turni].force then
    for i,s in ipairs(enemies[turni].spells) do
        if not find(enemies[turni].force,s) and enemies[turni].spells[s].cooldown<=0 and not enemies[turni].spells[s].justcooled then
        return false
        end
    end
    return true
    end
    return false
end

function resolve_turn_boss(args)
    -- turn end
    local alcnew,_=count_new(nil,args)
    if boss_all_cool() or (plri~=nil or find(autotargeting(),bactive) --[[or all_cool()]]) and (bactive~=nil or (--[[all_cool() and]] alcnew==0)) and ((args.state=='rowselect' or args.state=='firstclick') or picross[bactive] or (enemies[turni].spells[bactive] and alcnew>=enemies[turni].spells[bactive].minsq)) then
        rect(120+13*2+6+6,68+13*4-3,24,16,13)
        print('Done',120+13*2+6+6+4,68+13*4-3+5,12,false,1,true)
        rectb(120+13*2+6+6,68+13*4-3,24,16,t*FLASH_SPD)
        -- press 'done' button
        if args.left and not args.leftheld then
            if AABB(args.mox,args.moy,1,1,120+13*2+6+6,68+13*4-3,24,16) then
                sfx(8,12*6,6,3)
                
                if boss_all_cool() then
                    shout(fmt('%s can\'t do anything this turn!',enemy_name(enemies[turni])))
                end
                enemies[turni].force=nil
                
                nmy_backfire=false
                enemyatk=bactive
                browguess=true
                
                for sqx=0,args.mw-1 do
                for sqy=0,args.mh-1 do
                    -- check if row is correct (for new squares only)
                    if browguess and mget(args.bx+sqx,args.by+sqy)==0 and mget(args.ax+sqx,args.ay+sqy)==16 and mget(bmx+sqx,bmy+sqy)==0 then
                        --trace('fail')
                        browguess=false
                    end
                end
                end
                -- determine damage by amount of new squares
                new=count_new(nil,args)
  
                enemies[turni].headphase=enemies[turni].headphase+1
                enemies[turni].phase=nil
                
                for i,sp in ipairs(enemies[turni].spells) do
                    if enemies[turni].spells[sp].cooldown>0 then enemies[turni].spells[sp].cooldown=enemies[turni].spells[sp].cooldown-1 end
                end

                if browguess then
                if bactive=='Attack' then
                    allydmg(new,plri)
                    TIC=enemyturn
                elseif picross[bactive] then
                    allydmg(picross[bactive].w*picross[bactive].h,plri)
                    rem(bosspicross,bpicrossactive_i)
                    TIC=enemyturn
                else
                if bactive then
                shout(bactive..'!')
                TIC=_G['enemy_anim_'..string.lower(bactive)]
                else
                TIC=enemyturn
                end
                end
                else
                -- reset new squares on failure
                for sqxx=0,args.mw-1 do
                for sqyy=0,args.mh-1 do
                    if mget(args.bx+sqxx,args.by+sqyy)==0 and mget(args.ax+sqxx,args.ay+sqyy)==16 then
                        mset(args.ax+sqxx,args.ay+sqyy,0)
                    end
                end
                end
                nmy_backfire=true
                if bactive=='Attack' then
                    shout('The attack backfired: Incorrect Picross!')
                    enemydmg(new,turni)
                    TIC=enemyturn
                else
                shout('The spell backfired: Incorrect Picross!')
                TIC=_G['attack_anim_'..string.lower(bactive)]
                end
                end
                
                if enemies[turni].spells[bactive] then
                enemies[turni].icestack=enemies[turni].icestack or 0
                enemies[turni].flamestack=enemies[turni].flamestack or 0
                enemies[turni].spells[bactive].cooldown=enemies[turni].spells[bactive].maxcool+enemies[turni].icestack-enemies[turni].flamestack
                if enemies[turni].spells[bactive].cooldown>0 then bactive=nil end
                end

                for sqx=0,args.mw-1 do
                for sqy=0,args.mh-1 do
                    -- set old pic state
                    mset(args.bx+sqx,args.by+sqy,mget(args.ax+sqx,args.ay+sqy))
                end
                end
                
                if enemies[turni].poison then
                trace(fmt('Poison %d',enemies[turni].poison))
                end
                if browguess then enemies[turni].nudge=60 end
                
                bstate=nil
                bossfade=0
                sb_cam.y=sb_cam.oldy
                sc_t=t+1
            end
        end
    end
    if enemies[turni].spore then 
        enemies[turni].minatk=enemies[turni].minatk+enemies[turni].sporestack
        enemies[turni].maxatk=enemies[turni].maxatk+enemies[turni].sporestack
        for i,s in ipairs(enemies[turni].spells) do
            enemies[turni].spells[s].minsq=enemies[turni].spells[s].minsq+enemies[turni].sporestack
            enemies[turni].spells[s].maxsq=enemies[turni].spells[s].maxsq+enemies[turni].sporestack
        end
    end
    
    if TIC==enemyturn then turni=turni+1 end
end

function bossintro()
    if t-sc_t==0 then dist=0; poke(0x3FF8,0) end
    if t-sc_t==480 then
        sync((1<<3)+(1<<4),1); music(0) 
        poke(0x3FF8,2)
    end
    if t-sc_t>=480 then
        turn()
        dist=dist+2
    end
    rect(0-dist,0,120,136,2)
    rect(120+dist,0,120,136,2)
    if debug and t-sc_t==0 then sc_t=sc_t-(480) end
    if t-sc_t==480+90 then linel=nil; dist=0; TIC=turn end
    if t-sc_t<480 and (t-sc_t)%120==0 then
        local len=90
        if t-sc_t==360 then len=90+90 end
        sfx(14,'B-1',len,3)
    end
    
    linel=linel or 0
    for i=0,5 do
    line(90,i-8,90+cos(math.rad(20))*linel,i-8+sin(math.rad(20))*linel,4)
    line(0,i,0+cos(math.rad(20))*linel,i+sin(math.rad(20))*linel,4)
    end
    
    clip(0,0,linel,136)
    textri(
    90,0,90+cos(math.rad(20))*90,0+sin(math.rad(20))*90,90+cos(math.rad(110))*(30-4+2),0+sin(math.rad(110))*(30-4+2),
    t%66*8,54*8,t%66*8+66*8,54*8,t%66*8,(54+14)*8,
    true,12
    )
    textri(
    90+cos(math.rad(20))*90,0+sin(math.rad(20))*90,90+cos(math.rad(30))*90-1,30-4+6+2+sin(math.rad(110))*(30-4),90+cos(math.rad(110))*(30-4+2),0+sin(math.rad(110))*(30-4+2),
    t%66*8+66*8,54*8,t%66*8+66*8,(54+14)*8,t%66*8,(54+14)*8,
    true,12
    )
    textri(
    90+cos(math.rad(20))*90,0+sin(math.rad(20))*90,90+cos(math.rad(20))*90+cos(math.rad(20))*90,0+sin(math.rad(20))*90+sin(math.rad(20))*90,90+cos(math.rad(110))*(30-4+2)+cos(math.rad(20))*90,0+sin(math.rad(110))*(30-4+2)+sin(math.rad(20))*90,
    t%66*8,54*8,t%66*8+66*8,54*8,t%66*8,(54+14)*8,
    true,12
    )
    textri(
    90+cos(math.rad(20))*90+cos(math.rad(20))*90,0+sin(math.rad(20))*90+sin(math.rad(20))*90,90+cos(math.rad(30))*90+cos(math.rad(20))*90,30-4+6+2+sin(math.rad(110))*(30-4)+sin(math.rad(20))*90,90+cos(math.rad(110))*(30-4+2)+cos(math.rad(20))*90,0+sin(math.rad(110))*(30-4+2)+sin(math.rad(20))*90,
    t%66*8+66*8,54*8,t%66*8+66*8,(54+14)*8,t%66*8,(54+14)*8,
    true,12
    )
    textri(
    90-cos(math.rad(20))*90,0-sin(math.rad(20))*90,90+cos(math.rad(20))*90-cos(math.rad(20))*90,0+sin(math.rad(20))*90-sin(math.rad(20))*90,90+cos(math.rad(110))*(30-4+2)-cos(math.rad(20))*90,0+sin(math.rad(110))*(30-4+2)-sin(math.rad(20))*90,
    t%66*8,54*8,t%66*8+66*8,54*8,t%66*8,(54+14)*8,
    true,12
    )
    textri(
    90+cos(math.rad(20))*90-cos(math.rad(20))*90,0+sin(math.rad(20))*90-sin(math.rad(20))*90,90+cos(math.rad(30))*90-cos(math.rad(20))*90,30-4+6+2+sin(math.rad(110))*(30-4)-sin(math.rad(20))*90,90+cos(math.rad(110))*(30-4+2)-cos(math.rad(20))*90,0+sin(math.rad(110))*(30-4+2)-sin(math.rad(20))*90,
    t%66*8+66*8,54*8,t%66*8+66*8,(54+14)*8,t%66*8,(54+14)*8,
    true,12
    )
    clip()
    
    linel=linel or 0
    for i=0,5 do
    line(90+100,i-8,90+100+cos(math.rad(145))*linel,i-8+sin(math.rad(145))*linel,4)
    line(0+100+8,i-8,0+100+8+cos(math.rad(145))*linel,i-8+sin(math.rad(145))*linel,4)
    end
    clip(0,0,240,linel)
    textri(
    90+100-80,0+60-22+2,90+100-80+cos(math.rad(145))*120,0+60-22+sin(math.rad(145))*120+2,90+100-80+cos(math.rad(145+90))*(30-4+2),0+60-22+2+sin(math.rad(145+90))*(30-4+2),
    t%90*8+90*8,(71+14)*8,t%90*8,(71+14)*8,t%90*8+90*8,71*8,
    true,12
    )
    textri(
    90+100-80+cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145))*120,90+100-60+20+20+10-4-80-2+cos(math.rad(145))*120,30-4+6+2+30+60+20-4-4-2-22+2+sin(math.rad(145+90))*(30-4+2+4+2),90+100-80+cos(math.rad(145+90))*(30-4+2),0+60-22+2+sin(math.rad(145+90))*(30-4+2),
    t%90*8,(71+14)*8,t%90*8,71*8,t%90*8+90*8,71*8,
    true,12
    )
    textri(
    90+100-80+cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145))*120,90+100-80+cos(math.rad(145))*120+cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145))*120+sin(math.rad(145))*120,90+100-80+cos(math.rad(145+90))*(30-4+2)+cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145+90))*(30-4+2)+sin(math.rad(145))*120,
    t%90*8+90*8,(71+14)*8,t%90*8,(71+14)*8,t%90*8+90*8,71*8,
    true,12
    )
    textri(
    90+100-80+cos(math.rad(145))*120+cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145))*120+sin(math.rad(145))*120,90+100-60+20+20+10-4-80-2+cos(math.rad(145))*120+cos(math.rad(145))*120,30-4+6+2+30+60+20-4-4-2-22+2+sin(math.rad(145+90))*(30-4+2+4+2)+sin(math.rad(145))*120,90+100-80+cos(math.rad(145+90))*(30-4+2)+cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145+90))*(30-4+2)+sin(math.rad(145))*120,
    t%90*8,(71+14)*8,t%90*8,71*8,t%90*8+90*8,71*8,
    true,12
    )
    textri(
    90+100-80-cos(math.rad(145))*120,0+60-22+2-sin(math.rad(145))*120,90+100-80+cos(math.rad(145))*120-cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145))*120-sin(math.rad(145))*120,90+100-80+cos(math.rad(145+90))*(30-4+2)-cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145+90))*(30-4+2)-sin(math.rad(145))*120,
    t%90*8+90*8,(71+14)*8,t%90*8,(71+14)*8,t%90*8+90*8,71*8,
    true,12
    )
    textri(
    90+100-80+cos(math.rad(145))*120-cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145))*120-sin(math.rad(145))*120,90+100-60+20+20+10-4-80-2+cos(math.rad(145))*120-cos(math.rad(145))*120,30-4+6+2+30+60+20-4-4-2-22+2+sin(math.rad(145+90))*(30-4+2+4+2)-sin(math.rad(145))*120,90+100-80+cos(math.rad(145+90))*(30-4+2)-cos(math.rad(145))*120,0+60-22+2+sin(math.rad(145+90))*(30-4+2)-sin(math.rad(145))*120,
    t%90*8,(71+14)*8,t%90*8,71*8,t%90*8+90*8,71*8,
    true,12
    )
    clip()
    
    if linel<300 and t-sc_t<480 then linel=linel+2 end
    if t-sc_t>=480-60 then linel=linel-4 end
    
    -- because turn() already increments t
    if t-sc_t<480 then t=t+1 end
end

bosspicross={}
function boss_picross_unlock()
    cls(6)
    if tri_a==nil then
    tri_a=120-2*13-6
    tri_b=68
    tri_w=13*5-2+1
    end
    
    textri(tri_a,tri_b,tri_a+tri_w,tri_b,tri_a,tri_b+tri_w,8*bmx+0,8*bmy+0,8*bmx+8*bmw,8*bmy+0,8*bmx+0,8*bmy+8*bmh,true)
    textri(tri_a,tri_b+tri_w,tri_a+tri_w,tri_b,tri_a+tri_w,tri_b+tri_w,8*bmx+0,8*bmy+8*bmh,8*bmx+8*bmw,8*bmy+0,8*bmx+8*bmw,8*bmy+8*bmh,true)
    
    tri_a=tri_a+(120-1*13-6-tri_a)*0.1
    tri_w=tri_w+(13*10-2-tri_w)*0.1
    tri_b=tri_b+(4-tri_b)*0.1
    
    if t-sc_t>=60 then
        for i=1,#picross[fmt('%d:%d',bmx,bmy)] do
            print(sub(picross[fmt('%d:%d',bmx,bmy)],i,i),8+i*6,136/2+sin(t*0.2+i)*4,t*0.2+i)
        end
    end
    if t-sc_t==240 then
        ins(bosspicross,picross[fmt('%d:%d',mx,my)])
        if active~='Buff' and active~='SmolHeal' and active~='Taunt' and active~='Ice' and active~='Spore' and active~='Poison' and active~='AntiPsn' and active~='SoulLeech' and active~='AntiSpore' then sfx(8,12*6,6,3) end
        -- fresh Picross board
        for sqy=0,bmh-1 do
        for sqx=0,bmw-1 do
            mset(sqx,135-bmh+1+sqy,0)
            mset(sqx,135-bmh*2+1+sqy,0)
            mset(bmw+sqx,135-bmh+1+sqy,0)
        end
        end
        bstate=nil
        bmx=bmx+7
        if bmx>=51 then bmx=44 end
        if active=='Poison' then plr.poison=4; plr.poisonstack=plr.poisonstack or 0; plr.poisonstack=plr.poisonstack+new; end
      if active=='Flame' then enemies[turni].flame=3; enemies[turni].flamestack=enemies[turni].flamestack or 0; enemies[turni].flamestack=enemies[turni].flamestack+2; enemies[turni].icestack=enemies[turni].icestack or 0 end
        if active=='AntiPsn' then if enemies[turni].poison then enemies[turni].poisonstack=enemies[turni].poisonstack-new end end
        if active=='Summon' then 
            if #smnavail==0 then
            shout('But nobody came.')
            else
            local i=math.random(1,#smnavail)
            ins(enemies, smnavail[i])
            shout(fmt('Summoned %s!',smnavail[i].type))
            rem(smnavail,i)
            end
        end
        bosstiles={}
        ins_boss({{2,3,32},{5,3,32},{0,3},{1,3},{3,3},{4,3},{6,3}})
        ins_boss({{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6}})
        ins_boss({{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2}})
        ins_boss({{4,5,32},{4,0},{4,1},{4,2},{4,3},{4,4},{4,6}})
        ins_boss({{1,1},{2,1},{3,1},{4,1},{5,1}})
        TIC=enemyturn
        turni=turni+1
        sc_t=t+1
    end
    
    t=t+1
end
