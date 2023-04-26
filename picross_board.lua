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
                              --    state=nil
                              end
                    end   end
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
