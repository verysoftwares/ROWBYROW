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

