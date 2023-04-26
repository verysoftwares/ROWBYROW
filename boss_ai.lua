bossfade=240

bosstiles={
    --{{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2}},
    --{{3,0},{3,1},{3,2},{3,3},{3,4},{3,5},{3,6}},
    --['row3']={{2,3,32},{5,3,32},{0,3},{1,3},{3,3},{4,3},{6,3}},
    --{{4,5,32},{4,0},{4,1},{4,2},{4,3},{4,4},{4,6}},
}

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
                --    bq_target()
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

