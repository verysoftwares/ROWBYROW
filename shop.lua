require('shop_data')

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

