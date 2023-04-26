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

function has_read(dg)
    return diag_db[dg].i~=nil
end
