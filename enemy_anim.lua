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

