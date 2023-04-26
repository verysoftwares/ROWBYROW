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
