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

