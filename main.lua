-- title:  ROWBYROW
-- author: verysoftwares
-- desc:   a Picross battle game
-- script: lua
-- saveid: ROWBYROW

debug=false

t=0
x=96
y=24
ins=table.insert
rem=table.remove
fmt=string.format
sub=string.sub
sin=math.sin
cos=math.cos

TEXT_WOB=true
FLASH_SPD=0.3

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

function turn_query()

    cls(2)

    draw_bg()
    
    draw_board(args)

    draw_sidebar_query()
        
    resolve_turn_query()
    
    draw_footer()
    
    draw_header()

    t=t+1
end

bossfade=240

bosstiles={
        --{{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2}},
        --{{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6}},
        --['row3']={{2,3,32},{5,3,32},{0,3},{1,3},{3,3},{4,3},{6,3}},
        --{{4,5,32},{4,0},{4,1},{4,2},{4,3},{4,4},{4,6}},
}

function match(bt,who)
        for i,v in ipairs(bt) do
                if v[1]==who[1] and v[2]==who[2] and v[3]==who[3] then
                        return true
                end
        end
        return false
end

function ins_boss(lst)
        for i,b in ipairs(lst) do
                local tgt='row'..tostring(b[2])
                if not bosstiles[tgt] then bosstiles[tgt]={} end
                if not match(bosstiles[tgt],b) then ins(bosstiles[tgt], b) end
        end
        for i=0,7-1 do
                if bosstiles['row'..tostring(i)] and bosstiles['row'..tostring(i)]~=btiles then
                        table.sort(bosstiles['row'..tostring(i)], function(a,b) return a[1]<b[1] end)
                end
        end
        for i,b in ipairs(lst) do
                local tgt='col'..tostring(b[1])
                if not bosstiles[tgt] then bosstiles[tgt]={} end
                if not match(bosstiles[tgt],b) then ins(bosstiles[tgt], b) end
        end
        for i=0,7-1 do
                if bosstiles['col'..tostring(i)] and bosstiles['col'..tostring(i)]~=btiles then
                        table.sort(bosstiles['col'..tostring(i)], function(a,b) return a[2]<b[2] end)
                end
        end
end

ins_boss({{2,3,32},{5,3,32},{0,3},{1,3},{3,3},{4,3},{6,3}})
ins_boss({{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6}})
ins_boss({{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2}})
ins_boss({{4,5,32},{4,0},{4,1},{4,2},{4,3},{4,4},{4,6}})
ins_boss({{1,1},{2,1},{3,1},{4,1},{5,1}})

boss_queue={}

function bq_unlock(bx,by)
        if bx==5 and by==6 then
                if mget(args.ax+4,args.ay+6)==16 then
                        ins_boss({{1,6},{2,6},{3,6}})
                end
        end
        if bx==4 and by==6 then
                if mget(args.cx+5,args.cy+6)==32 then
                        ins_boss({{1,6},{2,6},{3,6}})
                end
        end
        if bx==2 and by==0 then ins_boss({{1,0,32},{0,0,32}}) end
        if bx==1 and by==1 then
                if mget(args.cx+1,args.cy+0)==32 then
                        ins_boss({{1,4,32}})
                end
        end
        if bx==1 and by==0 then
                if mget(args.ax+1,args.ay+1)==16 then
                        ins_boss({{1,4,32}})
                end
        end
        if bx==1 and by==6 then ins_boss({{1,5,32}}) end
        if bx==3 and by==0 then ins_boss({{0,0,32},{6,0,32}}) end
        if bx==3 and by==5 then ins_boss({{1,5,32}}) end
        if bx==0 and by==2 then
        ins_boss({{0,0,32},{0,4,32},{0,5,32},{0,6,32}})
        if mget(args.ax+0,args.ay+3)==16 then ins_boss({{0,1,32}}) end
        end
        if bx==0 and by==3 then 
        ins_boss({{0,0,32},{0,1,32},{0,5,32},{0,6,32}}) 
        if mget(args.ax+0,args.ay+2)==16 then ins_boss({{0,4,32}}) end
        end
        if bx==6 and by==5 then
                if mget(args.cx+4,args.cy+5)==32 then
                        ins_boss({{5,5,32}})
                end
        end
        if bx==4 and by==5 then
                if mget(args.cx+6,args.cy+5)==32 then
                        ins_boss({{5,5,32}})
                end
        end
        if bx==6 and by==4 then ins_boss({{6,5,32},{6,6,32}}) end
        if bx==5 and (by==4 or by==5 or by==6) then ins_boss({{5,4,32},{5,5,32},{5,6,32},{6,by,32}}) end
        if bx==1 and by==3 then ins_boss({{1,0,32}}) end
        if bx==2 and by==3 then ins_boss({{2,1},{2,4},{2,5},{2,6}}) end
        if bx==2 and by==2 then ins_boss({{2,0,32}}) end
        if bx==4 and by==0 then ins_boss({{0,0,32},{1,0,32}}) end
        if bx==0 and by==1 then ins_boss({{6,1}}) end
        if bx==6 and by==2 then ins_boss({{6,5,32},{6,6,32}}) end
        if bx==6 and by==3 then ins_boss({{6,0,32},{6,6,32}}) end
        if bx==6 and by==1 then ins_boss({{6,4,32},{6,5,32},{6,6,32}}) end
        if bx==3 and by==4 then ins_boss({{0,4,32},{6,4,32}}) end
        if bx==4 and by==4 then ins_boss({{0,4,32},{1,4,32}}) end
        if bx==5 and (by==0 or by==1 or by==2) and mget(args.cx+5,args.cy+3)==32 then ins_boss({{5,0},{5,1},{5,2},{5,4,32},{5,5,32},{5,6,32}}) end
        if bx==5 and by==3 then
                if mget(args.ax+5,args.ay+2)==16 or mget(args.ax+5,args.ay+1)==16 or mget(args.ax+5,args.ay+0)==16 then
                        ins_boss({{5,0},{5,1},{5,2},{5,4,32},{5,5,32},{5,6,32}})
                end             
        end
        if bx==2 and by==0 then ins_boss({{4,0},{5,0}}) end
        if bx==2 and by==1 and mget(args.cx+2,args.cy+3)==32 then ins_boss({{2,4},{2,5},{2,6}}) end
        if bx==2 and by==2 and mget(args.cx+2,args.cy+3)==32 then ins_boss({{2,1},{2,0,32},{2,4},{2,5},{2,6}}) end
        if bx==5 and by==4 and mget(args.ax+4,args.ay+4)==16 then ins_boss({{3,4},{2,4},{0,4,32},{1,4,32},{5,4,32},{6,4,32}}) end
        if bx==4 and by==4 and mget(args.cx+5,args.cy+4)==32 then ins_boss({{3,4},{2,4},{0,4,32},{1,4,32},{5,4,32},{6,4,32}}) end
        if bx==4 and by==6 then ins_boss({{0,6,32}}) end
        if bx==2 and by==4 then ins_boss({{5,4,32},{6,4,32}}) end
        if bx==2 and by==5 then ins_boss({{4,5,32},{5,5,32},{6,5,32},{0,5,32}}) end
        if bx==2 and by==6 then ins_boss({{6,6,32}}) end
        if bx==6 and by==6 then
                if mget(args.cx+6,args.cy+4)==32 then
                        ins_boss({{6,5,32}})
                end
        end
        if bx==6 and by==4 then
                ins_boss({{6,5,32},{6,6,32}})
        end
        if bx==0 and by==6 then
                if mget(args.cx+0,args.cy+4)==32 then
                        ins_boss({{0,5,32}})
                end
        end
        if bx==0 and by==4 then
                if mget(args.cx+0,args.cy+6)==32 then
                        ins_boss({{0,5,32}})
                end
        end
end

function aim_spell(sp)
        local si=find(enemies[turni].spells,sp)
        bctgt={x=16,y=sb_cam.y+6*8+7*3+7*(si)+6-3}
end

function bq_select(sp)
        if bactive==sp then return end
        ins(boss_queue, function() aim_spell(sp) end)
        ins(boss_queue, leftclick)
end

function bq_select2()
        if bactive=='Attack' then return end
        ins(boss_queue, function() bctgt={x=16,y=sb_cam.y+6*8+7*3+7*(-1)+6-3} end)
        ins(boss_queue, leftclick)
end

function bq_select3()
        ins(boss_queue, function() bctgt={x=16,y=sb_cam.y+6*8+7*3+7*(6)+6-3} end)
        ins(boss_queue, leftclick)
end

function bq_pick(sp,n)
        local poss={}
        -- remove duplicates
        for k,b in pairs(bosstiles) do
                for i2=#b,1,-1 do
                        local b2=b[i2]
                        if b2[3]==nil and mget(args.ax+b2[1],args.ay+b2[2])==16 then
                                rem(b,i2)
                                trace(fmt('removed duplicate %d,%d',b2[1],b2[2]))
                        elseif b2[3] and mget(args.cx+b2[1],args.cy+b2[2])==32 then
                                rem(b,i2)
                                trace(fmt('removed duplicate %d,%d',b2[1],b2[2]))
                        end
                end
        end
        local longestc,lchold=0,nil
        for k,b in pairs(bosstiles) do
                local c=0
                for i2=#b,1,-1 do
                        local b2=b[i2]
                        if mget(args.ax+b2[1],args.ay+b2[2])==16 then
                                rem(b,i2)
                        else
                        if b2[3]~=32 then c=c+1 end
                        end
                end
                if c>=n then ins(poss,b); trace(k) end
                if c>=longestc then longestc=c; lchold=b end
                --if #b>=n then ins(poss,b) end
        end

        if #poss==0 then
                btiles=lchold
        else
        btiles=poss[math.random(#poss)]
        end

        local i,j=1,0
        while j<n and i<=#btiles do
                local b=btiles[i]
                
                if args.who.taunt and j>=count_taunt(args) then
                        ins(boss_queue, function()
                        bctgt={x=120-2*13-6+(btiles[1][1]+1)*(bgrid+1)-(bgrid+1)/2,y=68+(btiles[1][2]+1)*(bgrid+1)-(bgrid+1)/2}
                        end)
                        ins(boss_queue, longleftclick)
                        if enemies[turni].spells[sp] and j<enemies[turni].spells[sp].minsq then 
                                --if j>1 then
                                bq_select2()
                                if plri==nil then
                                        bq_target()
                                end
                                bq_done()
                                --else
                                --if enemies[turni].spells['Poison'].cooldown==0 then
                                --bq_select('Poison')
                                --if plri==nil then
                                --      bq_target()
                                --end
                                --bq_done()
                                --else
                                -- what should be done here?
                                --end
                                --end
                        end
                        break
                end
                
                if (not b[3] and mget(args.ax+b[1],args.ay+b[2])~=16) or (b[3] and mget(args.cx+b[1],args.cy+b[2])~=32) then
                if b[3]~=32 then j=j+1 end
                ins(boss_queue, function()
                if (not b[3] and mget(args.ax+b[1],args.ay+b[2])~=16) or (b[3] and mget(args.cx+b[1],args.cy+b[2])~=32) then
                bctgt={x=120-2*13-6+(btiles[1][1]+1)*(bgrid+1)-(bgrid+1)/2,y=68+(btiles[1][2]+1)*(bgrid+1)-(bgrid+1)/2}
                else enemies[turni].phase=enemies[turni].phase+2 
                end
                rem(btiles,1)
                end)
                bq_unlock(b[1],b[2])
                if b[3]==32 then
                ins(boss_queue, rightclick)
                else
                ins(boss_queue, leftclick)
                end
                end
                
                ::bskip::
                i=i+1
        end
        
        if #poss==0 and enemies[turni].spells[sp] and j<enemies[turni].spells[sp].minsq then    
        --if j>1 then
        bq_select2()
        if plri==nil then
                bq_target()
        end
        bq_done()
        end

        local unlocks={}
        for k,b in pairs(bosstiles) do
                for i2=#b,1,-1 do
                        local b2=b[i2]
                        if b2[3]==32 then
                                ins(unlocks,b2)
                        end
                end
        end
        for i,b in ipairs(unlocks) do
                bq_unlock(b[1],b[2])
        end
        for k,b in pairs(bosstiles) do
                for i2=#b,1,-1 do
                        local b2=b[i2]
                        if b~=btiles and b2[3]==32 and mget(args.cx+b2[1],args.cy+b2[2])==0 then
                                        ins(boss_queue, function()
                                        if mget(args.cx+b2[1],args.cy+b2[2])==0 then
                                        bctgt={x=120-2*13-6+(b2[1]+1)*(bgrid+1)-(bgrid+1)/2,y=68+(b2[2]+1)*(bgrid+1)-(bgrid+1)/2}
                                        --bq_unlock(b2[1],b2[2])
                                        else enemies[turni].phase=enemies[turni].phase+2 end
                                        rem(b,find(b,b2))
                                        end)
                                        ins(boss_queue, rightclick)                                     
                        end
                end
        end
end

function bq_pick_wrong(n)
        for sqx=0,args.mw-1 do
        for sqy=0,args.mh-1 do
                if mget(args.cx+sqx,args.cy+sqy)==32 then
                        ins(boss_queue, function()
                        bctgt={x=120-2*13-6+(sqx+1)*(bgrid+1)-(bgrid+1)/2,y=68+(sqy+1)*(bgrid+1)-(bgrid+1)/2}
                        end)
                        ins(boss_queue, rightclick)
                        ins(boss_queue, leftclick)
                        ins_boss({{sqx,sqy,32}})
                        return
                end
        end
        end
        ins(boss_queue, function()
        bctgt={x=120-2*13-6+(0+1)*(bgrid+1)-(bgrid+1)/2,y=68+(0+1)*(bgrid+1)-(bgrid+1)/2}
        end)
        ins(boss_queue, leftclick)
end

function bq_done()
        ins(boss_queue, function() bctgt={x=120+13*2+6+6+12,y=68+13*4-3+8} end)
        ins(boss_queue, leftclick)
end

function leftclick()
        if not bcl then bcl=true
        else bcl=false; bc_t=12; enemies[turni].phase=enemies[turni].phase+1 end
end

function longleftclick()
        bcl_t=bcl_t or 120
        if bcl_t>0 then bcl=true; bcl_t=bcl_t-1
        else bcl_t=nil; bcl=false; bc_t=12; enemies[turni].phase=enemies[turni].phase+1 end
end

function rightclick()
        if not bcr then bcr=true
        else bcr=false; bc_t=12; enemies[turni].phase=enemies[turni].phase+1 end
end

function bq_target(i)
     i=i or 1
        ins(boss_queue, function() bctgt={x=56+5+12-(i-1)*30,y=6*8-24-6+12} end)
        ins(boss_queue, leftclick)
end

function boss1_queue(sp,forced)
        boss_queue={}
        if not forced and enemies[turni].force then
                if boss_all_cool() then             
                        bq_done()
                        return
                end
                for i,s in ipairs(enemies[turni].spells) do
                     if not find(enemies[turni].force,s) and enemies[turni].spells[s].cooldown<=0 and not enemies[turni].spells[s].justcooled then
                                boss1_queue(s,true)
                                return
                        end
                end
        end
        if #bosspicross>0 and sp~='Poison' and not enemies[turni].force then
                bq_select3()
                local weakest=allies[1]
                for i,a in ipairs(allies) do
                if a.maxhp<weakest.maxhp then weakest=a end
                end
                bq_target(find(allies,weakest))
                bq_done()
                start_dialogue('boss1_weakest')
                return
        end
        if sp=='Attack' then
                bq_select2()
                if plri~=1 then bq_target(1) end
                bq_pick(sp,enemies[turni].maxatk)
                bq_done()
        end
        if sp=='Flame' then
                bq_select('Flame')
                bq_pick(sp,enemies[turni].spells[sp].maxsq)
                bq_done()
        end
        if sp=='Poison' then
                if not enemies[turni].poison or enemies[turni].poison<2 then 
                bq_select('Poison')
                if plri==nil then
                bq_target()
                end
                bq_pick_wrong(enemies[turni].spells[sp].minsq)
                bq_done()
                else
                enemies[turni].headphase=enemies[turni].headphase+1
                if enemies[turni].headphase>#boss_head_queue then enemies[turni].headphase=1 end
                boss_head_queue[enemies[turni].headphase]()
                end
        end
        if sp=='AntiPsn' then
                bq_select('AntiPsn')
                bq_pick(sp,enemies[turni].spells[sp].maxsq)
                bq_done()
        end
        if sp=='Summon' then
                if live_nmy()<3 then
             bq_select('Summon')
                bq_pick(sp,enemies[turni].spells[sp].maxsq)
                bq_done()
                else
                boss1_queue('Attack')
                end
        end
end

function live_nmy()
        local out=0
        for i,e in ipairs(enemies) do
                if e.hp>0 then out=out+1 end
        end
        return out
end

function live_ally()
        local out=0
        for i,a in ipairs(allies) do
                if a.hp>0 then out=out+1 end
        end
        return out
end

boss_head_queue={
        function() boss1_queue('Summon') end,
        function() boss1_queue('Flame') end,
        function() boss1_queue('Poison') end,
        function() boss1_queue('AntiPsn') end,
        function() boss1_queue('AntiPsn') end,
        function() boss1_queue('Summon') end,
        function() boss1_queue('Poison') end,
        function() boss1_queue('Flame') end,
        function() boss1_queue('AntiPsn') end,
        function() boss1_queue('AntiPsn') end,
        function() boss1_queue('Poison') end,
        function() boss1_queue('Attack') end,
}

function boss1_ai()
        if not enemies[turni].headphase then
          enemies[turni].headphase=1
        end
        if not enemies[turni].phase then
                if enemies[turni].headphase>#boss_head_queue then enemies[turni].headphase=1 end
                boss_head_queue[enemies[turni].headphase]()
                enemies[turni].phase=1
        end
        --leftheld=bcl

        if bctgt==nil then
        if bc_t and bc_t>0 then bc_t=bc_t-1
        else 
        boss_queue[enemies[turni].phase]()
        end
        else
        bcx=bcx+(bctgt.x-bcx)*0.15
        bcy=bcy+(bctgt.y-bcy)*0.15
        if math.abs(bctgt.x-bcx)<1 and math.abs(bctgt.y-bcy)<1 then
        bctgt=nil
        enemies[turni].phase=enemies[turni].phase+1
        bc_t=12
        end
        end
end

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

function draw_sidebar_query()
        leftheld=left
        mox,moy,left,_,right,_,mwv=mouse()

        -- left bar

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
        sh=sh+(#keywords+1)*7
        
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
        print('Keywords',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
        end
        
        for i,kw in ipairs(keywords) do
                if sb_cam.y+6*8+7*(i-1)+7+7+6>6*8+4+2 and (sb_cam.y+6*8+7*(i-1)+7+6<6*8+4+64+8+8-1-1 or -sb_cam.y+6*8+4+7-7+1>=sh) then
                if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,4)
                    if left and not leftheld then
                            queryi=i
                            sfx(8,12*6,6,3)
                    end
                end
                if queryi==i then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,5)
                end
                
                local tw=print(kw,6+1,-6,12,false,1,true)
                sb_cam['x'..tostring(i)]=sb_cam['x'..tostring(i)] or 0
                sb_cam['dx'..tostring(i)]=sb_cam['dx'..tostring(i)] or -0.25
                if tw>56-4 then
                        clip(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7)
                        if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                        sb_cam['x'..tostring(i)]=sb_cam['x'..tostring(i)]+sb_cam['dx'..tostring(i)]
                        if sb_cam['x'..tostring(i)]+6+1+tw<56 or sb_cam['x'..tostring(i)]>2 then sb_cam['dx'..tostring(i)]=-sb_cam['dx'..tostring(i)] end
                        end
                end
                
                print(kw,6+1+sb_cam['x'..tostring(i)],sb_cam.y+6*8+7*(i-1)+7+7,12,false,1,true)
                clip()
                
                end
        end
end

function resolve_turn_query()
        if queryi~=nil then
                rect(120+13*2+6+6,68+13*4-3,24,16,13)
                print('Done',120+13*2+6+6+4,68+13*4-3+5,12,false,1,true)
                rectb(120+13*2+6+6,68+13*4-3,24,16,t*FLASH_SPD)
                -- press 'done' button
                if left and not leftheld then
                        if AABB(mox,moy,1,1,120+13*2+6+6,68+13*4-3,24,16) then
                                sfx(8,12*6,6,3)
                        
                                TIC=attack_anim_query
                                sc_t=t+1
                                for i=1,#keywords do
                                        sb_cam['x'..tostring(i)]=nil
                                        sb_cam['dx'..tostring(i)]=nil
                                end
                        end
                end
        end

end

function debug_grid()
        -- grid size debug
        -- Ctrl+left/right keys
        status=status or 1
        if status==1 then
                mw=5;mh=5;grid=12
                if key(63) and btnp(3) then status=2; clear_picross() end
        elseif status==2 then
          mw=6;mh=6;grid=10
                if key(63) and btnp(3) then status=3; clear_picross() end
                if key(63) and btnp(2) then status=1; clear_picross() end
        elseif status==3 then
                mw=7;mh=7;grid=8
                if key(63) and btnp(3) then status=4; clear_picross() end
                if key(63) and btnp(2) then status=2; clear_picross() end
        elseif status==4 then
                mw=8;mh=8;grid=7
                if key(63) and btnp(3) then status=5; clear_picross() end
                if key(63) and btnp(2) then status=3; clear_picross() end
        elseif status==5 then
                mw=9;mh=9;grid=6
                if key(63) and btnp(3) then status=6; clear_picross() end
                if key(63) and btnp(2) then status=4; clear_picross() end
        elseif status==6 then
                mw=10;mh=10;grid=5
                if key(63) and btnp(2) then status=5; clear_picross() end
        end
end

function all_cool()
        if plr.force and #forced==0 then return true end

        for i,sp in ipairs(plrspells) do
                if plrspells[sp].cooldown<=0 and find(forced,sp) then return false end
        end
        if #plrpicross==0 and (plr.force or (plr.atk_cooldown and plr.atk_cooldown>0)) then
        return true
        end
        return false
end

cast={
['Meteor']=180,
['Lightning']=50,
['SmolHeal']=120,
['Buff']=120,
['Taunt']=90,
['Ice']=130,
['Spore']=120,
['Poison']=120,
['AntiPsn']=120,
['Leech']=150,
['Mine']=110,
['SoulLeech']=160,
['AntiSpore']=140,
['Flame']=130,
['Flee']=60,
['Reflect']=100,
['MedHeal']=150,
['Query']=90,
['Summon']=140,
}

function autotargeting()
        return {'Lightning','SmolHeal','Buff','AntiPsn','AntiSpore','Flame','Flee','Reflect','Upgrade','MedHeal','Summon'}
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

function count_new(sel,args)
        local select=sel or args.select
        local new=0
        local buffd=false
        if not args.who.buff then
        for sqx=0,args.mw-1 do
        for sqy=0,args.mh-1 do
                if mget(args.bx+sqx,args.by+sqy)==0 and mget(args.ax+sqx,args.ay+sqy)==16 then
                        new=new+1
                end
        end
        end
        else
                if args.state=='firstclick' then return 1 end
                if args.state=='rowselect' and select=='column' then
                        for sqy=0,args.mh-1 do
                                if mget(args.bx+args.firsttile.x,args.by+sqy)==16 then buffd=true end
                                if mget(args.bx+args.firsttile.x,args.by+sqy)==16 or mget(args.ax+args.firsttile.x,args.ay+sqy)==16 then
                                        new=new+1
                                end
                        end
                end
                if args.state=='rowselect' and select=='row' then
                        for sqx=0,args.mw-1 do
                                if mget(args.bx+sqx,args.by+args.firsttile.y)==16 then buffd=true end
                                if mget(args.bx+sqx,args.by+args.firsttile.y)==16 or mget(args.ax+sqx,args.ay+args.firsttile.y)==16 then
                                        new=new+1
                                end
                        end
                end
        end
        return new,buffd
end

function poisondmg()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t-sc_t==90 then labels={} end 
        if t-sc_t>=90 and header.t==0 then
                sc_t=t+1
                ::retry::
                if turni<=#enemies then
            if enemies[turni].hp>0 and enemies[turni].poison and header.t==0 then   
                                sfx(8,12*6,6,3)
                                enemydmg(enemies[turni].poisonstack,turni)
                                if enemies[turni].poisonstack>=0 then
                                shout(fmt('%s takes poison damage!',enemy_name(enemies[turni])))
                                else shout(fmt('%s is healed by the AntiPsn in its veins!',enemy_name(enemies[turni]))) end
                                turni=turni+1
            elseif enemies[turni].hp==0 or not enemies[turni].poison then turni=turni+1; goto retry end
            --if TIC==poisondmg and header.t==0 then turni=turni+1 end--TIC=enemyturn 
                else
                        if plr.hp==0 then
                                TIC=gameover
                        elseif enemyclear() then
                                gain_exp()
                                TIC=victory
                        else
                        TIC=turn
                        end
                end
        end

        draw_labels()
        draw_header()

        t=t+1
end

function pass() end

function gain_exp()
        local expplus=0
        for i,e in ipairs(enemies) do
                if expgain[e.type] then expplus=expplus+expgain[e.type] end
        end
        local extra=0
        if plr.sponge then extra=expplus//4 end
        -- lvl_tgt is used here (instead of cur_lv+1
        -- to not gain the same level twice
        local msg=fmt(' (%d needed for next level)',levels[lvl_tgt]-(exp+expplus+extra))
        if exp+expplus+extra>=levels[lvl_tgt] then
          msg=''
        end
        if not plr.sponge then
        shout(fmt('Victory! Gained %d exp.%s',expplus,msg))
        exp=exp+expplus
        else
        shout(fmt('Victory! Gained %d+%d exp.%s',expplus,extra,msg))
        exp=exp+expplus
        exp=exp+extra
        end
        if exp+expplus+extra>=levels[lvl_tgt] then
                shout('LEVEL UP! Got a board upgrade!')
                ins(plrpicross,'Upgrade')
                cur_lv=cur_lv+1
                lvl_tgt=lvl_tgt+1
                shout('Max HP increased by 5!')
                plr.maxhp=plr.maxhp+5
                plr.origmaxhp=plr.maxhp
        end
end

reflectshout={}
prequeue={}
queue={}

exp=0
if debug then exp=670 end
levels={
        [0]=0,
        [1]=700,
        [2]=1500,
}
cur_lv=0
lvl_tgt=1

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
                --      old_queue=#queue
                --      inc=true
                --end
                rem(queue,#queue)
                --if inc then
                --      old_queue=old_queue-1
                --      i=i+1
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

function allyturn()
        if allyi==2 and allyi>#allies then TIC=enemyturn; turni=1; sc_t=t+1 end
        if t-sc_t>=90 and header.t==0 then
                sc_t=t+1
                if allyi<=#allies then
                enemydmg(math.random(allies[allyi].minatk,allies[allyi].maxatk),math.random(1,#enemies))
                allies[allyi].nudge=60
                allyi=allyi+1
                else
                TIC=enemyturn
                turni=1
                end
        end

        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if allyi==1 or (allyi-1>0 and ((not allies[allyi-1].nudge) or (allies[allyi-1].nudge and allies[allyi-1].nudge<30))) then
        if allyi-1>0 and allies[allyi-1].nudge and allies[allyi-1].nudge==30-3 then 
        sfx(8,12*6,6,3) 
        end
        draw_labels()
        end
        
        draw_header()
        
        t=t+1
end

function reset_encounter()
        enemyi=nil
        active=nil
        picrossactive_i=nil
        for i,v in ipairs(plrspells) do
                plrspells[v].cooldown=0
        end
        plr.buff=nil
        plr.taunt=nil
        plr.ice=nil; plr.icestack=0
        plr.spore=nil; plr.sporestack=0
        plr.poison=nil; plr.poisonstack=0
        plr.flame=nil; plr.flamestack=0
        plr.reflect=nil

        plr.maxhp=plr.origmaxhp
        if plr.hp>plr.maxhp then plr.hp=plr.maxhp end
        
        bosspicross={}
end

function victory()
        if t-sc_t>=180 and header.t==0 then
                --remove encounter from map
                local overlap=false
                for i=#area.roaming,1,-1 do
                        local r=area.roaming[i]
                        if r.tx==wldplr.tx and r.ty==wldplr.ty then rem(area.roaming,i); overlap=true; break end
                end
                if not overlap then
                mset(wldplr.tx,wldplr.ty,65)
                end
                
                --reset encounter-specific state
                reset_encounter()
                
                sc_t=t+1
                TIC=overworld_roaming
                music()
                
                postvictory()
        end
        draw_bg()
        draw_board(args)
        draw_header()
        t=t+1
end

function postvictory()
        if cur_encounter==encounters['rival1'] then
                start_dialogue('sc_1_post-telepathy')   
        end

        shrooms=0
        for i,v in ipairs({{44,40},{47,34},{50,40}}) do
                if mget(v[1],v[2])==65 then shrooms=shrooms+1 end
        end
        if shrooms==1 and not diag_db['sc_2_avenge'] and find({encounters['50:40'],encounters['44:40'],encounters['47:34']},cur_encounter) then
                if cur_encounter==encounters['50:40'] then
                        -- Shaably
                        diag_db['sc_2_avenge']={
                                {sp=374,col=2,'Aa, my everything hurts.'},
                                {f=function() ins(enemies,{type='Sheebly',blink=60,hp=28}); ins(enemies,{type='Shoobly',blink=60,hp=28}) end},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'We came here as soon as we heard a ruckus.'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Did you get yourself beaten up?'},
                                {sp=374,col=2,'I.. I don\'t understand.. Usually my Spores do the trick..'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'We will certainly avenge you.'},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Yeah, we\'ve got to.'},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Come meet me in an encounter to the west.'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'No no, come to the northwest! I wanna be the one to avenge Shaably!'},
                                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
                        }
                end
                if cur_encounter==encounters['44:40'] then
                        -- Sheebly
                        diag_db['sc_2_avenge']={
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Aa, my everything hurts.'},
                                {f=function() ins(enemies,{type='Shaably',blink=60,hp=28}); ins(enemies,{type='Shoobly',blink=60,hp=28}) end},
                                {sp=374,col=2,'We came here as soon as we heard a ruckus.'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Did you get yourself beaten up?'},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'I.. I don\'t understand.. Usually my Leeches do the trick..'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'We will certainly avenge you.'},
                                {sp=374,col=2,'Yeah, we\'ve got to.'},
                                {sp=374,col=2,'Come meet me in an encounter to the east.'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'No no, come to the northeast! I wanna be the one to avenge Sheebly!'},
                                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
                        }
                end
                if cur_encounter==encounters['47:34'] then
                        -- Shoobly
                        diag_db['sc_2_avenge']={
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Aa, my everything hurts.'},
                                {f=function() ins(enemies,{type='Sheebly',blink=60,hp=28}); ins(enemies,{type='Shaably',blink=60,hp=28}) end},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'We came here as soon as we heard a ruckus.'},
                                {sp=374,col=2,'Did you get yourself beaten up?'},
                                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I.. I don\'t understand.. Usually my Poison does the trick..'},
                                {sp=374,col=2,'We will certainly avenge you.'},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Yeah, we\'ve got to.'},
                                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Come meet me in an encounter to the southwest.'},
                                {sp=374,col=2,'No no, come to the southeast! I wanna be the one to avenge Shoobly!'},
                                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
                        }
                end
                start_dialogue('sc_2_avenge')
        end
        if shrooms==2 and not has_read('sc_2_shroom_bros2') and find({encounters['50:40'],encounters['44:40'],encounters['47:34']},cur_encounter) then
                if cur_encounter==encounters['44:40'] then
                        ins(diag_db['sc_2_shroom_bros2'],1,{f=function() ins(enemies,{type='Shaably',blink=60,hp=28}); ins(enemies,{type='Shoobly',blink=60,hp=28}) end})
                end
                if cur_encounter==encounters['47:34'] then
                        ins(diag_db['sc_2_shroom_bros2'],1,{f=function() ins(enemies,{type='Sheebly',blink=60,hp=28}); ins(enemies,{type='Shaably',blink=60,hp=28}) end})
                end
                if cur_encounter==encounters['50:40'] then
                        ins(diag_db['sc_2_shroom_bros2'],1,{f=function() ins(enemies,{type='Shoobly',blink=60,hp=28}); ins(enemies,{type='Sheebly',blink=60,hp=28}) end})
                end
                start_dialogue('sc_2_shroom_bros2')
        end
        if shrooms==3 and not has_read('sc_2_shroom_bros') and find({encounters['50:40'],encounters['44:40'],encounters['47:34']},cur_encounter) then
                if cur_encounter==encounters['44:40'] then
                        ins(diag_db['sc_2_shroom_bros'],1,{f=function() ins(enemies,{type='Shaably',blink=60,hp=28}); ins(enemies,{type='Shoobly',blink=60,hp=28}) end})
                end
                if cur_encounter==encounters['47:34'] then
                        ins(diag_db['sc_2_shroom_bros'],1,{f=function() ins(enemies,{type='Sheebly',blink=60,hp=28}); ins(enemies,{type='Shaably',blink=60,hp=28}) end})
                end
                if cur_encounter==encounters['50:40'] then
                        ins(diag_db['sc_2_shroom_bros'],1,{f=function() ins(enemies,{type='Shoobly',blink=60,hp=28}); ins(enemies,{type='Sheebly',blink=60,hp=28}) end})
                end
                start_dialogue('sc_2_shroom_bros')
        end
        
        if cur_encouter==encounters['56:43'] then
                start_dialogue('boss1_win')
        end
end

function gameover()
        tx=tx or 120-20; ty=ty or 60
        xadd=xadd or -1; yadd=yadd or -1
        local tw=print('Game over',tx,ty,t*FLASH_SPD)
        tx=tx+xadd; ty=ty+yadd
        if tx<0 then xadd=-xadd; tx=tx+xadd end
        if ty<0 then yadd=-yadd; ty=ty+yadd end
        if tx>240-tw+1 then xadd=-xadd; tx=tx+xadd end
        if ty>136-6+1 then yadd=-yadd; ty=ty+yadd end
        
        if thanks then
        local t2w=print('Thanks for playtesting!',0,-6,1,false,1,true)
        print('Thanks for playtesting!',120-t2w/2-1,96,1,false,1,true)
        print('Thanks for playtesting!',120-t2w/2,96-1,1,false,1,true)
        print('Thanks for playtesting!',120-t2w/2+1,96,1,false,1,true)
        print('Thanks for playtesting!',120-t2w/2,96+1,1,false,1,true)
        print('Thanks for playtesting!',120-t2w/2,96,12,false,1,true)
        else
        local t2w=print('R to reset game.',0,-6,1,false,1,true)
        print('R to reset game.',120-t2w/2-1,96,1,false,1,true)
        print('R to reset game.',120-t2w/2,96-1,1,false,1,true)
        print('R to reset game.',120-t2w/2+1,96,1,false,1,true)
        print('R to reset game.',120-t2w/2,96+1,1,false,1,true)
        print('R to reset game.',120-t2w/2,96,12,false,1,true)
        if keyp(18) then
                poke(0x3FF8,0); reset()
        end
        end
        
        t=t+1
end

function find(tb,what)
        for i,v in ipairs(tb) do 
                if v==what then return i end
        end
        return nil
end

function attack_anim_meteor()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles= particles or {}
                local size=math.random(1,2)
                if size==1 then
                        ins(particles,{sp=256,w=4,x=160-30-60+(enemyi-1)*40+math.random(0,24),y=-4*8})
                elseif size==2 then
                        ins(particles,{sp=260,w=2,x=160-30-60+(enemyi-1)*40+math.random(0,24),y=-2*8})              
                end
        end
        if particles then
        for i=#particles,1,-1 do
                local m=particles[i]
                spr(m.sp,m.x,m.y,0,1,0,0,m.w,m.w)
                m.x=m.x+1; m.y=m.y+1
                if m.y>6*8-m.w*8 then
                        rem(particles,i)
                end
        end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                enemydmg(new*plrspells[active].mult)
                particles=nil
                sc_t=t+1
                sfx(8,12*6,6,3)
                enemy_adapt('Meteor')
        end
        t=t+1
end

function attack_anim_lightning()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                if not lw then lw=0; rect(0,0,240,6*8,12) end
                if lw<4 then lw=lw+1 end
        end
        if t%8<3 then
                for i,e in ipairs(enemies) do
                if e.hp>0 or (e.t and e.t>0) then
                spr(262,160-30+(i-1)*40,0,0,1,0,0,3,lw)
                end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                for i,e in ipairs(enemies) do
                enemydmg(new*plrspells[active].mult,i)
                end
                lw=nil
                sc_t=t+1
                sfx(8,12*6,6,3)
                enemy_adapt('Lightning')
        end
        
        t=t+1
end

function attack_anim_mine()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        local r=(t*0.07)%4
        spr(138,160-30+(enemyi-1)*40,6*8-24-6,0,1,0,r,3,3)
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                enemies[enemyi].force=plrspells
                sc_t=t+1
                enemy_adapt('Mine')
        end
        
        t=t+1
end

function attack_anim_ice()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if (t-sc_t>12 and t-sc_t<=24) or (t-sc_t>36 and t-sc_t<48 and t%3==0) then
        pal(8,12); pal(9,12); pal(10,12)
        end
        spr(119,160-30+(enemyi-1)*40,6*8-24-6,0,1,0,0,3,3)
        pal()
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                enemies[enemyi].ice=3
                enemies[enemyi].icestack=enemies[enemyi].icestack or 0
                enemies[enemyi].icestack=enemies[enemyi].icestack+2
                enemies[enemyi].flamestack=enemies[enemyi].flamestack or 0
                enemies[enemyi].done4=true
                sc_t=t+1
                enemy_adapt('Ice')
        end
        
        t=t+1
end

function attack_anim_antipsn()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        pal(7,1); pal(6,2)
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=176,x=56+5+math.random(0,23),y=6*8-6-1,w=1})
                elseif size==2 then
                        ins(particles,{sp=177,x=56+5+math.random(0,23),y=6*8-6-1,w=1})
                end
        end
        
        spr(192,56+5,6*8-4-12+4+2,0,1,0,0,3,1)
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        pal()
        
        draw_header()
        
        if t-sc_t==cast[active] then
                particles=nil
                TIC=allyturn
                allyi=2
                if plr.poison then
                plr.poisonstack=plr.poisonstack-new
                end
                sc_t=t+1
                enemy_adapt('AntiPsn')
        end
        
        t=t+1
end


function attack_anim_smolheal()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=50+math.random(24)+5,y=6*8-2*8,w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=50+math.random(24)+5,y=6*8-2*8,w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                plrdmg(new*plrspells[active].mult)
                particles=nil
                sc_t=t+1
                enemy_adapt('SmolHeal')
        end

        t=t+1
end

function attack_anim_medheal()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=50+math.random(24)+5,y=6*8-2*8,w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=50+math.random(24)+5,y=6*8-2*8,w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                plrdmg(new*plrspells[active].mult)
                particles=nil
                sc_t=t+1
                enemy_adapt('MedHeal')
        end

        t=t+1
end

function attack_anim_buff()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local colour= math.random(1,2)
                if colour==1 then
                        ins(particles,{sp=297,x=50+math.random(24)+5,y=6*8-2*8,w=1})
                elseif colour==2 then
                        ins(particles,{sp=298,x=50+math.random(24)+5,y=6*8-2*8,w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                plr.buff=3; plr.done2=true
                particles=nil
                sc_t=t+1
                enemy_adapt('Buff')
        end

        t=t+1       
end

function attack_anim_taunt()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        spr(167,160-30+(enemyi-1)*40,6*8-24-8+sin(t*0.1)*6,1,1,0,0,3,3)
        
        draw_header()
        
        if t-sc_t==cast[active] then TIC=allyturn; allyi=2; sc_t=t+1; enemies[enemyi].done3=true; enemies[enemyi].taunt=3; enemy_adapt('Taunt'); enemies[enemyi].done3=true end
        t=t+1
end

function attack_anim_spore()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%4==0 then
                particles=particles or {}
                ins(particles,{sp=166,x=160-30+(enemyi-1)*40+math.random(0,23),y=8,w=1})
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        h.y=h.y+1
                        if h.y>6*8-8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then particles=nil; TIC=allyturn; allyi=2; sc_t=t+1; enemies[enemyi].done5=true; enemies[enemyi].spore=3; enemies[enemyi].sporestack=enemies[enemyi].sporestack or 0; enemies[enemyi].sporestack=enemies[enemyi].sporestack+2; enemy_adapt('Spore'); enemies[enemyi].done5=true end
        t=t+1
end

function attack_anim_poison()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        if nmy_backfire then enemyi=turni end
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=176,x=160-30+(enemyi-1)*40+math.random(0,23),y=6*8-6-1,w=1})
                elseif size==2 then
                        ins(particles,{sp=177,x=160-30+(enemyi-1)*40+math.random(0,23),y=6*8-6-1,w=1})
                end
        end
        
        spr(192,160-30+(enemyi-1)*40,6*8-4-12+4+2,0,1,0,0,3,1)
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if (not nmy_backfire and t-sc_t==cast[active]) or (nmy_backfire and t-sc_t==cast[enemyatk]) then 
        particles=nil; 
        if not nmy_backfire then 
        TIC=allyturn
        allyi=2 
        else 
        TIC=enemyturn
        turni=turni+1; 
        nmy_backfire=false 
        end
        enemies[enemyi].poison=4 
        enemies[enemyi].poisonstack=enemies[enemyi].poisonstack or 0
        enemies[enemyi].poisonstack=enemies[enemyi].poisonstack+new
        enemy_adapt('Poison'); enemies[enemyi].done6=true 
        sc_t=t+1; 
        end

        t=t+1
end

function attack_anim_leech()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=160-30+(enemyi-1)*40,y=6*8-2*8-math.random(24),w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=160-30+(enemyi-1)*40,y=6*8-2*8-math.random(24),w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        h.x=h.x-1
                        if h.x<56+5 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then particles=nil; TIC=allyturn; allyi=2; sc_t=t+1; enemydmg(new*2); plrdmg(-new*2); enemy_adapt('Leech') end
        t=t+1
end

function attack_anim_flame()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        for i=0,7 do
                local sp=182
                if t%16<8 then sp=198 end
                spr(sp,56+5+10+(cos(-t*0.07+i*((2*math.pi)/7))*12),6*8-24-6+6+sin(-t*0.07+i*((2*math.pi)/7))*12,0)
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then TIC=allyturn; allyi=2; sc_t=t+1; plr.flame=3; plr.flamestack=plr.flamestack or 0; plr.flamestack=plr.flamestack+2; enemy_adapt('Flame'); plr.done19=true end
        t=t+1
end


function attack_anim_soulleech()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=160-30+(enemyi-1)*40,y=6*8-2*8-math.random(24),w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=160-30+(enemyi-1)*40,y=6*8-2*8-math.random(24),w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        pal(12,10); pal(13,9)
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        pal()
                        h.x=h.x-1
                        if h.x<56+5 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then 
        particles=nil
        plr.old_hp=plr.hp
        plr.old_maxhp=plr.maxhp
        plr.hp=enemies[enemyi].hp
        plr.maxhp=enemies[enemyi].maxhp
        enemies[enemyi].hp=plr.old_hp
        enemies[enemyi].maxhp=plr.old_maxhp
     TIC=allyturn; allyi=2; sc_t=t+1; enemy_adapt('SoulLeech') end
        t=t+1
end

function attack_anim_antispore()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%4==0 then
                particles=particles or {}
                ins(particles,{sp=166,x=56+5+math.random(0,23),y=6*8-8,w=1})
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,2,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then 
        particles=nil
        plr.spore=3; plr.done5=true
        plr.sporestack=plr.sporestack or 0
        plr.sporestack=plr.sporestack-2
     TIC=allyturn; allyi=2; sc_t=t+1; enemy_adapt('AntiSpore') end
        t=t+1
end

function attack_anim_flee()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        draw_header()
        
        if t-sc_t==cast[active] then 
        --shout('Player left the encounter.')
        TIC=flee_fadeout
        
        sc_t=t+1;
        end
        t=t+1
end

function attack_anim_reflect()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if (t-sc_t>12 and t-sc_t<=24) or (t-sc_t>36 and t-sc_t<48 and t%3==0) then
        pal(2,12); pal(3,12); pal(4,12)
        end
        spr(163,56+5,6*8-24-6,0,1,0,0,3,3)
        pal()
        
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=1
                plr.reflect=plr.reflect or 0
                plr.reflect=plr.reflect+1
                sc_t=t+1
                enemy_adapt('Reflect')
        end
        
        t=t+1
end

function attack_anim_summon()
        cls(args.bg)
        draw_bg()
        draw_board(args)
                
        draw_header()
        
        if t-sc_t==cast[active] then
                TIC=allyturn
                allyi=2
                
                if not plr_smnavail then
                        plr_smnavail={}
                        ins(plr_smnavail,{type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4,blink=60})
                        if mget(15,45)==65 then ins(plr_smnavail,{type='MunSlime',hp=15,maxhp=15,minatk=2,maxatk=5,blink=60}) end
                        if mget(15,39)==65 then ins(plr_smnavail,{type='Maneki',hp=25,maxhp=25,minatk=1,maxatk=4,blink=60}) end
                end
                
                if #plr_smnavail==0 then
                shout('But nobody came.')
                else
                local i=math.random(1,#plr_smnavail)
                for j=1,3 do
                        if not allies[j] then 
                        ins(allies, deepcopy(plr_smnavail[i]))
                        shout(fmt('Summoned %s!',plr_smnavail[i].type))
                        break
                        end
                        if allies[j].hp==0 then
                        local ded=allies[j]
                        rem(allies,j)
                        ins(allies, j, deepcopy(plr_smnavail[i]))
                        shout(fmt('Summoned %s!',plr_smnavail[i].type))
                        ins(allies,ded)
                        break
                        end
                end
                --rem(smnavail,i)
                end
                
                enemy_adapt('Summon')
                particles=nil
                sc_t=t+1
        end

        t=t+1       
end

-- from somebody online
        function deepcopy(orig)
            local orig_type = type(orig)
            local copy
            if orig_type == 'table' then
                copy = {}
                for orig_key, orig_value in next, orig, nil do
                    copy[deepcopy(orig_key)] = deepcopy(orig_value)
                end
                setmetatable(copy, deepcopy(getmetatable(orig)))
            else -- number, string, boolean, etc
                copy = orig
            end
            return copy
        end

function attack_anim_query()
        cls(args.bg)
        draw_bg()
        draw_board(args)        
        
        if t-sc_t<cast[active] then
                local cx,cy=56+5+12,6*8-24-6+12
                local hyp=math.sqrt(12^2+12^2)
                local spin=sin(t*0.2)*0.2
                textri(cx+cos(math.rad(-(45+90)+spin))*hyp,cy+sin(math.rad(-(45+90))+spin)*hyp,
                       cx+cos(math.rad(-(45))+spin)*hyp,cy+sin(math.rad(-(45))+spin)*hyp,
                       cx+cos(math.rad(-(45+90+90))+spin)*hyp,cy+sin(math.rad(-(45+90+90))+spin)*hyp,
                       2*8,4*8,2*8+3*8,4*8,2*8,4*8+3*8,false,0)
                textri(cx+cos(math.rad(-(45))+spin)*hyp,cy+sin(math.rad(-(45))+spin)*hyp,
                       cx+cos(math.rad(-(45+90+90+90))+spin)*hyp,cy+sin(math.rad(-(45+90+90+90))+spin)*hyp,
                                            cx+cos(math.rad(-(45+90+90))+spin)*hyp,cy+sin(math.rad(-(45+90+90))+spin)*hyp,
                                            2*8+3*8,4*8,2*8+3*8,4*8+3*8,2*8,4*8+3*8,false,0)
        end
        
        draw_header()
        
        if t-sc_t==cast[active] then
                query_result()
                sc_t=t+1
                enemy_adapt('Query')
                queryi=nil
        end
        
        t=t+1
end

function query_result()
        if enemies[enemyi].hp<enemies[enemyi].maxhp then
        shout(fmt('%s doesn\'t want to talk because you\'ve hurt them!',enemy_name(enemies[enemyi])))
        TIC=allyturn; allyi=2
        elseif enemies[enemyi].type=='ShyFairy' then
        shout('The ShyFairy stays mute!')
        TIC=allyturn; allyi=2
        elseif enemies[enemyi].type=='Mimic' then
        shout('The Mimic stays mute!')
        TIC=allyturn; allyi=2
        elseif enemies[enemyi].type=='Schwobly' then
        shout('Schwobly merely shouts at you!')
        TIC=allyturn; allyi=2
        else
        start_dialogue('query_'..enemies[enemyi].type..'_'..keywords[queryi])
        end
end

function any_enemy_done(n)
        for i,e in ipairs(enemies) do
        if e['done'..tostring(n)] then return true end
        end
        return false
end

function enemy_anim_smolheal()
        cls(args.bg)
        draw_bg()
        draw_board(args)

        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=160-12-30+(turni-1)*40+math.random(24)+5,y=6*8-2*8,w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=160-12-30+(turni-1)*40+math.random(24)+5,y=6*8-2*8,w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn

        local dmg=-enemy_spell_range('SmolHeal')*3
        if not rowguess and active=='SmolHeal' and not any_enemy_done(15) then 
        enemies[turni].done15=true;
        dmg=new*plrspells['SmolHeal'].mult
        end
        
        enemydmg(dmg,turni)
        
        if not rowguess and active=='SmolHeal' and not any_enemy_done(7) then enemies[turni].done7=true; turni=1; 
        else turni=turni+1 end
        
        particles=nil
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_medheal()
        cls(args.bg)
        draw_bg()
        draw_board(args)

        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=160-12-30+(turni-1)*40+math.random(24)+5,y=6*8-2*8,w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=160-12-30+(turni-1)*40+math.random(24)+5,y=6*8-2*8,w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn

        local dmg=-enemy_spell_range('MedHeal')*3
        if not rowguess and active=='MedHeal' and not any_enemy_done(24) then 
        enemies[turni].done24=true;
        dmg=new*plrspells['MedHeal'].mult
        end
        
        enemydmg(dmg,turni)
        
        if not rowguess and active=='MedHeal' and not any_enemy_done(25) then enemies[turni].done25=true; turni=1; 
        else turni=turni+1 end
        
        particles=nil
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_taunt()
        cls(args.bg)
        draw_bg()
        draw_board(args)

        spr(167,56+5,6*8-24-8+sin(t*0.1)*6,1,1,1,0,3,3)

        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        shout('You have Taunt for 3 turns!')
        TIC=enemyturn
        plr.taunt=3; plr.done3=true
        --enemies[turni].done3=true; 
        if not rowguess and active=='Taunt' and not any_enemy_done(3) then enemies[turni].done3=true; turni=1; 
        else turni=turni+1 end
        
        player_adapt('Taunt')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_ice()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if (t-sc_t>12 and t-sc_t<=24) or (t-sc_t>36 and t-sc_t<48 and t%3==0) then
        pal(8,12); pal(9,12); pal(10,12)
        end
        spr(119,56+5,6*8-24-6,0,1,0,0,3,3)
        pal()

        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn
        plr.ice=3; plr.done4=true
        plr.icestack=plr.icestack or 0
        plr.icestack=plr.icestack+2
        plr.flamestack=plr.flamestack or 0
        shout(fmt('Player cooldowns increased by 2 for 3 turns! (total %s)',tolabel(plr.icestack-plr.flamestack)))
        --enemies[turni].done4=true; 
        if not rowguess and active=='Ice' and not any_enemy_done(4) then enemies[turni].done4=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('Ice')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_flame()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        for i=0,7 do
                local sp=182
                if t%16<8 then sp=198 end
                spr(sp,160-30+(turni-1)*40+10+(cos(-t*0.07+i*((2*math.pi)/7))*12),6*8-24-6+6+sin(-t*0.07+i*((2*math.pi)/7))*12,0)
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn
        enemies[turni].flame=3; 
        enemies[turni].flamestack=enemies[turni].flamestack or 0
        enemies[turni].flamestack=enemies[turni].flamestack+2
        enemies[turni].icestack=enemies[turni].icestack or 0
        enemies[turni].done19=true
        shout(fmt('%s\'s cooldowns decreased by 2 for 3 turns! (total %s)',enemy_name(enemies[turni]),tolabel(enemies[turni].icestack-enemies[turni].flamestack)))
        --enemies[turni].done4=true; 
        if not rowguess and active=='Flame' and not any_enemy_done(20) then enemies[turni].done20=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('Flame')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_mine()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        local r=(t*0.07)%4
        spr(138,56+5,6*8-24-6,0,1,0,4-r,3,3)
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn
        plr.force=enemies[turni].spells
        shout('Forced the use of an unseen spell!')
        --enemies[turni].done4=true; 
        if not rowguess and active=='Mine' and not any_enemy_done(12) then enemies[turni].done12=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('Mine')
        sc_t=t+1;
        end
        t=t+1
end


function enemy_anim_leech()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=56+5,y=6*8-2*8-math.random(24),w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=56+5,y=6*8-2*8-math.random(24),w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        h.x=h.x+1
                        if h.x>160-30+(turni-1)*40+12 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        particles=nil
        TIC=enemyturn

        local sq=enemy_spell_range('Leech')

        if not rowguess and active=='Leech' and not any_enemy_done(21) then enemies[turni].done21=true; plrdmg(new*2,self); enemydmg(-new*2,turni)
        else plrdmg(sq*2,self); enemydmg(-sq*2,turni); end
        --enemies[turni].done4=true; 

        if not rowguess and active=='Leech' and not any_enemy_done(11) then enemies[turni].done11=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('Leech')
        sc_t=t+1;
        end
        t=t+1
end


function enemy_anim_antipsn()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        pal(7,1); pal(6,2)
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=176,x=160-30+(turni-1)*40+math.random(0,23),y=6*8-6-1,w=1})
                elseif size==2 then
                        ins(particles,{sp=177,x=160-30+(turni-1)*40+math.random(0,23),y=6*8-6-1,w=1})
                end
        end
        
        spr(192,160-30+(turni-1)*40,6*8-4-12+4+2,0,1,0,0,3,1)
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        pal()
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then
        particles=nil 
        TIC=enemyturn
        if not enemies[turni].poison then shout(fmt('The AntiPsn fizzled: %s not poisoned!',enemy_name(enemies[turni])))
        else
        
        local psncount=enemy_spell_range('AntiPsn')
        if not rowguess and active=='AntiPsn' and not any_enemy_done(10) then enemies[turni].done10=true; psncount=new end
        if enemies[turni].type=='Schwobly' then psncount=new end
        shout(fmt('%s\'s poison damage reduced by %d! (now %d)',enemy_name(enemies[turni]),psncount,enemies[turni].poisonstack-psncount))
        enemies[turni].poisonstack=enemies[turni].poisonstack-psncount
        end
        
        if not rowguess and active=='AntiPsn' and not any_enemy_done(8) then enemies[turni].done8=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('AntiPsn')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_meteor()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles= particles or {}
                local size=math.random(1,2)
                if size==1 then
                        ins(particles,{sp=256,w=4,x=56+5+60-math.random(0,24),y=-4*8})
                elseif size==2 then
                        ins(particles,{sp=260,w=2,x=56+5+60-math.random(0,24),y=-2*8})              
                end
        end
        if particles then
        for i=#particles,1,-1 do
                local m=particles[i]
                spr(m.sp,m.x,m.y,0,1,1,0,m.w,m.w)
                m.x=m.x-1; m.y=m.y+1
                if m.y>6*8-m.w*8 then
                        rem(particles,i)
                end
        end
        end
        
        draw_header()

        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn
        local dmg=enemy_spell_range('Meteor')*3
        
        if not rowguess and active=='Meteor' and not any_enemy_done(16) then
        enemies[turni].done16=true
        dmg=new*plrspells[active].mult
        end
        plrdmg(dmg,self)

        if not rowguess and active=='Meteor' and not any_enemy_done(14) then enemies[turni].done14=true; turni=1 
        else turni=turni+1 end

        particles=nil
        sc_t=t+1
        end
        t=t+1
end

function enemy_anim_lightning()
        cls(args.bg)
        draw_bg()
        draw_board(args)

        if t%8==0 then
                if not lw then lw=0; rect(0,0,240,6*8,12) end
                if lw<4 then lw=lw+1 end
        end
        if t%8<3 then
                --for i,e in ipairs(enemies) do
                --if e.hp>0 or (e.t and e.t>0) then
                spr(262,56+5,0,0,1,1,0,3,lw)
                --end
                --end
        end

        draw_header()

        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn

        local dmg=enemy_spell_range('Lightning')*1.5
        if not rowguess and active=='Lightning' and not any_enemy_done(17) then
        enemies[turni].done17=true
        dmg=new*plrspells[active].mult
        end
        plrdmg(dmg,self)

        if not rowguess and active=='Lightning' and not any_enemy_done(13) then enemies[turni].done13=true; turni=1 
        else turni=turni+1 end

        lw=nil
        sc_t=t+1
        end
        t=t+1
end

function enemy_anim_spore()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%4==0 then
                particles=particles or {}
                ins(particles,{sp=166,x=56+5+math.random(0,23),y=8,w=1})
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y+1
                        if h.y>6*8-8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        particles=nil
        TIC=enemyturn
        plr.spore=3; plr.done5=true
        plr.sporestack=plr.sporestack or 0
        plr.sporestack=plr.sporestack+2 
        shout(fmt('Fill-in ranges decreased by 2 for 3 turns! (total %s)',tolabel(-plr.sporestack)))
        --enemies[turni].done4=true; 
        if not rowguess and active=='Spore' and not any_enemy_done(5) then enemies[turni].done5=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('Spore')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_soulleech()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=265,x=56+5,y=6*8-2*8-math.random(24),w=2})
                elseif size==2 then
                        ins(particles,{sp=267,x=56+5,y=6*8-2*8-math.random(24),w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        pal(12,10); pal(13,9)
                        spr(h.sp,h.x,h.y,0,1,1,0,h.w,h.w)
                        pal()
                        h.x=h.x+1
                        if h.x>160-30+(turni-1)*40+12 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        particles=nil
        TIC=enemyturn
        plr.old_hp=plr.hp
        plr.old_maxhp=plr.maxhp
        plr.hp=enemies[turni].hp
        plr.maxhp=enemies[turni].maxhp
        enemies[turni].hp=plr.old_hp
        enemies[turni].maxhp=plr.old_maxhp
        shout(fmt('Player\'s and %s\'s hit points were swapped!',enemy_name(enemies[turni])))

        if not rowguess and active=='SoulLeech' and not any_enemy_done(17) then enemies[turni].done17=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('SoulLeech')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_antispore()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%4==0 then
                particles=particles or {}
                ins(particles,{sp=166,x=160-30+(turni-1)*40+math.random(0,23),y=6*8-8,w=1})
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,1,2,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then
        particles=nil
        TIC=enemyturn
        enemies[turni].spore=3
        enemies[turni].sporestack=enemies[turni].sporestack or 0
        enemies[turni].sporestack=enemies[turni].sporestack-2
        enemies[turni].done5=true
        shout(fmt('%s\'s fill-in ranges increased by 2 for 3 turns! (total %s)',enemy_name(enemies[turni]),tolabel(-enemies[turni].sporestack)))

        if not rowguess and active=='AntiSpore' and not any_enemy_done(18) then enemies[turni].done18=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('AntiSpore')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_poison()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
                if t%8==0 then
                particles=particles or {}
                local size= math.random(1,2)
                if size==1 then
                        ins(particles,{sp=176,x=56+5+math.random(0,23),y=6*8-6-1,w=1})
                elseif size==2 then
                        ins(particles,{sp=177,x=56+5+math.random(0,23),y=6*8-6-1,w=1})
                end
        end
        
        spr(192,56+5,6*8-4-12+4+2,0,1,0,0,3,1)
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end

        draw_header()
        
        if t-sc_t==cast[enemyatk] then
        particles=nil 
        local psndmg=enemy_spell_range('Poison')
        
        if not rowguess and active=='Poison' and not any_enemy_done(9) then enemies[turni].done9=true; psndmg=new end
        if not plr.poison then shout(fmt('%d poison damage for 4 turns!',psndmg))
        else shout(fmt('Poison damage stacked by %d! (now %d)',psndmg,plr.poisonstack+psndmg)); shout('You\'re poisoned for 4 more turns!') end
        TIC=enemyturn
        plr.poison=4; plr.done6=true
        plr.poisonstack=plr.poisonstack or 0
        plr.poisonstack=plr.poisonstack+psndmg
        --enemies[turni].done4=true; 
        if not rowguess and active=='Poison' and not any_enemy_done(6) then enemies[turni].done6=true; turni=1 
        else turni=turni+1 end
        
        player_adapt('Poison')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_flee()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        draw_header()
        
        if t-sc_t==cast[enemyatk] then 
        TIC=enemyturn
        shout(fmt('%s left the encounter.',enemy_name(enemies[turni])))
        rem(enemies,turni)
        if #enemies==0 then sc_t=t+1; TIC=flee_fadeout end
        
        --if not rowguess and active=='Flee' then turni=1 
        --else turni=turni+1 end
        --turni=turni+1
        
        player_adapt('Flee')
        sc_t=t+1;
        end
        t=t+1
end

function enemy_anim_reflect()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if (t-sc_t>12 and t-sc_t<=24) or (t-sc_t>36 and t-sc_t<48 and t%3==0) then
        pal(2,12); pal(3,12); pal(4,12)
        end
        spr(163,160-30+(turni-1)*40,6*8-24-6,0,1,1,0,3,3)
        pal()

        draw_header()
        
        if t-sc_t==cast[enemyatk] then
                TIC=enemyturn
                if not enemies[turni].reflect then shout(fmt('%s reflects damage once!',enemy_name(enemies[turni])))
                else shout(fmt('%s reflects damage %d times!',enemy_name(enemies[turni]),enemies[turni].reflect+1)) end
                enemies[turni].reflect=enemies[turni].reflect or 0
                enemies[turni].reflect=enemies[turni].reflect+1
                sc_t=t+1
                player_adapt('Reflect')
                if not rowguess and active=='Reflect' and not any_enemy_done(23) then enemies[turni].done23=true; turni=1 
                else turni=turni+1 end 
        end
        
        t=t+1
end

function enemy_anim_buff()
        cls(args.bg)
        draw_bg()
        draw_board(args)
        
        if t%8==0 then
                particles=particles or {}
                local colour= math.random(1,2)
                if colour==1 then
                        ins(particles,{sp=297,x=160-30-10+(turni-1)*40+math.random(24)+5,y=6*8-2*8,w=1})
                elseif colour==2 then
                        ins(particles,{sp=298,x=160-30-10+(turni-1)*40+math.random(24)+5,y=6*8-2*8,w=1})
                end
        end
        
        if particles then
                for i=#particles,1,-1 do
                        local h=particles[i]
                        spr(h.sp,h.x,h.y,0,1,0,0,h.w,h.w)
                        h.y=h.y-1
                        if h.y<8 then rem(particles,i) end
                end
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then
                TIC=enemyturn
                enemies[turni].buff=3
                enemies[turni].done2=true
                --enemies[turni].done=true
                
                -- if this is from backfire, allow turn normally
                if not rowguess and active=='Buff' and not any_enemy_done(22) then enemies[turni].done22=true; turni=1 
                else turni=turni+1 end 
                player_adapt('Buff')
                particles=nil
                sc_t=t+1
        end

        t=t+1       
end

function enemy_anim_query()
        cls(args.bg)
        draw_bg()
        draw_board(args)        
        
        if t-sc_t<cast[enemyatk] then
                local cx,cy=160-30+(turni-1)*40+12,6*8-24-6+12
                local hyp=math.sqrt(12^2+12^2)
                local spin=sin(t*0.2)*0.2
                textri(cx+cos(math.rad(-(45+90)+spin))*hyp,cy+sin(math.rad(-(45+90))+spin)*hyp,
                       cx+cos(math.rad(-(45))+spin)*hyp,cy+sin(math.rad(-(45))+spin)*hyp,
                       cx+cos(math.rad(-(45+90+90))+spin)*hyp,cy+sin(math.rad(-(45+90+90))+spin)*hyp,
                       2*8,4*8,2*8+3*8,4*8,2*8,4*8+3*8,false,0)
                textri(cx+cos(math.rad(-(45))+spin)*hyp,cy+sin(math.rad(-(45))+spin)*hyp,
                       cx+cos(math.rad(-(45+90+90+90))+spin)*hyp,cy+sin(math.rad(-(45+90+90+90))+spin)*hyp,
                                            cx+cos(math.rad(-(45+90+90))+spin)*hyp,cy+sin(math.rad(-(45+90+90))+spin)*hyp,
                                            2*8+3*8,4*8,2*8+3*8,4*8+3*8,2*8,4*8+3*8,false,0)
        end
        
        draw_header()
        
        if t-sc_t==cast[enemyatk] then--or ((active=='Attack' or picross[active]) and not rowguess and t-sc_t==90) then
                if enemies[turni].type=='MercRat' then
                        if enemies[turni].phase==1 then
                                --ins(keywords,'[you]')
                                start_dialogue('sc_2_rat_phase1')
                        elseif enemies[turni].phase==2 then
                                --ins(keywords,'[Picross magic]')
                                start_dialogue('sc_2_rat_phase2')
                        elseif enemies[turni].phase==3 then
                                --ins(keywords,'[quest]')
                                start_dialogue('sc_2_rat_phase3')
                        end
                elseif enemies[turni].type=='Mimic' then
                        start_dialogue('query_Mimic')
                end
                --TIC=enemyturn
                --turni=turni+1
                sc_t=t+1
                player_adapt('Query')
        end
        
        t=t+1
end

function enemy_anim_summon()
        cls(args.bg)
        draw_bg()
        draw_board(args)
                
        draw_header()
        
        if t-sc_t==cast[enemyatk] then
                TIC=enemyturn
                smnavail=smnavail or {
                {type='Sheebly',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Leech','SoulLeech',['Leech']={maxcool=1,cooldown=0},['SoulLeech']={maxcool=4,cooldown=0}},blink=60,ai=function() 

                        if enemies[turni].hp<=enemies[turni].maxhp/3 and plr.hp>enemies[turni].hp then
                                if enemy_cast('SoulLeech') then
                                return
                                end
                        end
        
                        if enemy_cast('Leech') then
                        else enemy_attack()
                        end
                end},
                {type='Shoobly',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Poison','AntiPsn',['Poison']={maxcool=3,cooldown=0},['AntiPsn']={maxcool=2,cooldown=0}},blink=60,ai=function()

                        if enemies[turni].poisonstack and enemies[turni].poisonstack>=8 then
                                if enemy_cast('AntiPsn') then   
                                return
                                end
                        end
        
                        if enemy_cast('Poison') then        
                        else enemy_attack()
                        end
                end},
                {type='Shaably',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Spore','AntiSpore',['Spore']={maxcool=3,cooldown=0},['AntiSpore']={maxcool=3,cooldown=0}},blink=60,ai=function()

                        if enemies[turni].sporestack and enemies[turni].sporestack>=4 then
                                if enemy_cast('AntiSpore') then
                                return
                                end
                        end
        
                        if enemy_cast('Spore') then
                        else enemy_attack()
                        end
                end}                
                }
                if #smnavail==0 then
                shout('But nobody came.')
                else
                local i=math.random(1,#smnavail)
                for j=1,3 do
                        if not enemies[j] then 
                        ins(enemies, smnavail[i])
                        break
                        end
                        if enemies[j].hp==0 then
                        local ded=enemies[j]
                        rem(enemies,j)
                        ins(enemies, j, smnavail[i])
                        ins(enemies,ded)
                        break
                        end
                end
                shout(fmt('Summoned %s!',smnavail[i].type))
                rem(smnavail,i)
                end
                
                -- if this is from backfire, allow turn normally
                if not rowguess and active=='Summon' and not any_enemy_done(26) then enemies[turni].done26=true; turni=1 
                else turni=turni+1 end 
                player_adapt('Summon')
                particles=nil
                sc_t=t+1
        end

        t=t+1       
end

function player_adapt(sp)
        if not find(plrspells,sp) then
        shout(fmt('Learned %s!',sp))
        ins(plrspells,sp)
        plrspells[sp]=register_spell(sp)
        end
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

function picross_unlock()
        cls(2)
        if tri_a==nil then
        tri_a=120-2*13-6
        tri_b=68
        tri_w=13*5-2+1
        end
        
        textri(tri_a,tri_b,tri_a+tri_w,tri_b,tri_a,tri_b+tri_w,8*mx+0,8*my+0,8*mx+8*mw,8*my+0,8*mx+0,8*my+8*mh,true)
        textri(tri_a,tri_b+tri_w,tri_a+tri_w,tri_b,tri_a+tri_w,tri_b+tri_w,8*mx+0,8*my+8*mh,8*mx+8*mw,8*my+0,8*mx+8*mw,8*my+8*mh,true)
        
        tri_a=tri_a+(120-1*13-6-tri_a)*0.1
        tri_w=tri_w+(13*10-2-tri_w)*0.1
        tri_b=tri_b+(4-tri_b)*0.1
        
        if t-sc_t>=60 then
                for i=1,#picross[fmt('%d:%d',mx,my)] do
                        print(sub(picross[fmt('%d:%d',mx,my)],i,i),8+i*6,136/2+sin(t*0.2+i)*4,t*0.2+i)
                end
        end
        if t-sc_t==240 then
                TIC=allyturn
                allyi=2
                sc_t=t+1
                ins(plrpicross,picross[fmt('%d:%d',mx,my)])
                if active~='Buff' and active~='SmolHeal' and active~='Taunt' and active~='Ice' and active~='Spore' and active~='Poison' and active~='AntiPsn' and active~='SoulLeech' and active~='AntiSpore' then sfx(8,12*6,6,3) end
                -- fresh Picross board
                clear_picross()
                if mw==5 then
                mx=mx+5
                if mx>=20 then mx=0 end
                end
                if mw==6 then
                mx=mx+6
                if mx>=32 then mx=20 end
                end
                if active=='Buff' then plr.buff=3; plr.done2=true end
                if active=='Taunt' then enemies[enemyi].taunt=3; enemies[enemyi].done3=true end
                if active=='Ice' then enemies[enemyi].ice=3; enemies[enemyi].icestack=enemies[enemyi].icestack or 0; enemies[enemyi].icestack=enemies[enemyi].icestack+2; enemies[enemyi].flamestack=enemies[enemyi].flamestack or 0; enemies[enemyi].done4=true end
                if active=='Spore' then enemies[enemyi].spore=3; enemies[enemyi].sporestack=enemies[enemyi].sporestack or 0; enemies[enemyi].sporestack=enemies[enemyi].sporestack+2; enemies[enemyi].done5=true end
                if active=='Poison' then enemies[enemyi].poison=4; enemies[enemyi].poisonstack=enemies[enemyi].poisonstack or 0; enemies[enemyi].poisonstack=enemies[enemyi].poisonstack+new; enemies[enemyi].done6=true end
                if active=='AntiPsn' then if plr.poison then plr.poisonstack=plr.poisonstack-new end end
                if active=='Leech' then plrdmg(-new*2); enemydmg(new*2) end
                if active=='SoulLeech' then plr.old_hp=plr.hp; plr.old_maxhp=plr.maxhp; plr.hp=enemies[enemyi].hp; plr.maxhp=enemies[enemyi].maxhp; enemies[enemyi].hp=plr.old_hp; enemies[enemyi].maxhp=plr.old_maxhp end
            if active=='AntiSpore' then plr.spore=3; plr.done5=true; plr.sporestack=plr.sporestack or 0; plr.sporestack=plr.sporestack-2 end
            if active=='Flame' then plr.flame=3; plr.done19=true; plr.flamestack=plr.flamestack or 0; plr.flamestack=plr.flamestack+2; plr.icestack=plr.icestack or 0 end
                if active=='Mine' then enemies[enemyi].force=plrspells end
                if active=='Reflect' then plr.reflect=3 end 
                if active=='Flee' then sc_t=t+1; TIC=flee_fadeout end
                if active=='Query' then sc_t=t+1; TIC=turn_query end
                if active=='Lightning' then for i,e in ipairs(enemies) do
                enemydmg(new*plrspells[active].mult,i)
                end end
                if active=='Meteor' then 
                enemydmg(new*plrspells[active].mult)
                end
                if active=='SmolHeal' or active=='MedHeal' then
                plrdmg(new*plrspells[active].mult)
                end
                if cur_encounter==encounters['56:43'] then
                        cls(args.bg)
                        draw_board(args)
                        draw_header()
                end
        end
        
        t=t+1
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

function clear_picross()
        for sqx=0,mw-1 do
        for sqy=0,mh-1 do
                mset(239-mw*2+1+sqx,135-mh+1+sqy,0)
                mset(239-mw+1+sqx,135-mh*2+1+sqy,0)
                mset(239-mw+1+sqx,135-mh+1+sqy,0)
        end
        end
        state=nil
end

picross={['0:0']='CatHead',
                                 ['5:0']='Rocket',
                                    ['10:0']='Piranha',
                                    ['15:0']='OwlEye',
                                    
                                    ['20:0']='Humanoid',
                                    ['26:0']='ComfyBed',
                                    
                                    ['44:0']='PalmTree',
                                
         ['CatHead']={w=5,h=5},
         ['Rocket']={w=5,h=5},
         ['Piranha']={w=5,h=5},
         ['OwlEye']={w=5,h=5},
         
         ['Humanoid']={w=6,h=6},
         ['ComfyBed']={w=6,h=6},

         ['PalmTree']={w=7,h=7},
         
         ['Upgrade']={},
}
picno={
    ['CatHead']=1,
    ['Rocket']=2,
    ['Piranha']=3,
    ['OwlEye']=4,
    ['Humanoid']=5,
    ['ComfyBed']=6,
    ['Upgrade']=7,
}
function rev_picno(i)
    for k,v in pairs(picno) do
        if v==i then return k end
    end
end
plrpicross={}
mx=0; my=0
mw=picross[picross[fmt('%d:%d',mx,my)]].w
mh=picross[picross[fmt('%d:%d',mx,my)]].h
grid=12

function AABB(x1,y1,w1,h1, x2,y2,w2,h2)
    return (x1 < x2 + w2 and
            x1 + w1 > x2 and
            y1 < y2 + h2 and
            y1 + h1 > y2)
end

function all(type,comp,sqx,sqy)
        if comp=='row' then 
                for sqxx=0,mw-1 do
                        if mget(239-mw+1+sqxx,135-mh+1+sqy)~=type then
                                return false
                        end
                end
                return true
        end
        if comp=='column' then 
                for sqyy=0,mh-1 do
                        if mget(239-mw+1+sqx,135-mh+1+sqyy)~=type then
                                return false
                        end
                end
                return true
        end
end

function only1(type,args,sqx,sqy)
        if args.select=='row' then 
                local c=0
                local out={}
                for sqxx=0,args.mw-1 do
                        if mget(args.bx+sqxx,args.by+sqy)==0 and mget(args.ax+sqxx,args.ay+sqy)==type then
                                c=c+1
                                out.x=sqxx; out.y=sqy
                        end
                end
                if c==1 then return out end
        elseif args.select=='column' then 
                local c=0
                local out={}
                for sqyy=0,args.mh-1 do
                        if mget(args.bx+sqx,args.by+sqyy)==0 and mget(args.ax+sqx,args.ay+sqyy)==type then
                                c=c+1
                                out.x=sqx; out.y=sqyy
                        end
                end
                if c==1 then return out end
        end
end

-- palette swapping by BORB
        function pal(c0,c1)
          if(c0==nil and c1==nil)then if TIC~=flee_fadeout then for i=0,15 do poke4(0x3FF0*2+i,i) end else for i=0,15 do poke4(0x3FF0*2+i,fade_palette[i]) end end
          else poke4(0x3FF0*2+c0,c1) end
        end

function draw_board(args)
        rect(120-2*13-6+1,68+1,(args.grid+1)*args.mw-2,(args.grid+1)*args.mh-2,14)

        for sqx=0,args.mw-1 do
        for sqy=0,args.mh-1 do
                rect(120-2*13-6+sqx*(args.grid+1)+1,68+sqy*(args.grid+1)+1,args.grid,args.grid,13)
                if mget(args.ax+sqx,args.ay+sqy)==16 then
                rect(120-2*13-6+sqx*(args.grid+1),68+sqy*(args.grid+1),args.grid,args.grid,0)
                else
                rect(120-2*13-6+sqx*(args.grid+1),68+sqy*(args.grid+1),args.grid,args.grid,12)
                end
                if mget(args.cx+sqx,args.cy+sqy)==32 then
                        local xx=32
                        local offset=0
                        if args.grid==10 then offset=-1 end
                        if args.grid==8 then offset=-2 end
                        if args.grid==7 then xx=48; offset=-3 end
                        if args.grid==6 then xx=64; offset=-3 end
                        if args.grid==5 then xx=48; offset=-4 end
                        spr(xx,offset+120-2*13-6+sqx*(args.grid+1)+2,offset+68+sqy*(args.grid+1)+2,12)
                end
        end
        end
        
        hilight_board(args)

        draw_num(args)
end

function hilight_board(args)
        if args.state=='rowselect' or args.state=='firstclick' then
                if args.state=='rowselect' then
                if args.select=='row' then
                        rectb(120-2*13-6-1,68-1+args.firsttile.y*(args.grid+1),(args.grid+1)*args.mw+1,args.grid+2,t*FLASH_SPD)
                end
                if args.select=='column' then
                        rectb(120-2*13-6-1+args.firsttile.x*(args.grid+1),68-1,args.grid+2,(args.grid+1)*args.mh+1,t*FLASH_SPD)
                end
                elseif args.state=='firstclick' then
                        rectb(120-2*13-6-1+args.firsttile.x*(args.grid+1),68-1+args.firsttile.y*(args.grid+1),args.grid+2,args.grid+2,t*FLASH_SPD)
                end
        end
        if args.who.buff then
                local nu,buffd=count_new(nil,args)
                if buffd then describe(fmt('You\'re Buff\'d! %d total squares selected.',nu)) end
        end
end

function draw_num(args)
        local lx,ly=0,0
        for ly=0,args.mh-1 do
        local tabs={}
        local combo=0
        lx=0
        while lx<=args.mw-1 do
                local c=mget(args.mx+lx,args.my+ly)
                if c==16 then combo=combo+1 end
                if (c==0 or lx==args.mw-1) and combo>0 then
                        ins(tabs,combo)
                        combo=0
                end
                lx=lx+1
        end
        local num=tostring(tabs[1])
        if num=='nil' then num='0' end
        for tb=2,#tabs do
                num=num..fmt(' %d',tabs[tb])
        end
        local offset=0
        if args.grid==10 then offset=-1 end
        if args.grid==8 then offset=-2 end
        if args.grid==7 then offset=-3 end
        if args.grid==6 then offset=-4 end
        if args.grid==5 then offset=-4 end
        print(num,120-2*13-6-1-#num*4,offset+68+4+ly*(args.grid+1),12,true,1,true)
        end
    
        local lx,ly=0,0
        for lx=0,args.mw-1 do
        local tabs={}
        local combo=0
        ly=0
        while ly<=args.mh-1 do
                local c=mget(args.mx+lx,args.my+ly)
                if c==16 then combo=combo+1 end
                if (c==0 or ly==args.mh-1) and combo>0 then
                        ins(tabs,combo)
                        combo=0
                end
                ly=ly+1
        end
        local num=tostring(tabs[1])
        if num=='nil' then num='0' end
        for tb=2,#tabs do
                num=num..fmt('\n%d',tabs[tb])
        end
        local offset=0
        if args.grid==10 then offset=-1 end
        if args.grid==8 then offset=-2 end
        if args.grid==7 then offset=-3 end
        if args.grid==6 then offset=-4 end
        if args.grid==5 then offset=-4 end
        print(num,offset+120-2*13-6-1+6+lx*(args.grid+1),68-4-#num/2*6,12,true,1,true)
        end
end

function count_taunt(args)
        local record=10
        for sqx=0,args.mw-1 do
        local c=0
        for sqy=0,args.mh-1 do
        if mget(args.mx+sqx,args.my+sqy)==16 and mget(args.bx+sqx,args.by+sqy)==0 then c=c+1 end
        end
        if c>0 and c<record then record=c end
        end
        for sqy=0,args.mh-1 do
        local c=0
        for sqx=0,args.mw-1 do
        if mget(args.mx+sqx,args.my+sqy)==16 and mget(args.bx+sqx,args.by+sqy)==0 then c=c+1 end
        end
        if c>0 and c<record then record=c end
        end
        return record
end

function click_board(args)
        for sqx=0,args.mw-1 do
        for sqy=0,args.mh-1 do
                if AABB(args.mox,args.moy,1,1,120-2*13-6+sqx*(args.grid+1),68+sqy*(args.grid+1),args.grid,args.grid) then
                rectb(120-2*13-6-1+sqx*(args.grid+1),68-1+sqy*(args.grid+1),args.grid+2,args.grid+2,t*FLASH_SPD)
        end
        end
        end

        if args.left then
                if not args.leftheld then args.intent=nil end
                for sqx=0,args.mw-1 do
                for sqy=0,args.mh-1 do
                if AABB(args.mox,args.moy,1,1,120-2*13-6+sqx*(args.grid+1),68+sqy*(args.grid+1),args.grid,args.grid) and mget(args.cx+sqx,args.cy+sqy)==0 then
                        --if args.intent=='white' and mget(239-mw+1+sqx,135-mh*2+1+sqy)==32 then 
                        --sfx(8,12*6,6)
                        --mset(239-mw+1+sqx,135-mh*2+1+sqy,0)
                        --end
                        if args.state=='rowselect' then
                                if args.who.buff and (not args.intent or args.intent=='black') and only1(16,args,args.firsttile.x,sqy) and args.select=='column' and sqy==args.firsttile.y and sqx~=args.firsttile.x then args.intent='black'; args.select='row' end --trace('row') end
                                if args.who.buff and (not args.intent or args.intent=='black') and only1(16,args,sqx,args.firsttile.y) and args.select=='row' and sqx==args.firsttile.x and sqy~=args.firsttile.y then args.intent='black'; args.select='column' end --trace('column') end
                                if (args.select=='column' and sqx==args.firsttile.x)
                                or (args.select=='row'    and sqy==args.firsttile.y) then
                                     if (not args.intent or args.intent=='black') and mget(args.ax+sqx,args.ay+sqy)==0 then 
                                        
                                        if not args.who.taunt or (args.who.taunt and count_new(nil,args)<count_taunt(args)) then
                                        --if mget(239-mw+1+sqx,135-mh*2+1+sqy)==32 then mset(239-mw+1+sqx,135-mh*2+1+sqy,0) end
                                        mset(args.ax+sqx,args.ay+sqy,16) 
                                        sfx(4,12*3+6+count_new(nil,args),10,3)
                                        args.intent='black'
                                        else describe(fmt('Your Taunt only allows the minimum row, which is %d square(s)!',count_taunt(args))) end
                                        elseif (not args.intent or args.intent=='white') and mget(args.ax+sqx,args.ay+sqy)==16 then
                                                            if args.who.buff and only1(16,args,sqx,sqy) then
                                                            args.state=nil
                                                            end
                                             if mget(args.bx+sqx,args.by+sqy)==0 then
                                                            mset(args.ax+sqx,args.ay+sqy,0) 
                                                            args.intent='white'
                                                            local one= only1(16,args,sqx,sqy) 
                                                            if one then
                                                                    args.state='firstclick'
                                                                    args.firsttile.x=one.x; args.firsttile.y=one.y
                                                                    sfx(4,12*3+6+1,10,3)
                                                            else
                                                                    -- state is still rowselect
                                                                    --if (not plr.buff) and state~=nil then sfx(4,12*3+6+count_new(),10,2)
                                                                    --else 
                                                                    sfx(4,12*3+6+count_new(nil,args),10,3) 
                                                                    --end
                                                            --elseif all(0,select,sqx,sqy) then
                                                            --      state=nil
                                                            end
                                        end     end
                                end
                        elseif args.state=='firstclick' then
                                if sqx==args.firsttile.x and sqy==args.firsttile.y and mget(239-mw*2+1+sqx,135-mh+1+sqy)==0 then
                                        if not args.intent or args.intent=='white' then
                                        args.intent='white'
                                        mset(args.ax+sqx,args.ay+sqy,0)
                                        args.state=nil
                                        sfx(8,12*6,6,3)
                                        end
                                elseif sqx==args.firsttile.x or sqy==args.firsttile.y then
                                if (not args.intent or args.intent=='black') and mget(args.bx+sqx,args.by+sqy)==0 then
                                if not args.who.taunt or (args.who.taunt and count_new(nil,args)<count_taunt(args)) then
                                args.intent='black'
                                --if mget(239-mw+1+sqx,135-mh*2+1+sqy)==32 then mset(239-mw+1+sqx,135-mh*2+1+sqy,0) end
                                mset(args.ax+sqx,args.ay+sqy,16)
                                args.state='rowselect'
                                if sqx==args.firsttile.x then
                                args.select='column'
                                elseif sqy==args.firsttile.y then
                                args.select='row'
                                end
                                sfx(4,12*3+6+count_new(nil,args),10,3)
                                else describe(fmt('Your Taunt only allows the minimum row, which is %d square(s)!',count_taunt(args))) end
                                end
                                end
                        elseif args.state==nil and not args.intent and mget(args.bx+sqx,args.by+sqy)==0 then
                                args.firsttile={x=sqx,y=sqy}
                                args.intent='black'
                                --if mget(239-mw+1+sqx,135-mh*2+1+sqy)==32 then mset(239-mw+1+sqx,135-mh*2+1+sqy,0) end
                                mset(args.ax+sqx,args.ay+sqy,16)
                                args.state='firstclick'
                                sfx(4,12*3+6+1,10,3)
                                if args.who.buff then
                                        args.state='rowselect'
                                        local n1=count_new('column',args)
                                        local n2=count_new('row',args)
                                        if n1==1 and n2==1 then args.state='firstclick'
                                        elseif n2>=n1 then args.select='row' 
                                        else args.select='column' end
                                        sfx(4,12*3+6+count_new(nil,args),10,3)
                                end
                        end
    
                end
                end
                end
        end
        if args.right then
                if not args.rightheld then args.rintent=nil end
                for sqx=0,args.mw-1 do
                for sqy=0,args.mh-1 do
                if AABB(args.mox,args.moy,1,1,120-2*13-6+sqx*(args.grid+1),68+sqy*(args.grid+1),args.grid,args.grid) then
                        if mget(args.ax+sqx,args.ay+sqy)==0 then
                                --if mget(239-4+sqx,135-4+sqy)==16 then mset(239-4+sqx,135-4+sqy,0) end
                                if (not args.rintent or args.rintent=='X') and mget(args.cx+sqx,args.cy+sqy)==0 then
                                        sfx(5,'D-4',20,3)
                                        args.rintent='X'
                                        mset(args.cx+sqx,args.cy+sqy,32)
                                elseif (not args.rintent or args.rintent=='O') and mget(args.cx+sqx,args.cy+sqy)==32 then
                                        sfx(8,12*6,6,3)
                                        args.rintent='O'
                                        mset(args.cx+sqx,args.cy+sqy,0)
                                end
                        end
                end
                end
                end
        end
end

function draw_bg()
        --rect(0,0,240,6*8,0)
        map(area.x+0,17,30,6,0,0)
        
        --rect(56,6*8-24-6,24,24,1)
        --print('You',56+6,6*8-24-6+9,2,false,1,true)
        
        --for c=0,15 do pal(c,12) end
        --local psp=464
        --if plr.cast then psp=467 end
        --spr(psp,56+5+1,6*8-24-6,0,1,0,0,3,3)
        --spr(psp,56+5,6*8-24-6+1,0,1,0,0,3,3)
        --spr(psp,56+5-1,6*8-24-6,0,1,0,0,3,3)
        --spr(psp,56+5,6*8-24-6-1,0,1,0,0,3,3)
        --pal()

        if not (active=='Flee' and TIC==flee_fadeout) then
        --if (enemyatk=='default' and TIC==enemyturn and turni>1 and t-sc_t>=10 and t-sc_t<=10+12 and not plr.reflect) or (enemyatk=='Leech' and TIC==enemyturn and t-sc_t<=12 and not plr.reflect) or (not rowguess and TIC==enemyturn and turni==1 and sc_t and t-sc_t<=12 and (active=='Meteor' or active=='Lightning' or active=='Leech')) or (TIC==poisondmg and plr.poison and plr.poisonstack>0 and turni==1 and t-sc_t<=12) then
        if plr.blink then
        pal(3,12); pal(4,12); pal(13,12); pal(14,12); pal(15,12)
        plr.blink=plr.blink-1; if plr.blink==0 then plr.blink=nil end
        end
        if plr.cast and not cool then
        spr(467,56+5,6*8-24-6,0,1,0,0,3,3)
        plr.cast=plr.cast-1; if plr.cast==0 then plr.cast=nil end
        elseif not plr.cast and not cool then
        spr(464,56+5,6*8-24-6,0,1,0,0,3,3)
        elseif cool then
        local sp=464
        if t%8<4 then sp=467 end
        spr(sp,56+5,6*8-24-6,0,1,0,0,3,3)
        cool=cool-1; if cool==0 then cool=nil end
        end
        pal()
        end
        
        for i,a in ipairs(allies) do
        if a.hp>0 or (a.t and a.t>0) then
                a.anim=a.anim or 1
                local ax=56+5-(i-1)*30
                if a.nudge then ax=ax+sin(a.nudge/60*math.pi)*8; a.nudge=a.nudge-3; if a.nudge<=0 then a.nudge=nil end end
                if a.type=='AcroBat' then       
                        if a.blink then
                        pal(8,12); pal(9,12); pal(10,12)
                        a.blink=a.blink-1; if a.blink==0 then a.blink=nil end 
                        end
                        spr(320+(a.anim-1)*3,ax,6*8-24-6+sin(i*12+t*0.1)*3,0,1,1,0,3,3)
                        pal()
                        if t%8==0 then a.anim=a.anim+1 
                                if a.anim>2 then a.anim=1 end
                        end
                elseif a.type=='MunSlime' then
                        if a.blink then
                        pal(1,12); pal(5,12); pal(6,12); pal(7,12)
                        a.blink=a.blink-1; if a.blink==0 then a.blink=nil end 
                        end
                        spr(326+(a.anim-1)*3,ax,6*8-24-6,0,1,1,0,3,3)
                        pal()
                        if t%12==0 then a.anim=a.anim+1 
                                if a.anim>2 then a.anim=1 end
                        end
                elseif a.type=='Maneki' then
                        if a.blink then
                        pal(1,12); pal(2,12); pal(4,12); pal(5,12); pal(13,12); pal(14,12)
                        a.blink=a.blink-1; if a.blink==0 then a.blink=nil end 
                        end
                        spr(368+(a.anim-1)*3,ax,6*8-24-6,0,1,1,0,3,3)
                        pal()
                        if t%16==0 then a.anim=a.anim+1 
                                if a.anim>2 then a.anim=1 end
                        end
                end
        end
        end
        
        for i,e in ipairs(enemies) do
        if e.hp>0 or (e.t and e.t>0) or e.type=='Rival' or e.type=='Sheebly' or e.type=='Shoobly' or e.type=='Shaably' then
        e.anim=e.anim or 1
        local ex=160-30+(i-1)*40
        if e.type=='Schwobly' then ex=160-30-40+20 end
        if e.nudge then ex=ex-sin(e.nudge/60*math.pi)*8; e.nudge=e.nudge-3; if e.nudge<=0 then e.nudge=nil end end

        if e.type=='AcroBat' then       
        --if (TIC==enemyturn and t-sc_t<=12 and (active=='Attack' or picross[active] or active=='Meteor' or active=='Lightning' or active=='Leech' or plr.reflect) and turni==1 and rowguess and (enemyi==i or active=='Lightning')) or (TIC==poisondmg and turni-1==i and t-sc_t<=12 and e.poisonstack>0) then
        if e.blink then
        pal(8,12); pal(9,12); pal(10,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(320+(e.anim-1)*3,ex,6*8-24-6+sin(i*12+t*0.1)*3,0,1,0,0,3,3)
        pal()
        if t%8==0 then e.anim=e.anim+1 
                if e.anim>2 then e.anim=1 end
        end
        elseif e.type=='MunSlime' then
        if e.blink then
        pal(1,12); pal(5,12); pal(6,12); pal(7,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(326+(e.anim-1)*3,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        if t%12==0 then e.anim=e.anim+1 
                if e.anim>2 then e.anim=1 end
        end
        elseif e.type=='Maneki' then
        if e.blink then
        pal(1,12); pal(2,12); pal(4,12); pal(5,12); pal(13,12); pal(14,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(368+(e.anim-1)*3,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        if t%16==0 then e.anim=e.anim+1 
                if e.anim>2 then e.anim=1 end
        end
        elseif e.type=='Rival' then
        if e.blink then
        pal(3,12); pal(4,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(470,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        elseif e.type=='Sheebly' then
        pal(1,8); pal(2,9);
        if e.blink then
        pal(1,12); pal(2,12); pal(13,12); pal(14,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(374,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        elseif e.type=='Shoobly' then
        pal(1,3); pal(2,4);
        if e.blink then
        pal(1,12); pal(2,12); pal(13,12); pal(14,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(374,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        elseif e.type=='Shaably' then
        if e.blink then
        pal(1,12); pal(2,12); pal(13,12); pal(14,12)
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(374,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        elseif e.type=='Hidaldi' then
        if e.blink then
        pal(0,12); pal(13,12); pal(14,12);
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(416,ex,6*8-24-6,1,1,0,0,3,3)
        pal()
        elseif e.type=='Burr' then
        if e.blink then
        pal(1,12); pal(3,12); pal(13,12); pal(14,12); pal(15,12); 
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(422,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        elseif e.type=='ShyFairy' then
        if e.blink then
        pal(1,12); pal(4,12); pal(10,12); pal(13,12); pal(14,12);
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(462+(e.anim-1)*(494-462),ex,6*8-24-6+2+sin(i*12+t*0.1)*3,0,1,0,0,2,2)
        if t%8==0 then e.anim=e.anim+1 
                if e.anim>2 then e.anim=1 end
        end
        pal()
        elseif e.type=='Mimic' then
        if e.blink then
        pal(0,12); pal(2,12); pal(14,12);
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        local sp=90
        local flip=0
        if e.anim==2 then sp=93 end
        if e.anim==4 then sp=93; flip=1 end 
        spr(sp,ex,6*8-24-6,1,1,flip,0,3,3)
        if t%16==0 then e.anim=e.anim+1 
                if e.anim>4 then e.anim=1 end
        end
        pal()
        elseif e.type=='Merchant' then
        spr(208,ex,6*8-24-6,0,1,0,0,6,3)
        elseif e.type=='MercRat' then
        if e.blink then
        pal(1,12); pal(2,12); pal(4,12); pal(14,12); pal(15,12);
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(69,ex,6*8-24-6,0,1,0,0,3,3)
        pal()
        elseif e.type=='Schwobly' then
        if e.blink then
        pal(5,12); pal(6,12); pal(7,12); pal(13,12); pal(14,12); pal(15,12);
        e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
        end
        spr(8,ex,4,2,1,0,0,8,5)
        pal()
        else
        rect(ex,6*8-24-6,24,24,1)
        print('Enemy',ex+3,6*8-24-6+9,2,false,1,true)
        end
        if e.t then e.t=e.t-1; if e.t==0 then e.t=nil end end
        end
        end
        
        if TIC==turn or TIC==bossintro or TIC==turn_boss then
        for i=#allies,2,-1 do
        local a=allies[i]
        if a.hp>0 or (a.t and a.t>0) then
        print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30-1,9,1,false,1,true)
        print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30,9-1,1,false,1,true)
        print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30+1,9,1,false,1,true)
        print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30,9+1,1,false,1,true)
        print(fmt('%.1f/%.1f',a.hp,a.maxhp),160-13-20+(i-1)*40,9,12,false,1,true)
        end
        end
        local tc=12
        if plr.hp<=plr.maxhp/3 then tc=2 end
        print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5-1,9,1,false,1,true)
        print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5,9-1,1,false,1,true)
        print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5+1,9,1,false,1,true)
        print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5,9+1,1,false,1,true)
        print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5,9,tc,false,1,true)
        for i,e in ipairs(enemies) do
        if e.hp>0 or (e.t and e.t>0) then
        print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40-1,9,1,false,1,true)
        print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40,9-1,1,false,1,true)
        print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40+1,9,1,false,1,true)
        print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40,9+1,1,false,1,true)
        print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40,9,12,false,1,true)
        end
        end
        end
        
        line(0,6*8,240,6*8,1)
end

--enemy={hp=30,maxhp=30}
plr={hp=30,maxhp=30,origmaxhp=30,type='Player',minatk=1,maxatk=5,icestack=0,flamestack=0,poisonstack=0,sporestack=0}--reflect=2,
allies={plr}

function enemydmg(n,i)
        --if (enemyatk~='Leech' and active~='Leech') then
        i=i or enemyi 
        --end
        --if turni and (enemyatk=='Leech' or active=='Leech') then
        --if turni>#enemies then i=turni-1
        --else i=turni end
        if not enemies[i] then i=turni-1 end
        i=i or turni
        if not enemies[i] then i=turni end
        --trace(enemyatk)
--      if n<0 and enemies[i] and (plr.reflect or enemies[i].reflect) then enemies[i].reflect=enemies[i].reflect or 0; enemies[i].reflect=enemies[i].reflect-1 if enemies[i].reflect<=0 then enemies[i].reflect=nil; ins(reflectshout,{fmt('%s\'s Reflect wears out!',enemy_name(enemies[i])),orig=enemies[i]}) end plrdmg(n,turni); return end
--      if n>=0 and (enemyatk=='Leech' or active=='Leech') and ((enemies[i].reflect) or (n<0 and plr.reflect)) then
        if n>=0 and enemies[i].reflect then
                shout(fmt('Damage to %s was reflected!',enemy_name(enemies[i])))
                trace('enemy reflects damage')
                ins(prequeue, 1, function() trace('enemyreflect') if enemies[i].reflect then enemies[i].reflect=enemies[i].reflect-1; if enemies[i].reflect==0 then enemies[i].reflect=nil; ins(reflectshout,1,{fmt('%s\'s Reflect wears out!',enemy_name(enemies[i])),orig=enemies[i]}) end end plrdmg(n) end)
                return
        end
        if n<0 and plr.reflect and (enemyatk=='Leech' or active=='Leech') then
                --shout(fmt('Heals to %s were reflected!',enemy_name(enemies[i])))
                trace('enemy reflects heals')
                ins(prequeue, 1, function() plrdmg(n) end)
                trace(#queue)
                return
        end
        --if not enemies[i] then trace('what why not'); return end
        --if enemies[i].reflect and n>=0 then shout(fmt('Damage to %s was reflected!',enemy_name(enemies[i]))); enemies[i].reflect=enemies[i].reflect-1 if enemies[i].reflect<=0 then enemies[i].reflect=nil; shout(fmt('%s\'s Reflect wears out!',enemy_name(enemies[i]))) end plrdmg(n); return end
        --if (enemyatk=='Leech' or active=='Leech') and plr.reflect and n<0 then plr.reflect=plr.reflect-1; if plr.reflect==0 then plr.reflect=nil end plrdmg(n); return end

        if n>=0 then enemies[i].blink=12 end
        
        if enemies[i].hp>0 then
        enemies[i].hp=enemies[i].hp-n
        if enemies[i].hp>enemies[i].maxhp then enemies[i].hp=enemies[i].maxhp end
        if enemies[i].hp<0 then enemies[i].hp=0 end

        if enemies[i].hp==0 then
        -- scale persistence to animation length
        if active=='Attack' then
                enemies[i].t=90
        --[[elseif active=='Meteor' then
                enemies[i].t=180
        elseif active=='Lightning' then
                enemies[i].t=50]]
        elseif picross[active] then
                enemies[i].t=90
        end
        if solved() then enemies[i].t=90 end
        end

        local out=-n
        --if plrspells[active] and active~='Lightning' then out=fmt('%dx%d=%d',new,plrspells[active].mult,n) 
        --elseif active=='Lightning' then out=fmt('%dx%.1f=%.1f',new,plrspells[active].mult,n) end
        label(tolabel(out),160-30+8+(i-1)*40)
        end
end

function enemyclear()
        for i,e in ipairs(enemies) do
                if e.hp>0 then return false end
        end
        return true
end

function allydmg(n,i)
        i=i or 1
        if i==1 then plrdmg(n); return end
        
        if n>=0 then allies[i].blink=12 end

        allies[i].hp=allies[i].hp-n
        if allies[i].hp>allies[i].maxhp then allies[i].hp=allies[i].maxhp end
        if allies[i].hp<0 then allies[i].hp=0 end

        label(tolabel(-n),56+8+5-(i-1)*30)
end

function plrdmg(n,selfinflicted)
  --if n>=0 and (plr.reflect or ((active=='Leech' or enemyatk=='Leech') and enemies[turni].reflect)) then plr.reflect=plr.reflect or 0; plr.reflect=plr.reflect-1; if plr.reflect<=0 then plr.reflect=nil; ins(reflectshout,{'Your Reflect wears out!',orig=plr}) end
                --if plr.reflect then enemies[turni].reflect=enemies[turni].reflect or 0; enemies[turni].reflect=enemies[turni].reflect-1; if enemies[turni].reflect==0 then enemies[turni].reflect=nil; ins(reflectshout,{fmt('%s\'s Reflect wears out!',enemy_name(enemies[i])),orig=enemies[i]}) end return end 
        i=i or enemyi
        i=i or turni
        --trace(plr.reflect)
        --trace(n)
        if n>=0 and plr.reflect then
                shout('Damage to you was reflected!')
                trace('player reflects damage')
                ins(prequeue, 1, function() trace('playerreflect') if plr.reflect then plr.reflect=plr.reflect-1; if plr.reflect==0 then plr.reflect=nil; trace('reflectshout'); ins(reflectshout,1,{'Your Reflect wears out!',orig=plr}) end end 
                local i=turni-1;
                if not rowguess and selfinflicted then 
                i=enemyi
                while not i or enemies[i].hp==0 do
                i=math.random(#enemies)
                end
                end enemydmg(n,i) end)
                return
        end
        if n<0 and (enemyatk=='Leech' or active=='Leech') and (enemies[i].reflect) then
                --shout('Heals to you were reflected!')
                trace('player reflects heals')
                ins(prequeue, 1, function() enemydmg(n,turni-1) end)
                return
        end
        --if plr.reflect and n>=0 then shout('Damage to Player was reflected!'); plr.reflect=plr.reflect-1; if plr.reflect<=0 then plr.reflect=nil; shout('Your Reflect wears out!') end enemydmg(n,turni); return end

        if n>=0 then plr.blink=12 end

        plr.hp=plr.hp-n
        if plr.hp>plr.maxhp then plr.hp=plr.maxhp end
        if plr.hp<0 then plr.hp=0 end

        label(tolabel(-n),56+8+5)
end

labels={}
function label(msg,xpos)
        ins(labels,{msg=msg,x=xpos,y=6*8-12})
end

function tolabel(n)
        if n>0 then return '+'..tostring(n) end
        if n==0 then return '+/-0' end
        return tostring(n)
end

function draw_labels()
        for i=#labels,1,-1 do
                local l=labels[i]
                print(l.msg,l.x,l.y,t*FLASH_SPD)
                l.y=l.y-(l.y-9)*0.1
        end
end

footer={msg=nil,t=0}

function describe(msg)
        footer.msg=msg
        footer.t=1
end

function draw_footer()
        if footer.t>0 then
                rect(0,136-7,240,7,13)
                local tw=print(footer.msg,0,-6,12,false,1,true)
                print(footer.msg,120-tw/2,136-7+1,12,false,1,true)
                footer.t=footer.t-1
        end
end

header={msg={},t=0}

function shout(msg)
        if not header.msg[1] then header.t=170 end
        ins(header.msg,msg)
end

function draw_header()
        if header.t>0 then
                local rc=2
                local tc=12
                if header.t>=160 or header.t<=10 then 
                rc=1; tc=13
                end
                
                rect(0,0,240,7,rc)
                local tw=print(header.msg[1],0,-6,tc,false,1,true)
                print(header.msg[1],120-tw/2,1,tc,false,1,true)
                header.t=header.t-1
                if header.t==0 then
                        rem(header.msg,1)
                        if header.msg[1] then header.t=170 end
                end
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

function enemy_name(e)
        local name=e.type
        local similar={}
        for i2,e2 in ipairs(enemies) do
                if e2.type==e.type then
                        ins(similar,e2)
                end
        end
        if #similar>1 then
        for i2,e2 in ipairs(similar) do
                if e2==e then name=name..' '..tostring(i2); break end
        end
        end
        return name
end

function solved()
        for sqx=0,mw-1 do
        for sqy=0,mh-1 do
                if mget(mx+sqx,my+sqy)~=mget(239-mw+1+sqx,135-mh+1+sqy) then
                        return false
                end
        end
        end
        return true
end

function boss_solved()
        for sqx=0,bmw-1 do
        for sqy=0,bmh-1 do
                if mget(bmx+sqx,bmy+sqy)~=mget(sqx,135-bmh+1+sqy) then
                        return false
                end
        end
        end
        return true
end

plrspells={
'SmolHeal','Meteor','Lightning',--'Flee','Reflect',--'Taunt',
--'Flee','Reflect','Leech','Mine','Buff','Taunt',
--'Mine','Buff','Taunt','Ice','Spore','Poison','AntiPsn','Leech','AntiSpore','SoulLeech','Flame',
--'AntiPsn',
}

spells={
['SmolHeal']={desc='',maxcool=1,cooldown=0,mult=-3,minsq=1,maxsq=3},
['Meteor']={desc='',maxcool=2,cooldown=0,mult=3,minsq=1,maxsq=3},
['Lightning']={desc='Hits all enemies. ',maxcool=1,cooldown=0,mult=1.5,minsq=3,maxsq=5},
['Buff']={desc='Adds previously filled squares in row to damage calculations.',maxcool=3,cooldown=0,mult=1,minsq=2,maxsq=2},
['Taunt']={desc='Forces the target to fill in the tiniest possible rows.',maxcool=3,cooldown=0,mult=1,minsq=3,maxsq=3},
['Ice']={desc='Increases target cooldowns by 2.',maxcool=3,cooldown=0,mult=1,minsq=2,maxsq=2},
['Spore']={desc='Decreases target fill-in ranges.',maxcool=3,cooldown=0,mult=1,minsq=2,maxsq=2},
['Poison']={desc='Does squares\' amount of poison damage for 4 turns.',maxcool=3,cooldown=0,mult=1,minsq=1,maxsq=4},
['AntiPsn']={desc='Reduces poison damage by squares\' amount.',maxcool=2,cooldown=0,mult=1,minsq=1,maxsq=4},
['Leech']={desc='Steals HP from target. ',maxcool=1,cooldown=0,mult=2,minsq=2,maxsq=4},
['Mine']={desc='Forces the use of an unseen spell.',maxcool=0,cooldown=0,mult=2,minsq=2,maxsq=2},
['AntiSpore']={desc='Increases your fill-in ranges.',maxcool=3,cooldown=0,mult=1,minsq=2,maxsq=2},
['SoulLeech']={desc='Swaps target hit points with yours.',maxcool=4,cooldown=0,mult=1,minsq=4,maxsq=4},
['Flame']={desc='Decreases your cooldowns by 2.',maxcool=3,cooldown=0,mult=1,minsq=2,maxsq=2},
['Flee']={desc='Escape the encounter early.',maxcool=0,cooldown=0,mult=1,minsq=1,maxsq=1},
['Reflect']={desc='Reflect damage back to enemy.',maxcool=2,cooldown=0,mult=1,minsq=3,maxsq=3},
['MedHeal']={desc='',maxcool=1,cooldown=0,mult=-3,minsq=3,maxsq=7},
['Query']={desc='Ask target about keywords.',maxcool=0,cooldown=0,mult=1,minsq=1,maxsq=1},
['Summon']={desc='',maxcool=2,cooldown=0,mult=1,minsq=4,maxsq=4},
}
--plr.atk_cooldown=2

function register_spell(sp)
        return {desc=spells[sp].desc,maxcool=spells[sp].maxcool,cooldown=0,mult=spells[sp].mult,minsq=spells[sp].minsq,maxsq=spells[sp].maxsq}
end

for i,sp in ipairs(plrspells) do 
        plrspells[sp]=register_spell(sp)
end

wldplr={tx=3,ty=42,x=3*8,y=(42-34)*8}

function neighbours(ax,ay)
        local out={}
        if mget(ax+1,ay)==34 then ins(out,{x=ax+3,y=ay}) end
        if mget(ax-1,ay)==34 then ins(out,{x=ax-3,y=ay}) end
        if mget(ax,ay+1)==35 then ins(out,{x=ax,y=ay+3}) end
        if mget(ax,ay-1)==35 then ins(out,{x=ax,y=ay-3}) end
        return out 
end

function pathfind(ent,tx,ty)
        local enc_allowed=false
        ::restart::
        local fx,fy=ent.tx,ent.ty
        local out={{x=fx,y=fy}}
        local final={}

        for i,o in ipairs(out) do
        if i==1 and mget(o.x,o.y)==49 then
                if ent.prevdir=='right' then ins(out,{x=o.x-3,y=o.y,prev=o}) end
                if ent.prevdir=='left' then ins(out,{x=o.x+3,y=o.y,prev=o}) end
                if ent.prevdir=='down' then ins(out,{x=o.x,y=o.y-3,prev=o}) end
                if ent.prevdir=='up' then ins(out,{x=o.x,y=o.y+3,prev=o}) end
                goto skip
        end
        if mget(o.x,o.y)==49 and not enc_allowed then goto skip end
        
        for j,v in ipairs(neighbours(o.x,o.y)) do
                local inlist=false
                for k,q in ipairs(out) do
                        if q.x==v.x and q.y==v.y then
                                inlist=true
                                break
                        end
                end
                if not inlist then
                ins(out,v)
                v.prev=o
                end
                if v.x==tx and v.y==ty then
                        while v.prev do
                                -- the starting tile is skipped
                                ins(final,v)
                                v=v.prev
                        end
                        return final
                end
        end
        ::skip::
        if o.x==tx and o.y==ty then
                while o.prev do
                        -- the starting tile is skipped
                        ins(final,o)
                        o=o.prev
                end
                return final
        end
        end

        -- if can't find tx,ty on retry,
        -- return an empty path
        if enc_allowed then return final end

        -- can't find tx,ty:
        -- retry with encounters allowed on path
        -- except for the encounter you're standing on
        enc_allowed=true
        goto restart

end

areas={
{x=0,y=34,c=15,
roaming={{sp=506,tx=21,ty=42,x=21*8,y=(42-34)*8,spawn=function() 
start_dialogue('sc_1_telepathy')
end}}},
{x=30,y=34,c=6,
roaming={{sp=507,tx=38,ty=43,x=(38-30)*8,y=(43-34)*8,spawn=function()
TIC=overworld_fadeout; cur_encounter=encounters['sc_2_shyfairy']; fr=260; fa=21
end},
{sp=160,tx=47,ty=43,x=(47-30)*8,y=(43-34)*8,spawn=function()
TIC=overworld_fadeout; cur_encounter=encounters['merchant1']; fr=260; fa=21
end}
}},
{x=60,y=34,c=3,roaming={}},
{x=90,y=34,c=14,roaming={}}}
area=areas[1]

function overworld()
        draw_overworld()
        
        leftheld=left
        rightheld=right
        mox,moy,left,_,right=mouse()
        
        local mp=mget(area.x+mox//8,area.y+moy//8)
     if mp==33 or mp==49 or mp==50 or mp==65 then
                spr(255,mox-8+(t*0.18%3),moy-8+(t*0.18%3),0)
                spr(255,mox+4-(t*0.18%3),moy-8+(t*0.18%3),0,1,0,1)
                spr(255,mox-8+(t*0.18%3),moy+4-(t*0.18%3),0,1,0,3)
                spr(255,mox+4-(t*0.18%3),moy+4-(t*0.18%3),0,1,0,2)
                
                if left and not leftheld and not wldplr.tgt then
                        if (mget(wldplr.tx,wldplr.ty)==49 or mget(wldplr.tx,wldplr.ty)==50) and area.x+mox//8==wldplr.tx and area.y+moy//8==wldplr.ty then
                                TIC=overworld_fadeout
                                cur_encounter=encounters[fmt('%d:%d',wldplr.tx,wldplr.ty)]
                                fr=260
                                fa=21
                        else
                                path=pathfind(wldplr,area.x+mox//8,area.y+moy//8)
                                if #path>0 and (mget(wldplr.tx,wldplr.ty)~=49 or (path[#path].x==wldplr.tx-3 and wldplr.prevdir=='right') or (path[#path].x==wldplr.tx+3 and wldplr.prevdir=='left') or (path[#path].y==wldplr.ty-3 and wldplr.prevdir=='down') or (path[#path].y==wldplr.ty+3 and wldplr.prevdir=='up')) then
                                wldplr.tgt={x=(path[#path].x-area.x)*8,y=(path[#path].y-area.y)*8}
                                if path[#path].x==wldplr.tx+3 then wldplr.prevdir='right' end
                                if path[#path].x==wldplr.tx-3 then wldplr.prevdir='left' end
                                if path[#path].y==wldplr.ty+3 then wldplr.prevdir='down' end
                                if path[#path].y==wldplr.ty-3 then wldplr.prevdir='up' end
                                wldplr.tx=path[#path].x; wldplr.ty=path[#path].y
                                end
                        end
                end
                
                --[[if left and not leftheld and not tgt then
                        if mget(wldplr.tx,wldplr.ty)==49 and mox//8==wldplr.tx and 34+moy//8==wldplr.ty then
                                TIC=overworld_fadeout
                                cur_encounter=encounters[fmt('%d:%d',wldplr.tx,wldplr.ty)]
                                fr=200
                                fa=18
                        end
                  if (mget(wldplr.tx,wldplr.ty)~=49 or prevdir=='down') and mget(wldplr.tx,wldplr.ty-1)==35 and mox//8==wldplr.tx and 34+moy//8==wldplr.ty-3 then
                                wldplr.ty=wldplr.ty-3; wldplr.tgt={x=wldplr.x, y=(wldplr.ty-34)*8}; prevdir='up'
                        end
                  if (mget(wldplr.tx,wldplr.ty)~=49 or prevdir=='up') and mget(wldplr.tx,wldplr.ty+1)==35 and mox//8==wldplr.tx and 34+moy//8==wldplr.ty+3 then
                                wldplr.ty=wldplr.ty+3; wldplr.tgt={x=wldplr.x, y=(wldplr.ty-34)*8}; prevdir='down'
                        end
                  if (mget(wldplr.tx,wldplr.ty)~=49 or prevdir=='right') and mget(wldplr.tx-1,wldplr.ty)==34 and mox//8==wldplr.tx-3 and 34+moy//8==wldplr.ty then
                                wldplr.tx=wldplr.tx-3; wldplr.tgt={x=wldplr.tx*8, y=wldplr.y}; prevdir='left'
                        end
                  if (mget(wldplr.tx,wldplr.ty)~=49 or prevdir=='left') and mget(wldplr.tx+1,wldplr.ty)==34 and mox//8==wldplr.tx+3 and 34+moy//8==wldplr.ty then
                                wldplr.tx=wldplr.tx+3; wldplr.tgt={x=wldplr.tx*8, y=wldplr.y}; prevdir='right'
                        end
                end
                ]]--
        end
        
        if btnp(0) and not wldplr.tgt and (mget(wldplr.tx,wldplr.ty)~=49 or wldplr.prevdir=='down') and mget(wldplr.tx,wldplr.ty-1)==35 then wldplr.ty=wldplr.ty-3; wldplr.tgt={x=wldplr.x, y=(wldplr.ty-area.y)*8}; wldplr.prevdir='up' end
        if btnp(1) and not wldplr.tgt and (mget(wldplr.tx,wldplr.ty)~=49 or wldplr.prevdir=='up') and mget(wldplr.tx,wldplr.ty+1)==35 then wldplr.ty=wldplr.ty+3; wldplr.tgt={x=wldplr.x, y=(wldplr.ty-area.y)*8}; wldplr.prevdir='down' end
        if btnp(2) and not wldplr.tgt and (mget(wldplr.tx,wldplr.ty)~=49 or wldplr.prevdir=='right') and mget(wldplr.tx-1,wldplr.ty)==34 then wldplr.tx=wldplr.tx-3; wldplr.tgt={x=(wldplr.tx-area.x)*8, y=wldplr.y}; wldplr.prevdir='left' end
        if btnp(3) and not wldplr.tgt and (mget(wldplr.tx,wldplr.ty)~=49 or wldplr.prevdir=='left') and mget(wldplr.tx+1,wldplr.ty)==34 then wldplr.tx=wldplr.tx+3; wldplr.tgt={x=(wldplr.tx-area.x)*8, y=wldplr.y}; wldplr.prevdir='right' end
        if wldplr.tgt then
                wldplr.x=wldplr.x+(wldplr.tgt.x-wldplr.x)*0.2
                wldplr.y=wldplr.y+(wldplr.tgt.y-wldplr.y)*0.2
                if math.abs(wldplr.tgt.x-wldplr.x)<1 and math.abs(wldplr.tgt.y-wldplr.y)<1 then
                        wldplr.x=wldplr.tgt.x; wldplr.y=wldplr.tgt.y
                        wldplr.tgt=nil
                        local overlap=false
                        for i=#area.roaming,1,-1 do
                        local r=area.roaming[i]
                        if not r.spawned and r.tx==wldplr.tx and r.ty==wldplr.ty then
                                r.spawn()
                                r.spawned=true
                                r.steps=nil
                                --rem(roaming,i)
                                overlap=true
                        end
                        end
                        if path and not overlap then
                                rem(path,#path)
                                if #path==0 then path=nil
                                elseif #path>0 and (mget(wldplr.tx,wldplr.ty)~=49 or (path[#path].x==wldplr.tx-3 and wldplr.prevdir=='right') or (path[#path].x==wldplr.tx+3 and wldplr.prevdir=='left') or (path[#path].y==wldplr.ty-3 and wldplr.prevdir=='down') or (path[#path].y==wldplr.ty+3 and wldplr.prevdir=='up')) then
                                wldplr.tgt={x=(path[#path].x-area.x)*8,y=(path[#path].y-area.y)*8}
                                if path[#path].x==wldplr.tx+3 then wldplr.prevdir='right' end
                                if path[#path].x==wldplr.tx-3 then wldplr.prevdir='left' end
                                if path[#path].y==wldplr.ty+3 then wldplr.prevdir='down' end
                                if path[#path].y==wldplr.ty-3 then wldplr.prevdir='up' end
                                wldplr.tx=path[#path].x; wldplr.ty=path[#path].y
                                end
                        end
                end
        else
                if mget(wldplr.tx,wldplr.ty)==49 or mget(wldplr.tx,wldplr.ty)==50 then
                        if mget(wldplr.tx,wldplr.ty)==49 then 
                        print('Z or left-click to enter encounter',3-1,136-2-6,1,false,1,true)
                        print('Z or left-click to enter encounter',3,136-2-6-1,1,false,1,true)
                        print('Z or left-click to enter encounter',3+1,136-2-6,1,false,1,true)
                        print('Z or left-click to enter encounter',3,136-2-6+1,1,false,1,true)
                        print('Z or left-click to enter encounter',3,136-2-6,12,false,1,true)
                        end
                        if mget(wldplr.tx,wldplr.ty)==50 then 
                        print('Z or left-click to enter new area',3-1,136-2-6,1,false,1,true)
                        print('Z or left-click to enter new area',3,136-2-6-1,1,false,1,true)
                        print('Z or left-click to enter new area',3+1,136-2-6,1,false,1,true)
                        print('Z or left-click to enter new area',3,136-2-6+1,1,false,1,true)
                        print('Z or left-click to enter new area',3,136-2-6,12,false,1,true)
                        end
                        if btnp(4) then
                                TIC=overworld_fadeout
                                cur_encounter=encounters[fmt('%d:%d',wldplr.tx,wldplr.ty)]
                                fr=260
                                fa=21
                        end
                end
        end

        for i,r in ipairs(area.roaming) do
                if not r.sp then rect(r.x,r.y,8,8,1)
                else spr(r.sp,r.x,r.y,0) end
        end
        --rect(wldplr.x,wldplr.y,8,8,1)
        --print('You',wldplr.x-2,wldplr.y+1,2,false,1,true)
        spr(505,wldplr.x,wldplr.y,0)

        if t==0 then start_dialogue('sc_1_intro'); TIC() end

        if key(63) and keyp(19) then
                savedata()
                --shout('Game saved!')
        end
        if key(63) and keyp(12) then
                loaddata()
                --shout('Game loaded!')
        end
        
        -- weird rectangle code
        --[[if debug then
        rx=rx or math.random(0,30-1-5)
        ry=ry or math.random(0,136/8-1-5)
        for x=0,7-1 do for y=0,7-1 do
        if x==0 or x==7-1 or y==0 or y==7-1 then
        rect(rx*8+x*8,ry*8+y*8,8,8,0)
        end
        end end
        end]]
        
        draw_header()

        t=t+1
end

function fade_pal(c)
        if c==0 then return 0 end
        if c==1 then return 0 end
        if c==2 then return 1 end
        if c==3 then return 2 end
        if c==4 then return 3 end
        if c==5 then return 6 end
        if c==6 then return 7 end
        if c==7 then return 8 end
        if c==8 then return 1 end
        if c==9 then return 8 end
        if c==10 then return 9 end
        if c==11 then return 10 end
        if c==12 then return 13 end
        if c==13 then return 14 end
        if c==14 then return 15 end
        if c==15 then return 1 end
end

fade_palette={
}
for i=0,15 do fade_palette[i]=i end

function flee_fadeout()
        cls(args.bg)
        
        draw_bg()
        draw_board(args)

        if t-sc_t>=120 and header.t==0 then
                if t%16==0 then
                        local black=0
                        for i=0,15 do
                                if fade_palette[i]==0 then black=black+1 end
                                fade_palette[i]=fade_pal(fade_palette[i])
                                --trace(fmt('%d:%d',i,fade_palette[i]))
                                pal(i,fade_palette[i])
                        end
                        if black==16 then
                                reset_encounter()
                                sc_t=t+1
                                TIC=overworld_roaming
                                for i=0,15 do 
                                poke4(0x3FF0*2+i,i) 
                                fade_palette[i]=i 
                                end
                                music()
                        end
                end
        end

        draw_header()

        t=t+1
end

function overworld_fadeout()
        -- no cls
        if fr==260 then music(); sfx(16,'A-5',45,2) end
        for i=0,fa,2 do
        circb(wldplr.x+4,wldplr.y+4,fr-i,2)
        circb(wldplr.x+5,wldplr.y+4,fr-i,2)
        circb(wldplr.x+4,wldplr.y+5,fr-i,2)
        circb(wldplr.x+3,wldplr.y+4,fr-i,2)
        circb(wldplr.x+4,wldplr.y+3,fr-i,2)
        end
        fr=fr-fa
        if fa>1 then fa=fa-1 end
        if fr==0 then 
                if plr.permabubble then plr.reflect=1 end
                TIC=turn 
                cur_encounter.spawn()
        end
        t=t+1
end

--roaming={}

function overworld_append()
        draw_overworld()

        for i,r in ipairs(area.roaming) do
                if not r.sp then rect(r.x,r.y,8,8,1)
                else spr(r.sp,r.x,r.y,0) end
        end
        spr(505,wldplr.x,wldplr.y,0)

        if t%16==0 and #append>0 then
                mset(append[1].tx,append[1].ty,append[1].id)
                rem(append,1)
                sfx(5,'D-4',20,1)
        elseif #append==0 then sc_t=t+1; TIC=overworld_roaming end
        
        t=t+1
end

function draw_overworld()
        cls(area.c)
        if area.c==6 then
                for i=0,17,2 do
                        rect(0,i*8,240,8,7)
                end
        end
        --if area.c==14 then
        --      for i=0,30,2 do
        --              rect(i*8,0,8,136,10)
        --      end
        --end
        if area.c==15 then
        map(area.x,area.y,30,1,0,0)
        map(area.x,area.y+1,30,17-2,0,8,0)
        map(area.x,area.y+16,30,1,0,(17-1)*8)
        else
        map(area.x,area.y,30,17,0,0,0)
        end
end

function overworld_roaming()
        draw_overworld()
        overworld_music()
        
        --trace(TIC==overworld_roaming)
        --trace(t-sc_t)
        if t-sc_t==0 then
                for i,r in ipairs(area.roaming) do
                        r.steps=nil
                end
        end
        
        if #area.roaming==0 then TIC=overworld end

        for i=#area.roaming,1,-1 do
                local r=area.roaming[i]
          r.steps=r.steps or 5
                if r.steps>0 then
                        if not r.tgt then
                        local dir=neighbours(r.tx,r.ty)
                        dir=dir[math.random(1,#dir)]
                        if mget(r.tx,r.ty)~=49 or (mget(r.tx,r.ty)==49 and (r.prevdir==nil or (r.prevdir=='right' and dir.x==r.tx-3) or (r.prevdir=='left' and dir.x==r.tx+3) or (r.prevdir=='up' and dir.y==r.ty+3) or (r.prevdir=='down' and dir.y==r.ty-3))) then
                        r.tgt={x=(dir.x-area.x)*8,y=(dir.y-area.y)*8}
                        if dir.x==r.tx-3 then r.prevdir='left' end
                        if dir.x==r.tx+3 then r.prevdir='right' end
                        if dir.y==r.ty-3 then r.prevdir='up' end
                        if dir.y==r.ty+3 then r.prevdir='down' end
                        r.tx=dir.x; r.ty=dir.y
                        r.steps=r.steps-1
                        end
                        end
                elseif not r.tgt then  
                local allnil=true
                for j,r2 in ipairs(area.roaming) do
                        if r2.tgt then allnil=false; break end
                end
                if allnil then
                for j,r2 in ipairs(area.roaming) do
                        r2.steps=0; r2.spawned=false;
                end
                TIC=overworld 
                end
                end
        
                if r.tgt then
                        r.x=r.x+(r.tgt.x-r.x)*0.2
                        r.y=r.y+(r.tgt.y-r.y)*0.2
                        if math.abs(r.tgt.x-r.x)<1 and math.abs(r.tgt.y-r.y)<1 then
                                r.x=r.tgt.x; r.y=r.tgt.y
                                r.tgt=nil
                                if not r.spawned and r.tx==wldplr.tx and r.ty==wldplr.ty then
                                        for j,r2 in ipairs(area.roaming) do
                                                r2.steps=0;
                                                if r2.tgt then r2.x=r2.tgt.x; r2.y=r2.tgt.y end
                                        end
                                        r.spawn()
                                        r.spawned=true
                                        --r.steps=nil
                                        --rem(roaming,i)
                                end
                        end
                end

                if not r.sp then rect(r.x,r.y,8,8,1)
                else spr(r.sp,r.x,r.y,0) end
        end
        
        --rect(wldplr.x,wldplr.y,8,8,1)
        --print('You',wldplr.x-2,wldplr.y+1,2,false,1,true)
        spr(505,wldplr.x,wldplr.y,0)
        
        draw_header()

        t=t+1
end

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

expgain={
        ['AcroBat']=23,
        ['Maneki']=41,
        ['MunSlime']=34,
        ['Rival']=96,
        ['Burr']=78,
        ['Mimic']=87,
        ['Hidaldi']=82,
        ['Sheebly']=99,
        ['Shaably']=92,
        ['Shoobly']=97,
        ['ShyFairy']=141,
        ['MercRat']=63,
        ['Schwobly']=244,
}

function shoppe()
        cls(2)
        
        draw_bg()
        
        draw_board(args)
        
        draw_sidebar_shop()
        
        resolve_turn_shop()
        
        draw_header()
        
        draw_footer()
        
        t=t+1
end

shop_inv={
        'Potion','Potion','Potion','MedHeal','Attack+','PermaBubble','Sponge','Photo','Photo','IceSword',
        ['Potion']={desc='Restores health to max, active immediately.',cost=26},
        ['MedHeal']={desc='Upgrade SmolHeal (1-3) -> MedHeal (3-7).',cost=59},
        ['Attack+']={desc='Upgrade Attack (1-5) -> Attack (2-7).',cost=48},
        ['PermaBubble']={desc='Start every battle with one Reflect.',cost=63},
        ['Sponge']={desc='You\'ll gain +25% more exp.',cost=72},
        ['Photo']={desc='A nice ready-solved 5x5 Picross.',cost=38},
        ['IceSword']={desc='Regular Attacks increase target cooldowns by 1 for 3 turns.',cost=86},
}

function resolve_turn_shop()
        if (sb_tgt=='Buy' and #shoppingcart>0) or (sb_tgt=='Leave' and active=='Leave') then
                rect(120+13*2+6+6,68+13*4-3,24,16,13)
                print('Done',120+13*2+6+6+4,68+13*4-3+5,12,false,1,true)
                rectb(120+13*2+6+6,68+13*4-3,24,16,t*FLASH_SPD)

                local cost=0
                for i,n in ipairs(shoppingcart) do
                        cost=cost+shop_inv[shop_inv[n]].cost
                end

                if AABB(mox,moy,1,1,120+13*2+6+6,68+13*4-3,24,16) then
                        if sb_tgt=='Buy' then
                                describe(fmt('Buying %d item(s) with %d exp',#shoppingcart,cost))
                                if left and not leftheld and cost<=exp then
                                        sfx(8,12*6,6,3)
                                        
                                        --local cost=0
                                        for i,n in ipairs(shoppingcart) do
                                                --cost=cost+shop_inv[shop_inv[n]].cost
                                                if shop_inv[n]=='Potion' then shout('Drank 1 potion!')
                                                        --shout(fmt('Bought %s!',shop_inv[n]))
                                                        if plr.hp==plr.maxhp then shout('Your health was already full, but at least it tasted good..')
                                                        else plr.hp=plr.maxhp
                                                        shout('HP fully restored!') end
                                                elseif shop_inv[n]=='Photo' then
                                                        local pic=picross[fmt('%d:%d',math.random(0,3)*5,0)]
                                                        shout(fmt('Bought a photo: %s!',pic))
                                                        ins(plrpicross,pic)
                                                elseif shop_inv[n]=='Sponge' then
                                                        shout(fmt('Bought %s!',shop_inv[n]))
                                                        plr.sponge=true
                                                elseif shop_inv[n]=='PermaBubble' then
                                                        shout(fmt('Bought %s!',shop_inv[n]))
                                                  plr.permabubble=true
                                                elseif shop_inv[n]=='Attack+' then
                                                        shout(fmt('Bought %s!',shop_inv[n]))
                                                        plr.minatk=2; plr.maxatk=7
                                                elseif shop_inv[n]=='MedHeal' then
                                                        shout(fmt('Bought %s!',shop_inv[n]))
                                                        local i=find(plrspells,'SmolHeal')
                                                        rem(plrspells,i)
                                                        ins(plrspells,i,'MedHeal')
                                                        plrspells['MedHeal']=register_spell('MedHeal')
                                                elseif shop_inv[n]=='IceSword' then
                                                        shout(fmt('Bought %s!',shop_inv[n]))
                                                        plr.icesword=true
                                                else
                                                        shout(fmt('Bought %s!',shop_inv[n]))
                                                end
                                        end
                                        -- to not mess up the order of items
                                        for i,n in ipairs(shoppingcart) do
                                                rem(shop_inv,n)
                                                ins(shop_inv,n,-1)
                                        end
                                        for i=#shop_inv,1,-1 do
                                                if shop_inv[i]==-1 then rem(shop_inv,i) end
                                        end
                                        exp=exp-cost
                                        shout(fmt('%d exp lost. (Now %d)',cost,exp))
                                        shoppingcart={}
                                        for i=1,10 do
                                                sb_cam['x'..tostring(i)]=nil
                                                sb_cam['dx'..tostring(i)]=nil
                                        end
                                elseif left and not leftheld and cost>exp then
                                shout('Wait a minute! You don\'t have that many exp.')
                                end
                        end                             
                        if sb_tgt=='Leave' and active=='Leave' then
                                if left and not leftheld then
                                sfx(8,12*6,6,3)
                                shout('See you soon!')
                                sc_t=t+1
                                TIC=flee_fadeout
                                for i=1,10 do
                                        sb_cam['x'..tostring(i)]=nil
                                        sb_cam['dx'..tostring(i)]=nil
                                end
                                end
                        end
                end
        end
end

shoppingcart={}

function draw_sidebar_shop()
        leftheld=left
        mox,moy,left,_,right,_,mwv=mouse()

        -- left bar

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
        sh=sh+(#shop_inv+1)*7
        
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
        
        if sb_tgt=='Buy' then

        if sb_cam.y+6*8+4+2>6*8+4+1 then
        rect(6,sb_cam.y+6*8+4+2,56-4,6+1,1)
        print('Wares',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
        end
        
        for i,item in ipairs(shop_inv) do
                if sb_cam.y+6*8+7*(i-1)+7+7+6>6*8+4+2 and (sb_cam.y+6*8+7*(i-1)+7+6<6*8+4+64+8+8-1-1 or -sb_cam.y+6*8+4+7-7+1>=sh) then
                if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,4)
                    if left and not leftheld then
                            local j=find(shoppingcart,i)
                            if not j then ins(shoppingcart,i)
                            else rem(shoppingcart,j) end
                            sfx(8,12*6,6,3)
                    end
                    --if item~='IceSword' then describe(shop_inv[item].desc..' '..fmt('Cost: %d exp', shop_inv[item].cost))
                    --else if t%240<120 then describe(shop_inv[item].desc)
                    --else describe(fmt('Cost: %d exp', shop_inv[item].cost))
                    --end
                    --end
                    describe(shop_inv[item].desc)
                end
                if find(shoppingcart,i) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,5)
                end

                local tw=print(item..fmt(' (%d exp)',shop_inv[item].cost),6+1,-6,12,false,1,true)
                sb_cam['x'..tostring(i)]=sb_cam['x'..tostring(i)] or 0
                sb_cam['dx'..tostring(i)]=sb_cam['dx'..tostring(i)] or -0.25
                if tw>56-4 then
                        clip(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7)
                        if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                        sb_cam['x'..tostring(i)]=sb_cam['x'..tostring(i)]+sb_cam['dx'..tostring(i)]
                        if sb_cam['x'..tostring(i)]+6+1+tw<56 or sb_cam['x'..tostring(i)]>2 then sb_cam['dx'..tostring(i)]=-sb_cam['dx'..tostring(i)] end
                        end
                end             
                
                clip(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7)
                print(item..fmt(' (%d exp)',shop_inv[item].cost),sb_cam['x'..tostring(i)]+6+1,sb_cam.y+6*8+7*(i-1)+7+7,12,false,1,true)
                clip()
                end
        end
        
        local pot_count=0
        for i,n in ipairs(shoppingcart) do
                if shop_inv[n]=='Potion' then pot_count=pot_count+1 end
        end
        if pot_count>1 and not has_read('sc_2_merch_potions') then
                start_dialogue('sc_2_merch_potions')
        end
        
        elseif sb_tgt=='Leave' then
                --if sb_cam.y+6*8+4+2>6*8+4+1 then
                rect(6,sb_cam.y+6*8+4+2,56-4,6+1,1)
                print('Leave',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
                
                for i,item in ipairs({'Leave'}) do
                if sb_cam.y+6*8+7*(i-1)+7+7+6>6*8+4+2 and (sb_cam.y+6*8+7*(i-1)+7+6<6*8+4+64+8+8-7-1-1 or -sb_cam.y+6*8+4+7-7+1>=sh) then
                if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,4)
                    if left and not leftheld then
                            active='Leave'
                            sfx(8,12*6,6,3)
                    end
                end
                if active==item then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,5)
                end
                print(item,6+1,sb_cam.y+6*8+7*(i-1)+7+7,12,false,1,true)
                end
                end
        
        end
        -- right bar
        
        rectb(240-56-4,6*8+4,56,64-3,13)
        rect(240-56-4+2,6*8+4+2,56-4,6+1,1)
        print('Options',240-56-4+2+1,6*8+4+2+1,13,false,1,true)
        
        for i,option in ipairs({'Buy','Leave'}) do
                if AABB(mox,moy,1,1,240-56-4+2,6*8+4+2+i*7,56-4,7) then
                        rect(240-56-4+2,6*8+4+2+i*7,56-4,7,4)

                        if left and not leftheld then 
                        sb_tgt=option
                        --[[if sb_tgt~='Leave' then
                                active=nil
                        end
                        if sb_tgt~='Buy' then
                                purchases={}
                        end]]
                        sfx(8,12*6,6,3)
                        end
                        
                        if option=='Buy' then describe(fmt('Spend some of your %d exp.',exp)) end
                        if option=='Leave' then describe('Finish shopping session.') end
                end
                if sb_tgt==option then
                  rect(240-56-4+2,6*8+4+2+i*7,56-4,7,5)
                end
                
                if option=='Buy' then
                print(option..fmt(' (%d exp)',exp),240-56-4+2+1,6*8+4+2+1+i*7,12,false,1,true)
                else
                print(option,240-56-4+2+1,6*8+4+2+1+i*7,12,false,1,true)
                end
        end
        
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

encounters={
        ['9:42']={spawn=function()
        enemies={{type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4}}
        shout('An AcroBat blocks the way!')
        end},
        ['12:42']={spawn=function() 
        enemies={{type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4},
                 {type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4}}
        shout('Gah! Now there\'s two of them!')
        end},
        ['15:39']={spawn=function() 
        enemies={{type='Maneki',hp=25,maxhp=25,minatk=1,maxatk=4}}
        shout('How\'d this cat get lost in the dungeon?')
        end},
        ['15:45']={spawn=function() 
        enemies={{type='MunSlime',hp=15,maxhp=15,minatk=2,maxatk=5}}
        shout('Eww, slime!')
        end},
        ['21:42']={spawn=function() 
        area=areas[2]
        wldplr={tx=32,ty=37,x=(32-30)*8,y=(37-34)*8}
        --for i,r in ipairs(area.roaming) do
        --  r.x=(r.tx-area.x)*8; r.y=(r.ty-area.y)*8
        --end
        --old_roaming=roaming
        --roaming={}
        overworld()
        if not has_read('sc_2_feedback') then
        start_dialogue('sc_2_feedback')
        TIC()
        else sc_t=t+1; TIC=overworld_roaming end
        end},
        ['32:37']={spawn=function()
        area=areas[1]
        wldplr={tx=21,ty=42,x=21*8,y=(42-34)*8}
        --roaming={}
        sc_t=t+1
        TIC=overworld_roaming
        end},
        ['rival1']={spawn=function() 
                enemies={{type='Rival',hp=35,maxhp=35,minatk=1,maxatk=6,spells={'Buff',['Buff']={maxcool=3,cooldown=0}},ai=function()
                        if enemy_cast('Buff') then
                        else enemy_attack()
                        end
                end}}
        end},
        ['merchant1']={spawn=function()
                --TIC=shoppe
                if not has_read('sc_2_merch_intro') then start_dialogue('sc_2_merch_intro')
                else TIC=shoppe end
                sb_cam.y=0; sb_tgt='Buy'
                enemies={{type='Merchant',hp=60,maxhp=60,minatk=1,maxatk=9}}
                shoppe()
                TIC()
        end},
        ['sc_2_shyfairy']={spawn=function()
                --for i,r in ipairs(area.roaming) do
                        --if r.tx==wldplr.tx and r.ty==wldplr.ty then
                                --r.spawned=false
                                --r.steps=5
                        --end
                --end
                enemies={{type='ShyFairy',hp=10,maxhp=10,minatk=1,maxatk=3,spells={'Flee','Reflect',['Flee']={maxcool=3,cooldown=0},['Reflect']={maxcool=2,cooldown=0}},ai=function()
                        enemy_cast('Flee')
                end}}
        end},
        ['35:49']={spawn=function() 
        area=areas[3]
        wldplr={tx=73,ty=36,x=(73-60)*8,y=(36-34)*8}
        --roaming={}
        sc_t=t+1
        TIC=overworld_roaming
        end},
        ['76:42']={spawn=function() enemies={{type='Mimic',adaptor=true,hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Mine',['Mine']={maxcool=0,cooldown=0}},ai=function()
                if not enemies[turni].mined then
                if enemy_cast('Mine') then
                enemies[turni].mined=true
                return
                end
                end
                local sp=enemies[turni].spells[math.random(#enemies[turni].spells)]
                while (enemies[turni].force and find(enemies[turni].force,sp)) or enemies[turni].spells[sp].cooldown>0 or enemies[turni].spells[sp].justcooled or (enemies[turni].queried and sp=='Query') do
                        sp=enemies[turni].spells[math.random(#enemies[turni].spells)]
                end
                if enemy_cast(sp) then
                if sp=='Query' then enemies[turni].queried=true end
                else enemy_attack() end
        end}} 
        end},
        ['56:34']={spawn=function() start_dialogue('sc_2_demoarea') end},
        --{spawn=function()
        --      area=areas[4]
        --      wldplr={tx=104,ty=49,x=(104-90)*8,y=(49-34)*8}
        --      sc_t=t+1
        --      TIC=overworld_roaming
        --end},
        ['38:37']={spawn=function()
        enemies={{type='MercRat',hp=17,maxhp=17,minatk=1,maxatk=3,spells={'Meteor','Query','Lightning',['Meteor']={maxcool=spells['Meteor'].maxcool,cooldown=0},['Query']={maxcool=spells['Query'].maxcool,cooldown=0},['Lightning']={maxcool=spells['Lightning'].maxcool,cooldown=0}},phase=1,ai=function() 
                if enemies[turni].hp<enemies[turni].maxhp and not has_read('sc_2_rat_attack') then
                        start_dialogue('sc_2_rat_attack')
                        enemies[turni].minatk=3; enemies[turni].maxatk=5
                        enemies[turni].phase=-1
                        return
                end

                if enemies[turni].phase==-1 then
                if enemy_cast('Meteor') then
                elseif enemy_cast('Lightning') then
                else enemy_attack() end
                return
                end

                if enemies[turni].phase==1 or enemies[turni].phase==2 or enemies[turni].phase==3 then
                enemy_cast('Query')
                end
        end}}
        turn()
        start_dialogue('sc_2_rat_intro')
        TIC()
        end
        },
        ['44:40']={spawn=function() 
        enemies={{type='Sheebly',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Leech','SoulLeech',['Leech']={maxcool=1,cooldown=0},['SoulLeech']={maxcool=4,cooldown=0}},ai=function() 

                if enemies[turni].hp<=enemies[turni].maxhp/3 and plr.hp>enemies[turni].hp then
                        if enemy_cast('SoulLeech') then
                        return
                        end
                end

                if enemy_cast('Leech') then
                else enemy_attack()
                end
        end}}
        end},
        --['47:34']={spawn=function()
        --      start_dialogue('sc_2_shroom_bros')
        --end},
        ['47:34']={spawn=function()
        enemies={{type='Shoobly',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Poison','AntiPsn',['Poison']={maxcool=3,cooldown=0},['AntiPsn']={maxcool=2,cooldown=0}},ai=function()

                if enemies[turni].poisonstack and enemies[turni].poisonstack>=8 then
                        if enemy_cast('AntiPsn') then   
                        return
                        end
                end

                if enemy_cast('Poison') then        
                else enemy_attack()
                end
        end}}
        end},
        --['50:40']={spawn=function()
        --      start_dialogue('sc_2_shroom_bros2')
        --end},
        ['50:40']={spawn=function()
        enemies={{type='Shaably',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Spore','AntiSpore',['Spore']={maxcool=3,cooldown=0},['AntiSpore']={maxcool=3,cooldown=0}},ai=function()

                if enemies[turni].sporestack and enemies[turni].sporestack>=4 then
                        if enemy_cast('AntiSpore') then
                        return
                        end
                end

                if enemy_cast('Spore') then
                else enemy_attack()
                end
        end}}
        end},
        ['38:46']={spawn=function()
                shout('You\'re gonna """love""" this encounter.')
                enemies={{type='Burr',hp=15,maxhp=15,minatk=1,maxatk=4,spells={'Taunt',['Taunt']={maxcool=3,cooldown=0}},ai=function() 
                if enemy_cast('Taunt') then
                else enemy_attack()
                end
        end}}
        end},
        ['73:36']={spawn=function()
        area=areas[2]
        wldplr={tx=35,ty=49,x=(35-30)*8,y=(49-34)*8}
        --roaming={}
        sc_t=t+1
        TIC=overworld_roaming
        end},
        ['56:43']={
        spawn=function()
        enemies={{type='Schwobly',hp=60,maxhp=60,minatk=1,maxatk=7,spells={'Poison','AntiPsn','Flame','Summon',['Flame']={maxcool=3,cooldown=0},['Poison']={maxcool=spells['Poison'].maxcool,cooldown=0},['AntiPsn']={maxcool=spells['AntiPsn'].maxcool,cooldown=0},['Summon']={maxcool=3,cooldown=0}},ai=function()
        if enemies[turni].phase==1 then
                if enemy_cast('Flame') then
                        enemies[turni].phase=2
                        return
                end
        end
        if enemies[turni].phase==2 then
                if enemy_cast('Poison') then
                        TIC=attack_anim_poison
                        oldactive=active
                        active='Poison'
                        enemyi=turni
                        new=1
                        enemies[turni].phase=3
                        nmy_backfire=true
                        return
                end
        end
        if enemies[turni].phase==3 then
                if enemy_cast('AntiPsn') then
                        return
                end
        end
        end
        }}
        --TIC()
        --start_dialogue('sc_2_bosstest')
        --TIC()
        sc_t=t+1
        TIC=bossintro
        for i,sp in ipairs(enemies[1].spells) do
                for j,k in pairs(spells[sp]) do
                        enemies[1].spells[sp][j]=k
                end
        end
        end},
        --spawn=function() endtime=time(); sc_t=t+1; TIC=endofdemo end},

        ['47:46']={spawn=function() 
        enemies={{type='Hidaldi',hp=20,maxhp=20,minatk=1,maxatk=5,spells={'Ice','Flame',['Ice']={maxcool=3,cooldown=0},['Flame']={maxcool=3,cooldown=0}},ai=function()

                enemies[turni].flamestack=enemies[turni].flamestack or 0
                if enemies[turni].icestack and enemies[turni].icestack-enemies[turni].flamestack>=4 then
                        if enemy_cast('Flame') then
                        return
                        end
                end

                if enemy_cast('Ice') then
                else enemy_attack()
                end
        end}}
        end},
        ['56:37']={spawn=function()
        shout('Burr and Hidaldi have joined forces!')
        enemies={{type='Burr',hp=15,maxhp=15,minatk=1,maxatk=4,spells={'Taunt',['Taunt']={maxcool=3,cooldown=0}},ai=function()
                if enemy_cast('Taunt') then
                else enemy_attack()
                end
        end},{type='Hidaldi',hp=20,maxhp=20,minatk=1,maxatk=5,spells={'Ice','Flame',['Ice']={maxcool=3,cooldown=0},['Flame']={maxcool=3,cooldown=0}},ai=function()

                enemies[turni].flamestack=enemies[turni].flamestack or 0
                if enemies[turni].icestack and enemies[turni].icestack-enemies[turni].flamestack>=4 then
                        if enemy_cast('Flame') then
                        return
                        end
                end

                if enemy_cast('Ice') then
                else enemy_attack() 
                end
        end}}
        end},
}

function has_read(dg)
        return diag_db[dg].i~=nil
end

function dialogue()
        if cur_diag==diag_db['sc_2_avenge'] or cur_diag==diag_db['sc_2_shroom_bros2'] or cur_diag==diag_db['sc_2_shroom_bros'] then
                clip()
                draw_bg()
        end
        clip(0,136-64,240,64)
        cls(13)
        rectb(0,136-64,240,64,t*FLASH_SPD)
        leftheld=left
        rightheld=right
        mox,moy,left,_,right=mouse()
        
        while cur_line and not cur_line[1] do
                if cur_line.f then cur_line.f() end
                if cur_line.sp then cur_sp=cur_line.sp end
                if cur_line.pal then cur_pal=cur_line.pal
                else cur_pal=nil end
                cur_diag.i=cur_diag.i+1
                cur_line.j=1
                cur_line=cur_diag[cur_diag.i]
                cur_line.j=cur_line.j or 1
        end
        if cur_line.sp then cur_sp=cur_line.sp end
        if cur_line==cur_diag[1] and cur_line.j==1 and cur_line.f then cur_line.f() end
        
        if btnp(4) or (left and not leftheld) then
                if cur_line and cur_line.j<#cur_line[1] then cur_line.j=#cur_line[1]
                else 
                if cur_diag then 
                cur_diag.i=cur_diag.i+1
                cur_line=cur_diag[cur_diag.i]
                
                while cur_line and not cur_line[1] do
                        if cur_line.f then cur_line.f() end
                        if cur_line.sp then cur_sp=cur_line.sp end
                if cur_line.pal then cur_pal=cur_line.pal
      else cur_pal=nil end 
                        cur_diag.i=cur_diag.i+1
                        cur_line.j=1
                        cur_line=cur_diag[cur_diag.i]
                end
                
                if cur_line==nil then
                diag_db.active=nil
                cur_diag.i=1
                cur_diag=nil
                --sc_t=t+1
                --trace(t)
                --trace(sc_t)
                t=t+1
                TIC()
                return
                else
                cur_line.j=cur_line.j or 1
                if cur_line.f then cur_line.f() end
                if cur_line.sp then cur_sp=cur_line.sp end
                if cur_line.pal then cur_pal=cur_line.pal 
                else cur_pal=nil end
                end
                end
                end
        end
        
        rect(12-1,136-64+12-1,24+2,24+2,1)
        if cur_line and cur_line.pal then cur_pal=cur_line.pal
        else cur_pal=nil end
        if cur_pal then cur_pal() end
        local bg=0
        if cur_sp==416 then bg=1 end
        if cur_sp==93 then bg=1 end
        if cur_sp==41 then bg=2 end
        spr(cur_sp,12,136-64+12,bg,1,0,0,3,3)
        pal()
        
        local tw=0
        local th=0
        if cur_line then
        local flash
        for i=1,cur_line.j do
                -- text shadow
                local col=1
                if cur_sp==365 then col=7 end
                if cur_sp==269 then col=3 end
                if cur_sp==317 then col=1 end
                if cur_line.col then col=cur_line.col end
                local wob=sin(i*0.4+t*0.2)*1
                if not TEXT_WOB then wob=0 end
                print(sub(cur_line[1],i,i),48+tw+1,136-64+12+th+wob+1,col)

                local col2=12
                if sub(cur_line[1],i,i)=='[' then flash=true end
                if flash then 
                if FLASH_SPD==0.08 then col2=i+t*0.08 end
                if FLASH_SPD==0.3 then col2=i+t*0.3 end
                if FLASH_SPD==1 then col2=i+t*0.5 end
                end
                if sub(cur_line[1],i,i)==']' then flash=false end
                tw=tw+print(sub(cur_line[1],i,i),48+tw,136-64+12+th+wob,col2)
                if sub(cur_line[1],i,i)==' ' then
                        local nextword=print(sub(cur_line[1],i+1,string.find(cur_line[1],' ',i+1) or #cur_line[1]),0,-6,12)
                     if tw+nextword>240-48-6 then
                                th=th+8
                                tw=0
                        end
                end
        end
        cur_line.j=cur_line.j+1
        if cur_line.j>#cur_line[1] then cur_line.j=#cur_line[1] end
        end
        
        if cur_diag and cur_diag.i==1 and cur_line and cur_line.j==#cur_line[1] then
                print('Z or left-click to advance dialogue',4+1,136-4-5+1,1,false,1,true)
                print('Z or left-click to advance dialogue',4,136-4-5,12,false,1,true)
        end
        
        t=t+1
end

function start_dialogue(id)
        diag_db.active=id
        cur_diag=diag_db[diag_db.active]
        cur_diag.i=1--cur_diag.i or 1
        
        cur_line=cur_diag[cur_diag.i]
        cur_line.j=cur_line.j or 1
        
        if cur_line.sp then cur_sp=cur_line.sp end
        TIC=dialogue
end

keywords={}

diag_db={
        active=nil,
        ['sc_1_intro']={
                {sp=365,'Okay newbie! Theory lessons are over, now it\'s time for practice!'},
                {'Your first job! Clean the Academy dungeon! Come see me afterwards if you\'re still alive!'},
                {sp=317,'...'},
                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
        },
        ['sc_1_telepathy']={
                i=1,
                {j=1,sp=269,'(I\'ve figured out a way to legally break the Academy\'s vow of silence!)'},
                {'(Telepathy!)'},
                {'(Just focus on my voice in your head!)'},
                {sp=317,'(Why is he staring at me so intently)'},
                {sp=269,'(Am I clever or what?)'},
                {sp=317,'(stop it stop it stop it stop it this is beyond awkward)'},
                {f=function() clip(); sc_t=t+1; TIC=overworld_fadeout; cur_encounter=encounters['rival1']; fr=260; fa=21 end},
        },
        ['sc_1_post-telepathy']={
                {sp=269,'(Not fair, you just lucked out!)'},
                {'(Come see me again when you\'re stronger!)'},
                {'(In the meantime, I\'ll be fighting some boss enemies! Sayonara!)'},
                {sp=317,'(There he goes with the staring again..)'},
                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
        },
        ['sc_2_feedback']={
                {sp=365,f=function() if mget(15,39)==49 or mget(15,45)==49 or #areas[1].roaming>0 then 
                        diag_db['sc_2_feedback'][2][1]='You did a so-so job cleaning the dungeon!'
                        diag_db['sc_2_feedback'][3][1]='I expect more finesse from my graduates!'
                        else
                        diag_db['sc_2_feedback'][2][1]='You did a nice job cleaning the dungeon!'
                        diag_db['sc_2_feedback'][3][1]='Just what I expect from the graduates of this fine Academy!'
                        end
                end},
                {},
                {},
                {'Anyway, let\'s get you patched up! There\'s quite the challenge ahead.'},
                {sp=317, f=function() plr.hp=plr.maxhp end, '(HP restored.)'},
                {f=function() ins(keywords,'[monster generals]') end,sp=365,'The monsters here aren\'t just random encounters. There are [monster generals] that command lesser monsters.'},
                {'If we can get rid of the generals, it will destabilize the monsters.'},
                {f=function() ins(keywords,'[giant mushroom]') end,'There is a [giant mushroom] somewhere in this garden. It\'s one of the generals. You should have the wits to take it out.'},
                {'Look around for clues to its whereabouts.'},
                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
        },
        ['sc_2_shroom_bros']={
                {sp=374,col=2, 'Before we take this guy to the General for retribution, we\'ve got to decide who\'s our group leader!'},
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'I\'m the wisest! Whenever the General needs guidance, he consults me!'},
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I\'m the best fighter! Whenever the General needs someone taken care of, he sends me!'},
                {sp=374,col=2,'I\'m the original one! The lot of you are just lousy palette swaps of me!'},
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Ouch, bro.'},
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Yeah, you\'re about to give us Luigi syndrome.'},
                {sp=374,col=2,'Instead of that, let\'s open up the path to the General.'},
    {f=function() clip(); append={{tx=53,ty=38,id=35},{tx=53,ty=39,id=35},{tx=53,ty=40,id=33},{tx=54,ty=40,id=34},{tx=55,ty=40,id=34},{tx=56,ty=40,id=33},{tx=56,ty=41,id=35},{tx=56,ty=42,id=35},{tx=56,ty=43,id=49}}; TIC=overworld_append end},
        },
        ['sc_2_shroom_bros2']={
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'How do we tell ourselves apart? It\'s easy!'},
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'It\'s in the name. Sheebly\'s E is blue, Shoobly\'s O is yellow, and Shaably\'s A is red.'},
                {sp=374,col=2,'It\'s synaesthetic!'},
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Syn-a e s t h e t i c'},
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'If there were a Shiibly, he\'d be black, because I is a black letter.'},
    {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
        },
        ['sc_2_demoarea']={
                {sp=374,col=2,'Yo, it looks like you\'re about to leave the demo area.'},
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'We can\'t allow that.'},
                {f=function() clip(); sc_t=t+1; TIC=overworld_roaming end},
        },
        ['sc_2_merch_intro']={
                {sp=208,col=5,'Hello stranger! I\'m a travelling merchant.'},
                {sp=208,col=5,'You may buy my wares with your experience!'},
                {f=function() clip(); sc_t=t+1; TIC=shoppe end},
        },
        ['sc_2_merch_potions']={
                {sp=208,col=5,'Just FYI, you can\'t stockpile potions. You have to drink them on the spot.'},
                {sp=208,col=5,'That\'s because they contain no preservatives.'},
                {sp=208,col=5,'No added sugar, either! And they\'re vegan.'},
                {f=function() clip(); sc_t=t+1; TIC=shoppe end},
        },
        ['sc_2_rat_intro']={
                {sp=69,col=14,'Stop. I see that murderous glare in your eyes.'},
                {sp=69,col=14,'I wish no ill will for you. I just want to ask some questions. Is that okay?'},
                {sp=317,'...'},
                {sp=69,col=14,'Ah, the Academy\'s vow of silence. Well, if you won\'t hurt me this turn, your actions will speak for themselves.'},
                {f=function() clip(); sc_t=t+1; TIC=turn end},
        },
        ['sc_2_rat_phase1']={
                {f=function() ins(keywords,'[you]') end,sp=69,col=14,'First question, and the most basic one. So who are [you] really?'},
                {sp=69,col=14,'You may write your answer on the back of your Picross board.'},
                {sp=317,'*scribble scribble*'},
                {sp=317,'("I am Aldo, a wizard apprentice fresh from the Academy.")'},
                {sp=69,col=14,'I see. They train your kind to persecute us monsters.'},
                {sp=69,col=14,'I can\'t say I condone this activity, but we all choose our own paths.'},
                {f=function() clip(); sc_t=t+1; TIC=enemyturn; enemies[turni].phase=enemies[turni].phase+1; turni=turni+1 end},
        },
        ['sc_2_rat_phase2']={
                {f=function() ins(keywords,'[Picross magic]') end,sp=69,col=14,'Next question. What do you think [Picross magic] really is?'},
                {sp=317,'*scribble scribble*'},
                {sp=317,'("A means of self-defense against monsters.")'},
                {sp=69,col=14,'Ha, of course you think this is how it works. No, I see a conflict in your future.'},
                {sp=69,col=14,'Your answer was superficial. Where do you think [Picross magic] comes from? Do you think it\'s just a given that it works?'},
                {sp=69,col=14,'You still have a lot to learn, but if you stay inquisitive, you will find answers.'},
                {f=function() clip(); sc_t=t+1; TIC=enemyturn; enemies[turni].phase=enemies[turni].phase+1; turni=turni+1 end},
        },
        ['sc_2_rat_phase3']={
                {f=function() ins(keywords,'[quest]') end,sp=69,col=14,'Finally, I want to know: what is your [quest]?'},
                {sp=317,'*scribble scribble*'},
                {sp=317,'("To locate and eliminate the [giant mushroom].")'},
                {sp=69,col=14,'The extent of your snobbery! You\'re simply not strong enough to take out [monster generals].'},
                {sp=69,col=14,'...And I can\'t see why you would even want to. It would only have drastic effects on the balance of this area.'},
                {sp=69,col=14,'No, no good can come from walking that path. I would suggest you seek the path of non-violence.'},
                {sp=69,col=14,'Well, do what you will. Thanks for having this little dialogue, you are now free to go.'},
                {f=function() clip(); turni=turni+1; enemyturn(); gain_exp(); TIC=victory end},
        },
        ['sc_2_rat_attack']={
                {sp=69,col=14,'You\'ve made a grave mistake!'},
                {f=function() clip(); music(5); sc_t=t+1; enemy_cast('Meteor') end},
        },
        ['query_MercRat_[monster generals]']={
                {sp=69,col=14,'Ooh, they\'re very powerful.'},
                {sp=69,col=14,'The ordinance of all monsters rests on their shoulders.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MercRat_[giant mushroom]']={
                {sp=69,col=14,'It lives to the east of this area, in a hidden location.'},
                {sp=69,col=14,'I don\'t see what business you would have with them.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MercRat_[you]']={
                {sp=69,col=14,'I\'m just a humble servant of the [monster generals].'},
                {sp=69,col=14,'I\'m perfectly fine with not harming and not being harmed.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MercRat_[Picross magic]']={
                {sp=69,col=14,'There is a dark secret to [Picross magic].'},
                {sp=69,col=14,'You wouldn\'t fathom the concept, since you\'re from the Academy.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Burr_[you]']={
                {sp=422,col=14,'I HAVE CHRONIC ANXIETY!'},
                {f=function() clip(); TIC=allyturn; allyi=2 end},
        },
        ['query_Burr_[Picross magic]']={
                {sp=422,col=14,'MY TAUNT IS ALL I NEED TO KEEP ENEMIES AT BAY!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Burr_[monster generals]']={
                {sp=422,col=14,'I\'M SCARED OF THEM! THEY\'RE SO POWERFUL!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Burr_[giant mushroom]']={
                {sp=422,col=14,'I DON\'T WANNA CROSS PATHS WITH THEM!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Burr_[quest]']={
                {sp=422,col=14,'QUESTS?! I ALREADY HAVE MY HANDS FULL STAYING SANE HERE!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Hidaldi_[you]']={
                {sp=416,col=0,'I wield the powers of ice and fire.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Hidaldi_[giant mushroom]']={
                {sp=416,col=0,'They\'re not the boss of me, I don\'t take orders from no icky mushroom.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Hidaldi_[monster generals]']={
                {sp=416,col=0,'Hmm, I think they could benefit from my fire magic...'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Hidaldi_[Picross magic]']={
                {sp=416,col=0,'I keep my most powerful spell hidden until there\'s an emergency.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Hidaldi_[quest]']={
                {f=function() 
                        if cur_encounter==encounters['47:46'] then
                                diag_db['query_Hidaldi_[quest]'][2][1]='I\'m looking for someone to team up with!'
                        elseif cur_encounter==encounters['56:37'] then
                                diag_db['query_Hidaldi_[quest]'][2][1]='Now that I\'ve teamed up, my quest is complete.'
                        end     
                end},
                {sp=416,col=0,''},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Mimic']={
                {sp=93,col=2,'Hmmmmm, breaking character a little here.'},
                {sp=93,col=2,'You must be wondering what\'s in the other two encounters, hmmmm?'},
                {sp=93,col=2,'Maybe if you find a secret you\'ll get there hmmmmmm...'},
                {sp=93,col=2,'...But I\'ll give you a hint: you won\'t like what lurks there.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Sheebly_[you]']={
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'I\'m the blue mushroom, Sheebly! I don\'t need no introduction.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shoobly_[you]']={
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I\'m the yellow mushroom, Shoobly! I won\'t lose to you!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shaably_[you]']={
                {sp=374,col=2,'I\'m the red mushroom, Shaably! My enemies fear me!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Sheebly_[Picross magic]']={
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, '[Picross magic] allows me to Leech! It makes me feel a surge of power!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shoobly_[Picross magic]']={
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'My Poison magic is unrivalled in its efficiency!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shaably_[Picross magic]']={
                {sp=374,col=2,'I\'ll Spore you up!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Sheebly_[monster generals]']={
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'They\'re the backbone of our monster army!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shoobly_[monster generals]']={
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'Nobody can take on the [monster generals] and survive!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shaably_[monster generals]']={
                {sp=374,col=2,'Without them, where would we be? Just waiting for someone to beat us up?'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Sheebly_[giant mushroom]']={
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Ooh, the General! I adore him! Maybe one day I\'ll grow as big as him!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shoobly_[giant mushroom]']={
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'He uses Poison magic really creatively! It\'s exquisite!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shaably_[giant mushroom]']={
                {sp=374,col=2,'Only us shrooms know how to reach the General!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Sheebly_[quest]']={
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'My [quest]? Right now it\'s to Leech you dry!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shoobly_[quest]']={
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end, 'I just want to be useful to the General.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Shaably_[quest]']={
                {sp=374,col=2,'As much as I like sharing with Sheebly and Shoobly, maybe a house of my own would be nice.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Maneki_[quest]']={
                {sp=368,col=2,'To get 999999999 gold!!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Maneki_[monster generals]']={
                {sp=368,col=2,'It\'s really peaceful in this dungeon because there\'s no generals bossing us around.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Maneki_[giant mushroom]']={
                {sp=368,col=2,'It ain\'t in this dungeon, that\'s for sure!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Maneki_[Picross magic]']={
                {sp=368,col=2,'I wonder if I\'ll be able to buy some magic!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Maneki_[you]']={
                {sp=368,col=2,'I\'m just a cat born under a lucky star!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MunSlime_[you]']={
                {sp=326,col=6,'My existence is slime.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MunSlime_[Picross magic]']={
                {sp=326,col=6,'I don\'t need magic, I\'ve got a nasty bite!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MunSlime_[giant mushroom]']={
                {sp=326,col=6,'I wanna take a bite out of him!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MunSlime_[monster generals]']={
                {sp=326,col=6,'Bah, they\'re overrated.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_MunSlime_[quest]']={
                {sp=326,col=6,'One day I will devour the world!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Rival_[quest]']={
                {sp=269,'I won\'t settle for small dreams! I want to become one of the [monster generals]!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Rival_[monster generals]']={
                {sp=269,'They\'re small fry compared to me! Hah!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Rival_[you]']={
                {sp=269,'I\'m the best and you know it!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Rival_[Picross magic]']={
                {sp=269,'Magic is awesome and I\'ll do everything to become the best at it!'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['query_Rival_[giant mushroom]']={
                {sp=269,'I think I saw a glimpse of it outside.'},
                {f=function() clip(); TIC=allyturn; allyi=2; sc_t=t+1 end},
        },
        ['sc_2_bosstest']={
                {sp=41,'Uaaargh!'},
                {f=function() clip(); TIC=turn end},
        },
        ['boss1_weakest']={
                {sp=41,'THE WEAKEST MUST GO!'},
                {f=function() clip(); TIC=turn_boss end},
        },
        ['boss1_win']={
                {sp=41,'IMPOSSIBLE!'},
                {sp=374,col=3,pal=function() pal(1,3); pal(2,4); end,'My General, surely this is only a temporary setback!'},
                {sp=374,col=2,'Oh no! I\'m already feeling the aura of this area collapse!'},
                {sp=374,col=8,pal=function() pal(1,8); pal(2,9); end, 'Nobody panic!'},
                {f=function() clip(); endtime=time(); sc_t=t+1; TIC=endofdemo  end},
        },
}

function overworld_music()
        if area==areas[1] and peek(0x13FFC)~=1 then
                music(1)
        end
        if area==areas[2] and peek(0x13FFC)~=2 then
                music(2)
        end
end

savetime=0
function endofdemo()
        cls(2)
        if peek(0x13FFC)~=1 then music(1) end
        if t-sc_t==0 then dist=200 end
        if t-sc_t>=0 and t-sc_t<550 then
        --local tw=print('End of demo.',0,-6,12)
        --print('End of demo.',120-tw/2-dist,40-12+32,12)
        for i=1,#('End of demo.') do
                print(sub('End of demo.',i,i),-dist+120-(#('End of demo.')*6/2)+(i-1)*6,40+2+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
        end
        local tm=savetime+(endtime-starttime)
        local msg=fmt('Time taken: %.2d:%.2d:%.2d',math.floor(tm/(1000*60*60)),math.floor(tm/(1000*60))%60,math.floor(tm/1000)%60)
        local tw=print(msg,0,-6,12)
        print(msg,120-tw/2+dist,40-12+32+16,12)
        if dist>0 then dist=dist-2 end
        end
        if t-sc_t>=400 and t-sc_t<550 then dist=dist-2 end
        if t-sc_t==550 then TIC=credits; sc_t=t+1 end
        t=t+1
end

function credits()
        cls(2)
        if peek(0x13FFC)~=1 then music(1); poke(0x3FF8,0) end
        
        if t-sc_t==0 then dist=200 end
        if t-sc_t>=0 and t-sc_t<650 then
        spr(425,120-16-dist,40,0,1,0,0,4,4)
        local tw=print('Game by',0,-6,12)
        print('Game by',120-tw/2+dist,40+32+6,12)
        --local tw=print('verysoftwares',0,-6,12)
        for i=1,#('verysoftwares') do
                print(sub('verysoftwares',i,i),dist+120-(#('verysoftwares')*6/2)+(i-1)*6,40+32+6+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
        end
        if dist>0 then dist=dist-2 end
        end
        if t-sc_t>=500 and t-sc_t<650 then
        dist=dist-2
        end
        
        if t-sc_t==650 then dist=200 end
        if t-sc_t>=650 and t-sc_t<650*2 then
        local tw=print('Original concept by',0,-6,12)
        print('Original concept by',120-tw/2-dist,40-12+32,12)
        for i=1,#('Mark Brown') do
                print(sub('Mark Brown',i,i),dist+120-(#('Mark Brown')*6/2)+(i-1)*6,40-12+32+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
        end
        local tw=print('(Game Maker\'s Toolkit)',0,-6,12)
        print('(Game Maker\'s Toolkit)',120-tw/2+dist,40-12+32+16+16,12)
        if dist>0 then dist=dist-2 end
        end
        if t-sc_t>=650+500 and t-sc_t<650*2 then
        dist=dist-2
        end
        
        if t-sc_t==650*2 then dist=200 end
        if t-sc_t>=650*2 and t-sc_t<650*3-140 then
        local tw=print('Additional code by',0,-6,12)
        print('Additional code by',120-tw/2-dist,40-12+32,12)
        for i=1,#('BORB') do
                print(sub('BORB',i,i),dist+120-(#('BORB')*6/2)+(i-1)*6,40-12+32+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
        end
        if dist>0 then dist=dist-2 end
        end
        if t-sc_t>=650*2+500-140 and t-sc_t<650*3-140 then
        dist=dist-2
        end
        
        if t-sc_t==650*3-140 then dist=240 end
        if t-sc_t>=650*3-140 and t-sc_t<650*4+120-140 then
        local tw=print('Special thanks to playtesters,',0,-6,12)
        print('Special thanks to playtesters,',120-tw/2-dist,40,12)
        local tw=print('feedback givers & bug finders, including:',0,-6,12)
        print('feedback givers & bug finders, including:',120-tw/2-dist,40+8,12)
        if dist>0 then dist=dist-2 end
        local msg='Immu Suominen, BORB, Amaunator, Surael,'
        local tw=print(msg,0,-6,12)
        print(msg,120-tw/2+dist,40+8+16,12)
        local msg='Arcy, Prox, Dogtopius, Stepan Krapivin,'
        local tw=print(msg,0,-6,12)
        print(msg,120-tw/2+dist,40+8+16+8,12)
        local msg='olenananas, Lexi Zaninetti, YamaNeko,'
        local tw=print(msg,0,-6,12)
        print(msg,120-tw/2+dist,40+8+16+8+8,12)
        local msg='Malandi, insert-penguin, rdeforest, Pjootrz'
        local tw=print(msg,0,-6,12)
        print(msg,120-tw/2+dist,40+8+16+8+8+8,12)
        end
        if t-sc_t>=650*3+500+120-140 and t-sc_t<650*4+120-140 then
        dist=dist-2
        end
        if t-sc_t==650*4+120-140 then --[[dist=0; TIC=titlescr; sel=nil; sb_tgt='Game';]] reset() end
        
        t=t+1
end

function titlescr()
        cls(2)
        dist=dist or 140
        if dist==140 then music(4) end
        draw_board_ts(5,0,102,11,5,120-2*13-6-1+dist,68-48-7)
        draw_board_ts(5,2,108,7,5,120-2*13-6+12-1-dist,68-6)
        draw_board_ts(5,0,114,11,5,120-2*13-6-1+dist,68+48+7-18)
        if dist>0 then dist=dist-2  end
        if debug then dist=0; while #abd_tiles>0 do append_board() end end
        if dist==0 then
        append_board()
        end
        if #abd_tiles==0 then
                if peek(0x13FFC)~=3 then
                        music(3); poke(0x3FF8,2)
                end
                draw_sidebar_ts()
                local tw=print('Version 3b',0,-6,12)
                print('Version 3b',240-tw-2+1,136-6-2+1,12)
                resolve_ts()
        end
        draw_footer()
        t=t+1
end

function resolve_ts()
        if ((sb_tgt=='Game' and (sel=='New game' or sel=='Load game')) or (sb_tgt=='Credits' and sel=='Play credits')) then
                rect(120+13*2+6+6,68+13*4-3,24,16,13)
                print('Done',120+13*2+6+6+4,68+13*4-3+5,12,false,1,true)
                rectb(120+13*2+6+6,68+13*4-3,24,16,t*FLASH_SPD)
                -- press 'done' button
                if left and not leftheld then
                        if AABB(mox,moy,1,1,120+13*2+6+6,68+13*4-3,24,16) then
                                sfx(8,12*6,6,3)
                          if sel=='New game' then
                                TIC=overworld
                                starttime=time()
                                t=-1
                                end
                                if sel=='Load game' then
                                loaddata()
                                --shout('Game loaded!')
                                end
                                if sel=='Play credits' then
                                TIC=credits
                                sc_t=t+1
                                dist=nil
                                end
                                music()
                        end
                end
        end
end

options={
        'Text anim',
        'Flashing',
        ['Text anim']={'ON','OFF'},
        ['Flashing']={'MED','FAST','SLOW'},
}

function draw_sidebar_ts()
        leftheld=left
        mox,moy,left,_,right,_,mwv=mouse()

        -- left bar
        sb_tgt=sb_tgt or 'Game'

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
        sh=sh+(#shop_inv+1)*7
        
        if sh>64+8+8 and -sb_cam.y+6*8+4+24+7-7<sh then
        rect(6,6*8+4+64+8+8-7,56-4,7,12)
        tri(6+(56-4)/2,6*8+4+64+8+8-7+7-1,6+(56-4)/2+4,6*8+4+64+8+8-7-1,6+(56-4)/2-4,6*8+4+64+8+8-7-1,13)
        if (left and not leftheld and AABB(mox,moy,1,1,6,6*8+4+64+8+8-7,56-4,7)) or (mwv<0 and AABB(mox,moy,1,1,4,6*8+4,56,64+8+8)) then
                if sb_cam.y==0 then sb_cam.y=sb_cam.y-8
                else sb_cam.y=sb_cam.y-7 end
                leftheld=true
        end
        end
        
        rectb(4,6*8+4,56,64+8+8-20-10,13)
        
        if sb_tgt=='Game' then

        if sb_cam.y+6*8+4+2>6*8+4+1 then
        rect(6,sb_cam.y+6*8+4+2,56-4,6+1,1)
        print('Game',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
        end
        
        for i,item in ipairs({'New game','Load game'}) do
                if sb_cam.y+6*8+7*(i-1)+7+7+6>6*8+4+2 and (sb_cam.y+6*8+7*(i-1)+7+6<6*8+4+64+8+8-1-1 or -sb_cam.y+6*8+4+7-7+1>=sh) then
                if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,4)
                    if left and not leftheld and not (item=='Load game' and pmem(0)==0) then
                            sfx(8,12*6,6,3)
                            sel=item
                    end
                end
                if sel==item then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,5)
                end
                if item=='Load game' and pmem(0)==0 then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,13)
                end
                print(item,6+1,sb_cam.y+6*8+7*(i-1)+7+7,12,false,1,true)
                end
        end
                
        elseif sb_tgt=='Options' then
                --if sb_cam.y+6*8+4+2>6*8+4+1 then
                rect(6,sb_cam.y+6*8+4+2,56-4,6+1,1)
                print('Options',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
                
                for i,item in ipairs(options) do
                if sb_cam.y+6*8+7*(i-1)+7+7+6>6*8+4+2 and (sb_cam.y+6*8+7*(i-1)+7+6<6*8+4+64+8+8-7-1-1 or -sb_cam.y+6*8+4+7-7+1>=sh) then
                if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,4)
                    if item=='Text anim' then
                            if options[item][1]=='ON' then
                                    describe('Wobbly dialogue text is on.')
                            else
                                    describe('Wobbly dialogue text is off.')
                            end
                    end
                    if item=='Flashing' then
                            if options[item][1]=='MED' then
                                    describe('Medium flashing, suitable for most people.')
                            elseif options[item][1]=='FAST' then
                                    describe('Fast flashing, not suitable for photosensitive people.')
                            elseif options[item][1]=='SLOW' then
                                    describe('Slow flashing, suitable for everyone.')
                            end
                    end
                    if left and not leftheld then
                            local cyc=options[item][1]
                            rem(options[item],1)
                            ins(options[item],cyc)
                            if item=='Text anim' then
                                    if options[item][1]=='OFF' then TEXT_WOB=false end
                                    if options[item][1]=='ON' then TEXT_WOB=true end
                            end
                            if item=='Flashing' then
                                    if options[item][1]=='FAST' then FLASH_SPD=1 end
                                    if options[item][1]=='SLOW' then FLASH_SPD=0.08 end
                                    if options[item][1]=='MED' then FLASH_SPD=0.3 end
                            end
                            sfx(8,12*6,6,3)
                            
                            local opts={}
                            if options['Text anim'][1]=='ON' then opts[1]=1 end
                            if options['Text anim'][1]=='OFF' then opts[1]=2 end
                            if options['Flashing'][1]=='MED' then opts[2]=1 end
                            if options['Flashing'][1]=='FAST' then opts[2]=2 end 
                            if options['Flashing'][1]=='SLOW' then opts[2]=3 end
                            local out1,out2=to32(opts,0,0)
                            pmem(8,out1)
                    end
                end
                print(item..': '..options[item][1],6+1,sb_cam.y+6*8+7*(i-1)+7+7,12,false,1,true)
                end
                end
        
        elseif sb_tgt=='Credits' then

        if sb_cam.y+6*8+4+2>6*8+4+1 then
        rect(6,sb_cam.y+6*8+4+2,56-4,6+1,1)
        print('Credits',6+1,sb_cam.y+6*8+4+2+1,13,false,1,true)
        end
        
        for i,item in ipairs({'Play credits'}) do
                if sb_cam.y+6*8+7*(i-1)+7+7+6>6*8+4+2 and (sb_cam.y+6*8+7*(i-1)+7+6<6*8+4+64+8+8-1-1 or -sb_cam.y+6*8+4+7-7+1>=sh) then
                if AABB(mox,moy,1,1,6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7) then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,4)
                    if left and not leftheld and not (item=='Load game' and pmem(0)==0) then
                            sfx(8,12*6,6,3)
                            sel=item
                    end
                end
                if sel==item then
                    rect(6,sb_cam.y+6*8+7*(i-1)+7+6,56-4,7,5)
                end
                print(item,6+1,sb_cam.y+6*8+7*(i-1)+7+7,12,false,1,true)
                end
        end
                
        end
        -- right bar
        
        rectb(240-56-4,6*8+4,56,64+8+8-20-10,13)
        rect(240-56-4+2,6*8+4+2,56-4,6+1,1)
        print('Menu',240-56-4+2+1,6*8+4+2+1,13,false,1,true)
        
        for i,option in ipairs({'Game','Options','Credits'}) do
                if AABB(mox,moy,1,1,240-56-4+2,6*8+4+2+i*7,56-4,7) then
                        rect(240-56-4+2,6*8+4+2+i*7,56-4,7,4)

                        if left and not leftheld then 
                        sb_tgt=option
                        --[[if sb_tgt~='Leave' then
                                active=nil
                        end
                        if sb_tgt~='Buy' then
                                purchases={}
                        end]]
                        sfx(8,12*6,6,3)
                        end
                        
                end
                if sb_tgt==option then
                  rect(240-56-4+2,6*8+4+2+i*7,56-4,7,5)
                end
                
                print(option,240-56-4+2+1,6*8+4+2+1+i*7,12,false,1,true)
        end
end

abd_tiles={
        {0+11,102,16},
        {0+11,102+1,16},
        {0+11,102+2,16},
        {0+11,102+3,16},
        {0+11,102+4,16},
        
        {11+8,102,16},
        {11+8,102+1,16},
        {11+8,102+2,16},
        {11+8,102+3,16},
        {11+8,102+4,16},

        {11+10,102,16},
        {11+10,102+1,16},
        {11+10,102+2,16},
        {11+10,102+3,16},
        {11+10,102+4,16},
        
        {11+6,102+2,16},
        {11+4,102+2,16},

        {11+1,102,16},
        {11+11+2,102,32},

        {11+1,102+2,16},
        {11+2,102+2,16},
        {11+11+3,102+2,32},
        
        {11+1,102+3,16},
        {11+11+2,102+3,32},     

        {11+11+1,102+4,32},
        {11+11+1,102+1,32},
        
        {11+11+9,102,32},
        
        {11+11+5,102+2,32},
        {11+11+7,102+2,32},
        {11+11+9,102+2,32},

        {11+9,102+3,16},
        {11+9,102+4,16},
        {11+11+9,102+1,32},
        
        {11+2,102+1,16},
        {11+4,102+1,16},
        {11+6,102+1,16},
        {11+11+2+1,102+1,32},
        {11+11+4+1,102+1,32},
        {11+11+6+1,102+1,32},
        
        {11+11+4,102+4,32},
        {11+11+6,102+4,32},
        
        {11+11+7,102+4,32},
        {11+5,102+4,16},
        {11+11+5,102+3,32},
        {11+5,102,16},
        
        {11+11+3,102,32},
        {11+11+4,102,32},
        {11+11+6,102,32},
        {11+11+7,102,32},
        
        {11+11+7,102+3,32},
        {11+6,102+3,16},
        {11+4,102+3,16},
        {11+11+3,102+3,32},
        
        {11+2,102+4,16},
        {11+11+3,102+4,32},
        
        {11+11+2,102,0},
        {11+11+3,102,0},
        {11+11+4,102,0},
        {11+11+6,102,0},
        {11+11+7,102,0},
        {11+11+9,102,0},

        {11+11+1,102+1,0},
        {11+11+3,102+1,0},
        {11+11+5,102+1,0},
        {11+11+7,102+1,0},
        {11+11+9,102+1,0},
        
        {11+11+3,102+2,0},
        {11+11+5,102+2,0},
        {11+11+7,102+2,0},
        {11+11+9,102+2,0},

        {11+11+2,102+3,0},
        {11+11+3,102+3,0},
        {11+11+5,102+3,0},
        {11+11+7,102+3,0},
        
        {11+11+1,102+4,0},
        {11+11+3,102+4,0},
        {11+11+4,102+4,0},
        {11+11+6,102+4,0},
        {11+11+7,102+4,0},
        
        {9,108,16},
        {9,108+1,16},
        {9,108+2,16},
        {9,108+3,16},
        {9,108+4,16},

        {9+1,108,16},
        {9+7+2,108,32},
        {9+7+1,108+1,32},
        {9+1,108+2,16},
        {9+7+2,108+2,32},
        {9+7+1,108+3,32},
        {9+1,108+4,16},
        {9+7+2,108+4,32},
        
        {9+2,108+1,16},
        {9+2,108+3,16},

        {9+7+3,108,32},
        {9+7+3,108+1,32},
        {9+7+3,108+2,32},
        {9+7+3,108+3,32},
        {9+7+3,108+4,32},
        
        {9+4,108+1,16},
        {9+7+5,108+1,32},
        {9+6,108+1,16},
        
        {9+7+4,108+3,32},
        {9+7+4,108+4,32},
        {9+7+6,108+3,32},
        {9+7+6,108+4,32},
        {9+5,108+2,16},
        {9+5,108+3,16},
        {9+5,108+4,16},

        {9+7+4,108+2,32},
        {9+7+6,108+2,32},
        {9+4,108,16},
        {9+7+5,108,32},
        {9+6,108,16},
        
        {9+7+2,108,0},
        {9+7+3,108,0},
        {9+7+5,108,0},
        {9+7+1,108+1,0},
        {9+7+3,108+1,0},
        {9+7+5,108+1,0},
        {9+7+2,108+2,0},
        {9+7+3,108+2,0},
        {9+7+4,108+2,0},
        {9+7+6,108+2,0},
        {9+7+1,108+3,0},
        {9+7+3,108+3,0},
        {9+7+4,108+3,0},
        {9+7+6,108+3,0},
        {9+7+2,108+4,0},
        {9+7+3,108+4,0},
        {9+7+4,108+4,0},
        {9+7+6,108+4,0},
        
        {11+11+3,114,32},
        {11+11+3,114+1,32},
        {11+11+3,114+2,32},
        {11+11+3,114+3,32},
        {11+11+3,114+4,32},
        {11+11+7,114,32},
        {11+11+7,114+1,32},
        {11+11+7,114+2,32},
        {11+11+7,114+3,32},
        {11+11+7,114+4,32},
        
        {11+10,114,16},
        {11+10,114+1,16},
        {11+10,114+2,16},
        {11+10,114+3,16},
        {11+10,114+4,16},
        {11+8,114,16},
        {11+8,114+1,16},
        {11+8,114+2,16},
        {11+8,114+3,16},
        {11+8,114+4,16},
        {11,114,16},
        {11,114+1,16},
        {11,114+2,16},
        {11,114+3,16},
        {11,114+4,16},
        
        {11+9,114+4,16},
        {11+9,114+3,16},
        {11+11+9,114+2,32},
        {11+11+9,114+1,32},
        {11+11+9,114+0,32},
        
        {11+6,114+2,16},
        {11+4,114+2,16},
        {11+1,114+2,16},
        {11+2,114+2,16},
        {11+11+5,114+2,32},
        
        {11+11+1,114+1,32},
        {11+2,114+1,16},
        {11+4,114+1,16},
        {11+11+5,114+1,32},
        {11+6,114+1,16},
        
        {11+11+4,114+4,32},
        {11+11+6,114+4,32},
        {11+5,114+4,16},
        {11+11+1,114+4,32},
        {11+2,114+4,16},
        
        {11+1,114+3,16},
        {11+11+2,114+3,32},
        {11+4,114+3,16},
        {11+11+5,114+3,32},
        {11+6,114+3,16},
        
        {11+1,114,16},
        {11+11+2,114,32},
        {11+11+4,114,32},
        {11+5,114,16},
        {11+11+6,114,32},
        
        {11+11+2,114,0},
        {11+11+3,114,0},
        {11+11+4,114,0},
        {11+11+6,114,0},
        {11+11+7,114,0},
        {11+11+9,114,0},

        {11+11+1,114+1,0},
        {11+11+3,114+1,0},
        {11+11+5,114+1,0},
        {11+11+7,114+1,0},
        {11+11+9,114+1,0},
        
        {11+11+3,114+2,0},
        {11+11+5,114+2,0},
        {11+11+7,114+2,0},
        {11+11+9,114+2,0},

        {11+11+2,114+3,0},
        {11+11+3,114+3,0},
        {11+11+5,114+3,0},
        {11+11+7,114+3,0},
        
        {11+11+1,114+4,0},
        {11+11+3,114+4,0},
        {11+11+4,114+4,0},
        {11+11+6,114+4,0},
        {11+11+7,114+4,0},
}

function append_board()
        local tile=abd_tiles[1]
        if not tile then return end
        mset(tile[1],tile[2],tile[3])
        rem(abd_tiles,1)
        --abd_tiles.i=abd_tiles.i+1
end

function draw_board_ts(grid,mx,my,mw,mh,bx,by)
        rect(bx+1,by+1,(grid+1)*mw-2,(grid+1)*mh-2,14)

        for sqx=0,mw-1 do
        for sqy=0,mh-1 do
                rect(bx+sqx*(grid+1)+1,by+sqy*(grid+1)+1,grid,grid,13)
                if mget(mx+mw+sqx,my+sqy)==16 then
                rect(bx+sqx*(grid+1),by+sqy*(grid+1),grid,grid,0)
                else
                rect(bx+sqx*(grid+1),by+sqy*(grid+1),grid,grid,12)
                end
                if mget(mx+mw*2+sqx,my+sqy)==32 then
                        local xx=32
                        local offset=0
                        if grid==10 then offset=-1 end
                        if grid==8 then offset=-2 end
                        if grid==7 then xx=48; offset=-3 end
                        if grid==6 then xx=64; offset=-3 end
                        if grid==5 then xx=48; offset=-4 end
                        spr(xx,offset+bx+sqx*(grid+1)+2,offset+by+sqy*(grid+1)+2,12)
                end
        end
        end
        
        draw_num_ts(grid,mx,my,mw,mh,bx,by)
end

function draw_num_ts(grid,mx,my,mw,mh,bx,by)
        local lx,ly=0,0
        for ly=0,mh-1 do
        local tabs={}
        local combo=0
        lx=0
        while lx<=mw-1 do
                local c=mget(mx+lx,my+ly)
                if c==16 then combo=combo+1 end
                if (c==0 or lx==mw-1) and combo>0 then
                        ins(tabs,combo)
                        combo=0
                end
                lx=lx+1
        end
        local num=tostring(tabs[1])
        if num=='nil' then num='0' end
        for tb=2,#tabs do
                num=num..fmt(' %d',tabs[tb])
        end
        local offset=0
        if grid==10 then offset=-1 end
        if grid==8 then offset=-2 end
        if grid==7 then offset=-3 end
        if grid==6 then offset=-4 end
        if grid==5 then offset=-4 end
        print(num,bx-1-#num*4,offset+by+4+ly*(grid+1),12,true,1,true)
        end
    
        local lx,ly=0,0
        for lx=0,mw-1 do
        local tabs={}
        local combo=0
        ly=0
        while ly<=mh-1 do
                local c=mget(mx+lx,my+ly)
                if c==16 then combo=combo+1 end
                if (c==0 or ly==mh-1) and combo>0 then
                        ins(tabs,combo)
                        combo=0
                end
                ly=ly+1
        end
        local num=tostring(tabs[1])
        if num=='nil' then num='0' end
        for tb=2,#tabs do
                num=num..fmt('\n%d',tabs[tb])
        end
        local offset=0
        if grid==10 then offset=-1 end
        if grid==8 then offset=-2 end
        if grid==7 then offset=-3 end
        if grid==6 then offset=-4 end
        if grid==5 then offset=-4 end
        print(num,offset+bx-1+6+lx*(grid+1),by-4-#num/2*6,12,true,1,true)
        end
end

if debug then
        mset(9,42,65); mset(12,42,65); mset(15,45,65); mset(15,39,65); mset(38,37,65); --[[mset(47,34,65); mset(50,40,65);]] mset(38,46,65); mset(56,37,65); mset(76,42,65)
        plrspells={}
        for k,s in pairs(spells) do
        --if not (k=='Query') then
        ins(plrspells,k)
        plrspells[k]=register_spell(k)
        --end
        end
        for i=0,15,5 do
        ins(plrpicross,picross[fmt('%d:%d',i,0)])
        end
        for i,a in ipairs(areas) do
        if i~=2 then
        a.roaming={}
        end
        end
end

-- save/load funcs by BORB
        flr=math.floor
        function has(tbl,val)--returns which key
            for k,v in pairs(tbl)do if v==val then return k end end
            return false
        end
        function boolToBin(b)return b and 1 or 0 end
        function binToBool(b)return b==1 and true or false end
        function to32(tbl,bit,j)
            for i,v in ipairs(tbl) do
                if has({"boolean","nil"},type(v))then
                    bit=bit+(boolToBin(v)<<j)
                    j=j+1
                elseif type(v)=="number" then
                    bit=bit+(flr(v)<<j)
                    j=j+8--8-bit integers 0..255
                elseif type(v)=="table" then
                    bit,j=to32(v,bit,j)
                end
                if j>32 then trace("liian iso taulukko")end
            end
            return bit,j
        end
        function from32(val,tbl,j)
            for i,v in ipairs(tbl) do
                if has({"boolean","nil"},type(v))then
                    tbl[i]=binToBool(val>>j&1)
                    j=j+1
                elseif type(v)=="number" then
                    tbl[i]=val>>j&255
                    j=j+8
                elseif type(v)=="table" then
                    tbl[i],j=from32(val,tbl[i],j)
                end
            end
            return tbl,j
        end

src_locations={
        -1,
        {9,42},
        {12,42},
        {15,39},
        {15,45},
        -1,--rival1
        {38,37},
        {38,46},
        {76,42}, 
        {47,46}, 
        {44,40}, 
        {47,34}, 
        {50,40},
        {56,37},
        -1,--ShyFairy
}

src_keywords={
    '[monster generals]','[giant mushroom]','[you]','[Picross magic]','[quest]'
}

spellorder={
'SmolHeal','MedHeal','Meteor','Lightning','Query','Buff','Taunt','Ice','Flame','Spore','AntiSpore','Poison','AntiPsn','Leech','SoulLeech','Mine','Reflect','Flee',
}

shoporder={
        'Potion','Potion','Potion','MedHeal','Attack+','PermaBubble','Sponge','Photo','Photo','IceSword',
}

function savedata()
        --pmem(0-2): encounters
        --pmem(3-4): spells
        --pmem(5): cur area, plr hp 
        --         and world progress
        --pmem(6): merchant data
        --pmem(7): experience
        --pmem(8): game options
        --pmem(9-13): Picross state 
        --pmem(14-15): Picross abilities
        --pmem(16): level & dialogue progress
        --pmem(17): elapsed time
        --pmem(18): keywords
        local locations={
        }
        for i,v in ipairs(src_locations) do
                if v~=-1 then
                locations[i]=mget(v[1],v[2])==65
                else
                if i==1 then locations[i]=true 
                elseif i==5+1 then locations[i]=#(areas[1].roaming)==0
                elseif i==14+1 then
                        locations[14+1]=true
                        for i,v in ipairs(areas[2].roaming) do
                                if v.sp==507 then locations[14+1]=false; break end
                        end
                end
                end
        end
        local out1,out2=to32(locations,0,0)
        pmem(0,out1)
        
        local savespells={
        }
        for i,v in ipairs(spellorder) do
                if find(plrspells,v) then savespells[i]=true
                else savespells[i]=false end
        end
        local out1,out2=to32(savespells,0,0)
        pmem(3,out1)
        
        local savearea={
        }
        for i,v in ipairs(areas) do
                if v==area then savearea[1]=i; break end
        end
        ins(savearea,plr.hp)
        ins(savearea,plr.maxhp)
        ins(savearea,shrooms==3)
        local out1,out2=to32(savearea,0,0)
        pmem(5,out1)
        
        local merch={
        }
        local i=1
        local j=1
        while i<=#shoporder do
                if (shop_inv[j]==shoporder[i]) then
                        --trace(fmt('shop_inv[%d]: %s',j,shop_inv[j]))
                        --trace(fmt('shoporder[%d]: %s',i,shoporder[i]))
                        merch[i]=false
                        --trace(fmt('merch[%d]=%s',i,tostring(merch[i])))
                        i=i+1
                        j=j+1
                else
                        merch[i]=true
                        --trace(fmt('merch[%d]=%s',i,tostring(merch[i])))
                        i=i+1
                end
                --trace('\n')
        end
        local out1,out2=to32(merch,0,0)
        --trace(out1)
        pmem(6,out1)
        --trace(out2)
        
        pmem(7,exp)
        local proglist={cur_lv,lvl_tgt,has_read('sc_2_feedback'),diag_db['sc_2_avenge']~=nil,has_read('sc_2_shroom_bros2'),has_read('sc_2_shroom_bros'),has_read('sc_2_merch_intro')}
        local out1,out2=to32(proglist,0,0)
        pmem(16,out1)
        
        --pmem(8) is saved during options
        
        save_pic1={mx,my,mw,mh}
        save_pic2={}
        save_pic3={}
        save_pic4={}
        save_pic5={}
        
        local tg=save_pic2
        local i=0
        for sqy=0,mh-1 do
        for sqx=0,mw-1 do
                ins(tg,mget(239-mw*2+1+sqx,135-mh+1+sqy)==16)
                i=i+1
                if i>=32 then tg=save_pic3 end
                if i>=64 then tg=save_pic4 end
                if i>=96 then tg=save_pic5 end
        end
        end
        
        for i=1,5 do
        local out1,out2=to32(_G['save_pic'..tostring(i)],0,0)
        pmem(9+i-1,out1)
        end
        
        local save_abl1={}
        local save_abl2={}
        local tg=save_abl1
        for i,p in ipairs(plrpicross) do
                ins(tg,picno[p])
                if i>=4 then tg=save_abl2 end
                if i>=8 then break end
        end
        
        local out1,out2=to32(save_abl1,0,0)
        pmem(14,out1)
        local out1,out2=to32(save_abl2,0,0)
        pmem(15,out1)
        
        pmem(17,math.floor(savetime+(time()-starttime)))
        trace(fmt('savetime: %d',math.floor(savetime+(time()-starttime))))
        
        local savewords={}
        for i,v in ipairs(src_keywords) do
                if find(keywords,v) then savewords[i]=true
                else savewords[i]=false end
        end
        local out1,out2=to32(savewords,0,0)
        pmem(18,out1)
        
        shout('Game saved!')
end

function loaddata()
        if pmem(0)==0 then shout('Game not loaded...') return end
        --else shout('Game loaded!') end

        reset_encounter()
        
        local locations={
        }
        for i=1,15 do ins(locations,false) end
        
        from32(pmem(0),locations,0)
        trace('Loaded')
        for i,v in ipairs(locations) do
                if src_locations[i]~=-1 then
                        if v then mset(src_locations[i][1],src_locations[i][2],65)
                        else mset(src_locations[i][1],src_locations[i][2],49) end
                else
                        if i==1 then
                                -- just a placeholder to mark existing save file
                        elseif i==5+1 then
                                if v then areas[1].roaming={} 
                                else areas[1].roaming={{sp=506,tx=21,ty=42,x=21*8,y=(42-34)*8,spawn=function() 
                                start_dialogue('sc_1_telepathy')
                                end}}
                                end
                        elseif i==14+1 then
                                if v then
                                  areas[2].roaming={{sp=160,tx=47,ty=43,x=(47-30)*8,y=(43-34)*8,spawn=function()
                                        TIC=overworld_fadeout; cur_encounter=encounters['merchant1']; fr=260; fa=21
                                        end}}
                                else
                                  areas[2].roaming={{sp=507,tx=38,ty=43,x=(38-30)*8,y=(43-34)*8,spawn=function()
                                        TIC=overworld_fadeout; cur_encounter=encounters['sc_2_shyfairy']; fr=260; fa=21
                                        end},
                                        {sp=160,tx=47,ty=43,x=(47-30)*8,y=(43-34)*8,spawn=function()
                                        TIC=overworld_fadeout; cur_encounter=encounters['merchant1']; fr=260; fa=21
                                        end}}
                                end
                        end
                end
        end

        local savespells={
        }
        for i=1,#spellorder do
        savespells[i]=false
        end
        from32(pmem(3),savespells,0)
        plrspells={}
        for i,v in ipairs(savespells) do
                if v then ins(plrspells,spellorder[i]);
                plrspells[spellorder[i]]=register_spell(spellorder[i])
                end
        end
        
        local savearea={0,0,0,false}
        from32(pmem(5),savearea,0)
        area=areas[savearea[1]]
        --if area==nil then area=areas[1] end
        if area==areas[1] then wldplr.tx=3; wldplr.ty=42; wldplr.x=(3-0)*8; wldplr.y=(42-34)*8 end
        if area==areas[2] then wldplr.tx=32; wldplr.ty=37; wldplr.x=(32-30)*8; wldplr.y=(37-34)*8 end
        if area==areas[3] then wldplr.tx=73; wldplr.ty=36; wldplr.x=(73-60)*8; wldplr.y=(36-34)*8 end
        if area==areas[4] then wldplr.tx=104; wldplr.ty=49; wldplr.x=(104-90)*8; wldplr.y=(49-34)*8 end
        plr.hp=savearea[2]
        plr.maxhp=savearea[3]
        plr.origmaxhp=plr.maxhp
        if savearea[4] then for i,v in ipairs({{tx=53,ty=38,id=35},{tx=53,ty=39,id=35},{tx=53,ty=40,id=33},{tx=54,ty=40,id=34},{tx=55,ty=40,id=34},{tx=56,ty=40,id=33},{tx=56,ty=41,id=35},{tx=56,ty=42,id=35},{tx=56,ty=43,id=49}}) do mset(v.tx,v.ty,v.id) end end

        local merch={}
        for i=1,#shoporder do
                merch[i]=false
        end
        from32(pmem(6),merch,0)
        while #shop_inv>0 do
                rem(shop_inv,1)
        end
        for i,v in ipairs(merch) do
                -- not bought/bought
                if not v then ins(shop_inv,shoporder[i]) 
                else 
                if shoporder[i]=='Sponge' then
                        plr.sponge=true
                elseif shoporder[i]=='PermaBubble' then
                        plr.permabubble=true
                elseif shoporder[i]=='Attack+' then
                        plr.minatk=2; plr.maxatk=7
                elseif shoporder[i]=='IceSword' then
                        plr.icesword=true
                end
                end
        end
        
        exp=pmem(7)
        local proglist={0,0,false,false,false,false,false}
        from32(pmem(16),proglist,0)
        cur_lv=proglist[1]
        lvl_tgt=proglist[2]
        if proglist[3] then diag_db['sc_2_feedback'].i=1 end
        if proglist[4] then diag_db['sc_2_avenge']={i=1} end
        if proglist[5] then diag_db['sc_2_shroom_bros2'].i=1 end
        if proglist[6] then diag_db['sc_2_shroom_bros'].i=1 end
        if proglist[7] then diag_db['sc_2_merch_intro'].i=1 end
        --cur_lv=0
        --for i,v in ipairs(levels) do
        --      if v>exp then lvl_tgt=i; break end
        --      cur_lv=cur_lv+1
        --end
                
        wldplr.tgt=nil
        
        load_opts()
        
        TIC=overworld_roaming
        sc_t=t+1
        header={msg={},t=0}

        clear_picross()

        local save_pic1={mx,my,mw,mh}
        from32(pmem(9),save_pic1,0)
        mx=save_pic1[1]; my=save_pic1[2]; mw=save_pic1[3]; mh=save_pic1[4]
        if mw==5 then grid=12 end
        if mw==6 then grid=10 end
        if mw==7 then grid=8 end
        if mw==8 then grid=7 end
        if mw==9 then grid=6 end
        if mw==10 then grid=5 end
        
        save_pic2={}
        save_pic3={}
        save_pic4={}
        save_pic5={}
        
        local tg=save_pic2
        local i=0
        for sqy=0,mh-1 do
        for sqx=0,mw-1 do
                ins(tg,false)
                i=i+1
                if i>=32 then tg=save_pic3 end
                if i>=64 then tg=save_pic4 end
                if i>=96 then tg=save_pic5 end
        end
        end
        
        for i=2,5 do
        from32(pmem(9+i-1),_ENV['save_pic'..tostring(i)],0,0)
        end
        
        local i=0
        local ioff=0
        local tg=save_pic2
        for sqy=0,mh-1 do
        for sqx=0,mw-1 do
                if tg[i-ioff+1] then mset(239-mw*2+1+sqx,135-mh+1+sqy,16); mset(239-mw+1+sqx,135-mh+1+sqy,16)
                else mset(239-mw*2+1+sqx,135-mh+1+sqy,0); mset(239-mw+1+sqx,135-mh+1+sqy,0) end
                i=i+1
                if i>=32 then ioff=32; tg=save_pic3 end
                if i>=64 then ioff=64; tg=save_pic4 end
                if i>=96 then ioff=96; tg=save_pic5 end
        end
        end

        plrpicross={}

        local save_abl1={0,0,0,0}
        local save_abl2={0,0,0,0}
        local tg=save_abl1
        from32(pmem(14),save_abl1,0)
        from32(pmem(15),save_abl2,0)
        local ioff=0
        for i=0,7 do
                --trace(i-ioff+1)
                --trace(tg[i-ioff+1])
                --trace(rev_picno(tg[i-ioff+1]))
                if tg[i-ioff+1]~=0 then ins(plrpicross,rev_picno(tg[i-ioff+1])) end
                if i>=3 then ioff=4; tg=save_abl2 end
        end
        
        local savewords={false,false,false,false,false}
        from32(pmem(18),savewords,0)
        keywords={}
        for i,v in ipairs(savewords) do
                if v then ins(keywords,src_keywords[i]) end
        end
        
        savetime=pmem(17)
        trace(fmt('savetime: %d',savetime))
        
        starttime=time()
        
        shout('Game loaded!')
end

function load_opts()
        if pmem(8)==0 then return end
        local opts={0,0}
        from32(pmem(8),opts,0)
        local tgt=({'ON','OFF'})[opts[1]]
        local cyc=options['Text anim'][1]
        while cyc~=tgt do
        rem(options['Text anim'],1)
        ins(options['Text anim'],cyc)
        cyc=options['Text anim'][1]
        end
        if cyc=='ON' then TEXT_WOB=true end
        if cyc=='OFF' then TEXT_WOB=false end
        local tgt=({'MED','FAST','SLOW'})[opts[2]]
        local cyc=options['Flashing'][1]
        while cyc~=tgt do
        rem(options['Flashing'],1)
        ins(options['Flashing'],cyc)
        cyc=options['Flashing'][1]
        end
        if cyc=='SLOW' then FLASH_SPD=0.08 end
        if cyc=='MED' then FLASH_SPD=0.3 end
        if cyc=='FAST' then FLASH_SPD=1 end
end

load_opts()

TIC=titlescr
--TIC=overworld

--pmem(0,0)