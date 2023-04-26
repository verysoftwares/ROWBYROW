require('overworld_data')

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

function draw_overworld()
    cls(area.c)
    if area.c==6 then
        for i=0,17,2 do
            rect(0,i*8,240,8,7)
        end
    end
    --if area.c==14 then
    --    for i=0,30,2 do
    --        rect(i*8,0,8,136,10)
    --    end
    --end
    if area.c==15 then
    map(area.x,area.y,30,1,0,0)
    map(area.x,area.y+1,30,17-2,0,8,0)
    map(area.x,area.y+16,30,1,0,(17-1)*8)
    else
    map(area.x,area.y,30,17,0,0,0)
    end
end

--roaming={}

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

function overworld_music()
    if area==areas[1] and peek(0x13FFC)~=1 then
        music(1)
    end
    if area==areas[2] and peek(0x13FFC)~=2 then
        music(2)
    end
end

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
