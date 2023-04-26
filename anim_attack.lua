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

