-- title:  ROWBYROW
-- author: verysoftwares
-- desc:   a Picross battle RPG
-- script: lua
-- saveid: ROWBYROW

require('utility')
require('utility_save')
require('save-load')
require('picross')
require('enemy')
require('player')
require('dialogue')
require('anim_attack')
require('anim_enemy')
require('title')
require('shop')
require('boss')
require('query')

debug=false

t=0
x=96
y=24
ins=table.insert
rem=table.remove
fmt=string.format
sub=string.sub
sin=math.sin
cos=math.cos

TEXT_WOB=true
FLASH_SPD=0.3

function match(bt,who)
    for i,v in ipairs(bt) do
        if v[1]==who[1] and v[2]==who[2] and v[3]==who[3] then
            return true
        end
    end
    return false
end

function live_nmy()
    local out=0
    for i,e in ipairs(enemies) do
        if e.hp>0 then out=out+1 end
    end
    return out
end

function live_ally()
    local out=0
    for i,a in ipairs(allies) do
        if a.hp>0 then out=out+1 end
    end
    return out
end

function debug_grid()
    -- grid size debug
    -- Ctrl+left/right keys
    status=status or 1
    if status==1 then
        mw=5;mh=5;grid=12
        if key(63) and btnp(3) then status=2; clear_picross() end
    elseif status==2 then
      mw=6;mh=6;grid=10
        if key(63) and btnp(3) then status=3; clear_picross() end
        if key(63) and btnp(2) then status=1; clear_picross() end
    elseif status==3 then
        mw=7;mh=7;grid=8
        if key(63) and btnp(3) then status=4; clear_picross() end
        if key(63) and btnp(2) then status=2; clear_picross() end
    elseif status==4 then
        mw=8;mh=8;grid=7
        if key(63) and btnp(3) then status=5; clear_picross() end
        if key(63) and btnp(2) then status=3; clear_picross() end
    elseif status==5 then
        mw=9;mh=9;grid=6
        if key(63) and btnp(3) then status=6; clear_picross() end
        if key(63) and btnp(2) then status=4; clear_picross() end
    elseif status==6 then
        mw=10;mh=10;grid=5
        if key(63) and btnp(2) then status=5; clear_picross() end
    end
end

function all_cool()
    if plr.force and #forced==0 then return true end

    for i,sp in ipairs(plrspells) do
        if plrspells[sp].cooldown<=0 and find(forced,sp) then return false end
    end
    if #plrpicross==0 and (plr.force or (plr.atk_cooldown and plr.atk_cooldown>0)) then
    return true
    end
    return false
end

function autotargeting()
    return {'Lightning','SmolHeal','Buff','AntiPsn','AntiSpore','Flame','Flee','Reflect','Upgrade','MedHeal','Summon'}
end


function count_new(sel,args)
    local select=sel or args.select
    local new=0
    local buffd=false
    if not args.who.buff then
    for sqx=0,args.mw-1 do
    for sqy=0,args.mh-1 do
        if mget(args.bx+sqx,args.by+sqy)==0 and mget(args.ax+sqx,args.ay+sqy)==16 then
            new=new+1
        end
    end
    end
    else
        if args.state=='firstclick' then return 1 end
        if args.state=='rowselect' and select=='column' then
            for sqy=0,args.mh-1 do
                if mget(args.bx+args.firsttile.x,args.by+sqy)==16 then buffd=true end
                if mget(args.bx+args.firsttile.x,args.by+sqy)==16 or mget(args.ax+args.firsttile.x,args.ay+sqy)==16 then
                    new=new+1
                end
            end
        end
        if args.state=='rowselect' and select=='row' then
            for sqx=0,args.mw-1 do
                if mget(args.bx+sqx,args.by+args.firsttile.y)==16 then buffd=true end
                if mget(args.bx+sqx,args.by+args.firsttile.y)==16 or mget(args.ax+sqx,args.ay+args.firsttile.y)==16 then
                    new=new+1
                end
            end
        end
    end
    return new,buffd
end

function poisondmg()
    cls(args.bg)
    draw_bg()
    draw_board(args)
    
    if t-sc_t==90 then labels={} end 
    if t-sc_t>=90 and header.t==0 then
        sc_t=t+1
        ::retry::
        if turni<=#enemies then
        if enemies[turni].hp>0 and enemies[turni].poison and header.t==0 then 
                sfx(8,12*6,6,3)
                enemydmg(enemies[turni].poisonstack,turni)
                if enemies[turni].poisonstack>=0 then
                shout(fmt('%s takes poison damage!',enemy_name(enemies[turni])))
                else shout(fmt('%s is healed by the AntiPsn in its veins!',enemy_name(enemies[turni]))) end
                turni=turni+1
        elseif enemies[turni].hp==0 or not enemies[turni].poison then turni=turni+1; goto retry end
        --if TIC==poisondmg and header.t==0 then turni=turni+1 end--TIC=enemyturn 
        else
            if plr.hp==0 then
                TIC=gameover
            elseif enemyclear() then
                gain_exp()
                TIC=victory
            else
            TIC=turn
            end
        end
    end

    draw_labels()
    draw_header()

    t=t+1
end

function pass() end

function gain_exp()
    local expplus=0
    for i,e in ipairs(enemies) do
        if expgain[e.type] then expplus=expplus+expgain[e.type] end
    end
    local extra=0
    if plr.sponge then extra=expplus//4 end
    -- lvl_tgt is used here (instead of cur_lv+1
    -- to not gain the same level twice
    local msg=fmt(' (%d needed for next level)',levels[lvl_tgt]-(exp+expplus+extra))
    if exp+expplus+extra>=levels[lvl_tgt] then
      msg=''
    end
    if not plr.sponge then
    shout(fmt('Victory! Gained %d exp.%s',expplus,msg))
    exp=exp+expplus
    else
    shout(fmt('Victory! Gained %d+%d exp.%s',expplus,extra,msg))
    exp=exp+expplus
    exp=exp+extra
    end
    if exp+expplus+extra>=levels[lvl_tgt] then
        shout('LEVEL UP! Got a board upgrade!')
        ins(plrpicross,'Upgrade')
        cur_lv=cur_lv+1
        lvl_tgt=lvl_tgt+1
        shout('Max HP increased by 5!')
        plr.maxhp=plr.maxhp+5
        plr.origmaxhp=plr.maxhp
    end
end

reflectshout={}
prequeue={}
queue={}

exp=0
if debug then exp=670 end
levels={
    [0]=0,
    [1]=700,
    [2]=1500,
}
cur_lv=0
lvl_tgt=1

function allyturn()
    if allyi==2 and allyi>#allies then TIC=enemyturn; turni=1; sc_t=t+1 end
    if t-sc_t>=90 and header.t==0 then
        sc_t=t+1
        if allyi<=#allies then
        enemydmg(math.random(allies[allyi].minatk,allies[allyi].maxatk),math.random(1,#enemies))
        allies[allyi].nudge=60
        allyi=allyi+1
        else
        TIC=enemyturn
        turni=1
        end
    end

    cls(args.bg)
    draw_bg()
    draw_board(args)
    
    if allyi==1 or (allyi-1>0 and ((not allies[allyi-1].nudge) or (allies[allyi-1].nudge and allies[allyi-1].nudge<30))) then
    if allyi-1>0 and allies[allyi-1].nudge and allies[allyi-1].nudge==30-3 then 
    sfx(8,12*6,6,3) 
    end
    draw_labels()
    end
    
    draw_header()
    
    t=t+1
end

function reset_encounter()
    enemyi=nil
    active=nil
    picrossactive_i=nil
    for i,v in ipairs(plrspells) do
        plrspells[v].cooldown=0
    end
    plr.buff=nil
    plr.taunt=nil
    plr.ice=nil; plr.icestack=0
    plr.spore=nil; plr.sporestack=0
    plr.poison=nil; plr.poisonstack=0
    plr.flame=nil; plr.flamestack=0
    plr.reflect=nil

    plr.maxhp=plr.origmaxhp
    if plr.hp>plr.maxhp then plr.hp=plr.maxhp end
    
    bosspicross={}
end


mx=0; my=0
mw=picross[picross[fmt('%d:%d',mx,my)]].w
mh=picross[picross[fmt('%d:%d',mx,my)]].h

function count_taunt(args)
    local record=10
    for sqx=0,args.mw-1 do
    local c=0
    for sqy=0,args.mh-1 do
    if mget(args.mx+sqx,args.my+sqy)==16 and mget(args.bx+sqx,args.by+sqy)==0 then c=c+1 end
    end
    if c>0 and c<record then record=c end
    end
    for sqy=0,args.mh-1 do
    local c=0
    for sqx=0,args.mw-1 do
    if mget(args.mx+sqx,args.my+sqy)==16 and mget(args.bx+sqx,args.by+sqy)==0 then c=c+1 end
    end
    if c>0 and c<record then record=c end
    end
    return record
end

function draw_bg()
    --rect(0,0,240,6*8,0)
    map(area.x+0,17,30,6,0,0)
    
    --rect(56,6*8-24-6,24,24,1)
    --print('You',56+6,6*8-24-6+9,2,false,1,true)
    
    --for c=0,15 do pal(c,12) end
    --local psp=464
    --if plr.cast then psp=467 end
    --spr(psp,56+5+1,6*8-24-6,0,1,0,0,3,3)
    --spr(psp,56+5,6*8-24-6+1,0,1,0,0,3,3)
    --spr(psp,56+5-1,6*8-24-6,0,1,0,0,3,3)
    --spr(psp,56+5,6*8-24-6-1,0,1,0,0,3,3)
    --pal()

    if not (active=='Flee' and TIC==flee_fadeout) then
    --if (enemyatk=='default' and TIC==enemyturn and turni>1 and t-sc_t>=10 and t-sc_t<=10+12 and not plr.reflect) or (enemyatk=='Leech' and TIC==enemyturn and t-sc_t<=12 and not plr.reflect) or (not rowguess and TIC==enemyturn and turni==1 and sc_t and t-sc_t<=12 and (active=='Meteor' or active=='Lightning' or active=='Leech')) or (TIC==poisondmg and plr.poison and plr.poisonstack>0 and turni==1 and t-sc_t<=12) then
    if plr.blink then
    pal(3,12); pal(4,12); pal(13,12); pal(14,12); pal(15,12)
    plr.blink=plr.blink-1; if plr.blink==0 then plr.blink=nil end
    end
    if plr.cast and not cool then
    spr(467,56+5,6*8-24-6,0,1,0,0,3,3)
    plr.cast=plr.cast-1; if plr.cast==0 then plr.cast=nil end
    elseif not plr.cast and not cool then
    spr(464,56+5,6*8-24-6,0,1,0,0,3,3)
    elseif cool then
    local sp=464
    if t%8<4 then sp=467 end
    spr(sp,56+5,6*8-24-6,0,1,0,0,3,3)
    cool=cool-1; if cool==0 then cool=nil end
    end
    pal()
    end
    
    for i,a in ipairs(allies) do
    if a.hp>0 or (a.t and a.t>0) then
        a.anim=a.anim or 1
        local ax=56+5-(i-1)*30
        if a.nudge then ax=ax+sin(a.nudge/60*math.pi)*8; a.nudge=a.nudge-3; if a.nudge<=0 then a.nudge=nil end end
        if a.type=='AcroBat' then   
            if a.blink then
            pal(8,12); pal(9,12); pal(10,12)
            a.blink=a.blink-1; if a.blink==0 then a.blink=nil end 
            end
            spr(320+(a.anim-1)*3,ax,6*8-24-6+sin(i*12+t*0.1)*3,0,1,1,0,3,3)
            pal()
            if t%8==0 then a.anim=a.anim+1 
                if a.anim>2 then a.anim=1 end
            end
        elseif a.type=='MunSlime' then
            if a.blink then
            pal(1,12); pal(5,12); pal(6,12); pal(7,12)
            a.blink=a.blink-1; if a.blink==0 then a.blink=nil end 
            end
            spr(326+(a.anim-1)*3,ax,6*8-24-6,0,1,1,0,3,3)
            pal()
            if t%12==0 then a.anim=a.anim+1 
                if a.anim>2 then a.anim=1 end
            end
        elseif a.type=='Maneki' then
            if a.blink then
            pal(1,12); pal(2,12); pal(4,12); pal(5,12); pal(13,12); pal(14,12)
            a.blink=a.blink-1; if a.blink==0 then a.blink=nil end 
            end
            spr(368+(a.anim-1)*3,ax,6*8-24-6,0,1,1,0,3,3)
            pal()
            if t%16==0 then a.anim=a.anim+1 
                if a.anim>2 then a.anim=1 end
            end
        end
    end
    end
    
    for i,e in ipairs(enemies) do
    if e.hp>0 or (e.t and e.t>0) or e.type=='Rival' or e.type=='Sheebly' or e.type=='Shoobly' or e.type=='Shaably' then
    e.anim=e.anim or 1
    local ex=160-30+(i-1)*40
    if e.type=='Schwobly' then ex=160-30-40+20 end
    if e.nudge then ex=ex-sin(e.nudge/60*math.pi)*8; e.nudge=e.nudge-3; if e.nudge<=0 then e.nudge=nil end end

    if e.type=='AcroBat' then   
    --if (TIC==enemyturn and t-sc_t<=12 and (active=='Attack' or picross[active] or active=='Meteor' or active=='Lightning' or active=='Leech' or plr.reflect) and turni==1 and rowguess and (enemyi==i or active=='Lightning')) or (TIC==poisondmg and turni-1==i and t-sc_t<=12 and e.poisonstack>0) then
    if e.blink then
    pal(8,12); pal(9,12); pal(10,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(320+(e.anim-1)*3,ex,6*8-24-6+sin(i*12+t*0.1)*3,0,1,0,0,3,3)
    pal()
    if t%8==0 then e.anim=e.anim+1 
        if e.anim>2 then e.anim=1 end
    end
    elseif e.type=='MunSlime' then
    if e.blink then
    pal(1,12); pal(5,12); pal(6,12); pal(7,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(326+(e.anim-1)*3,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    if t%12==0 then e.anim=e.anim+1 
        if e.anim>2 then e.anim=1 end
    end
    elseif e.type=='Maneki' then
    if e.blink then
    pal(1,12); pal(2,12); pal(4,12); pal(5,12); pal(13,12); pal(14,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(368+(e.anim-1)*3,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    if t%16==0 then e.anim=e.anim+1 
        if e.anim>2 then e.anim=1 end
    end
    elseif e.type=='Rival' then
    if e.blink then
    pal(3,12); pal(4,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(470,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    elseif e.type=='Sheebly' then
    pal(1,8); pal(2,9);
    if e.blink then
    pal(1,12); pal(2,12); pal(13,12); pal(14,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(374,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    elseif e.type=='Shoobly' then
    pal(1,3); pal(2,4);
    if e.blink then
    pal(1,12); pal(2,12); pal(13,12); pal(14,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(374,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    elseif e.type=='Shaably' then
    if e.blink then
    pal(1,12); pal(2,12); pal(13,12); pal(14,12)
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(374,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    elseif e.type=='Hidaldi' then
    if e.blink then
    pal(0,12); pal(13,12); pal(14,12);
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(416,ex,6*8-24-6,1,1,0,0,3,3)
    pal()
    elseif e.type=='Burr' then
    if e.blink then
    pal(1,12); pal(3,12); pal(13,12); pal(14,12); pal(15,12); 
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(422,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    elseif e.type=='ShyFairy' then
    if e.blink then
    pal(1,12); pal(4,12); pal(10,12); pal(13,12); pal(14,12);
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(462+(e.anim-1)*(494-462),ex,6*8-24-6+2+sin(i*12+t*0.1)*3,0,1,0,0,2,2)
    if t%8==0 then e.anim=e.anim+1 
        if e.anim>2 then e.anim=1 end
    end
    pal()
    elseif e.type=='Mimic' then
    if e.blink then
    pal(0,12); pal(2,12); pal(14,12);
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    local sp=90
    local flip=0
    if e.anim==2 then sp=93 end
    if e.anim==4 then sp=93; flip=1 end 
    spr(sp,ex,6*8-24-6,1,1,flip,0,3,3)
    if t%16==0 then e.anim=e.anim+1 
        if e.anim>4 then e.anim=1 end
    end
    pal()
    elseif e.type=='Merchant' then
    spr(208,ex,6*8-24-6,0,1,0,0,6,3)
    elseif e.type=='MercRat' then
    if e.blink then
    pal(1,12); pal(2,12); pal(4,12); pal(14,12); pal(15,12);
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(69,ex,6*8-24-6,0,1,0,0,3,3)
    pal()
    elseif e.type=='Schwobly' then
    if e.blink then
    pal(5,12); pal(6,12); pal(7,12); pal(13,12); pal(14,12); pal(15,12);
    e.blink=e.blink-1; if e.blink==0 then e.blink=nil end 
    end
    spr(8,ex,4,2,1,0,0,8,5)
    pal()
    else
    rect(ex,6*8-24-6,24,24,1)
    print('Enemy',ex+3,6*8-24-6+9,2,false,1,true)
    end
    if e.t then e.t=e.t-1; if e.t==0 then e.t=nil end end
    end
    end
    
    if TIC==turn or TIC==bossintro or TIC==turn_boss then
    for i=#allies,2,-1 do
    local a=allies[i]
    if a.hp>0 or (a.t and a.t>0) then
    print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30-1,9,1,false,1,true)
    print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30,9-1,1,false,1,true)
    print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30+1,9,1,false,1,true)
    print(fmt('%.1f/%.1f',a.hp,a.maxhp),56-3+5+(i-1)*30,9+1,1,false,1,true)
    print(fmt('%.1f/%.1f',a.hp,a.maxhp),160-13-20+(i-1)*40,9,12,false,1,true)
    end
    end
    local tc=12
    if plr.hp<=plr.maxhp/3 then tc=2 end
    print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5-1,9,1,false,1,true)
    print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5,9-1,1,false,1,true)
    print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5+1,9,1,false,1,true)
    print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5,9+1,1,false,1,true)
    print(fmt('%.1f/%.1f',plr.hp,plr.maxhp),56-3+5,9,tc,false,1,true)
    for i,e in ipairs(enemies) do
    if e.hp>0 or (e.t and e.t>0) then
    print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40-1,9,1,false,1,true)
    print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40,9-1,1,false,1,true)
    print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40+1,9,1,false,1,true)
    print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40,9+1,1,false,1,true)
    print(fmt('%.1f/%.1f',e.hp,e.maxhp),160-13-20+(i-1)*40,9,12,false,1,true)
    end
    end
    end
    
    line(0,6*8,240,6*8,1)
end

--enemy={hp=30,maxhp=30}
plr={hp=30,maxhp=30,origmaxhp=30,type='Player',minatk=1,maxatk=5,icestack=0,flamestack=0,poisonstack=0,sporestack=0}--reflect=2,
allies={plr}

function enemydmg(n,i)
    --if (enemyatk~='Leech' and active~='Leech') then
    i=i or enemyi 
    --end
    --if turni and (enemyatk=='Leech' or active=='Leech') then
    --if turni>#enemies then i=turni-1
    --else i=turni end
    if not enemies[i] then i=turni-1 end
    i=i or turni
    if not enemies[i] then i=turni end
    --trace(enemyatk)
--    if n<0 and enemies[i] and (plr.reflect or enemies[i].reflect) then enemies[i].reflect=enemies[i].reflect or 0; enemies[i].reflect=enemies[i].reflect-1 if enemies[i].reflect<=0 then enemies[i].reflect=nil; ins(reflectshout,{fmt('%s\'s Reflect wears out!',enemy_name(enemies[i])),orig=enemies[i]}) end plrdmg(n,turni); return end
--    if n>=0 and (enemyatk=='Leech' or active=='Leech') and ((enemies[i].reflect) or (n<0 and plr.reflect)) then
    if n>=0 and enemies[i].reflect then
        shout(fmt('Damage to %s was reflected!',enemy_name(enemies[i])))
        trace('enemy reflects damage')
        ins(prequeue, 1, function() trace('enemyreflect') if enemies[i].reflect then enemies[i].reflect=enemies[i].reflect-1; if enemies[i].reflect==0 then enemies[i].reflect=nil; ins(reflectshout,1,{fmt('%s\'s Reflect wears out!',enemy_name(enemies[i])),orig=enemies[i]}) end end plrdmg(n) end)
        return
    end
    if n<0 and plr.reflect and (enemyatk=='Leech' or active=='Leech') then
        --shout(fmt('Heals to %s were reflected!',enemy_name(enemies[i])))
        trace('enemy reflects heals')
        ins(prequeue, 1, function() plrdmg(n) end)
        trace(#queue)
        return
    end
    --if not enemies[i] then trace('what why not'); return end
    --if enemies[i].reflect and n>=0 then shout(fmt('Damage to %s was reflected!',enemy_name(enemies[i]))); enemies[i].reflect=enemies[i].reflect-1 if enemies[i].reflect<=0 then enemies[i].reflect=nil; shout(fmt('%s\'s Reflect wears out!',enemy_name(enemies[i]))) end plrdmg(n); return end
    --if (enemyatk=='Leech' or active=='Leech') and plr.reflect and n<0 then plr.reflect=plr.reflect-1; if plr.reflect==0 then plr.reflect=nil end plrdmg(n); return end

    if n>=0 then enemies[i].blink=12 end
    
    if enemies[i].hp>0 then
    enemies[i].hp=enemies[i].hp-n
    if enemies[i].hp>enemies[i].maxhp then enemies[i].hp=enemies[i].maxhp end
    if enemies[i].hp<0 then enemies[i].hp=0 end

    if enemies[i].hp==0 then
    -- scale persistence to animation length
    if active=='Attack' then
        enemies[i].t=90
    --[[elseif active=='Meteor' then
        enemies[i].t=180
    elseif active=='Lightning' then
        enemies[i].t=50]]
    elseif picross[active] then
        enemies[i].t=90
    end
    if solved() then enemies[i].t=90 end
    end

    local out=-n
    --if plrspells[active] and active~='Lightning' then out=fmt('%dx%d=%d',new,plrspells[active].mult,n) 
    --elseif active=='Lightning' then out=fmt('%dx%.1f=%.1f',new,plrspells[active].mult,n) end
    label(tolabel(out),160-30+8+(i-1)*40)
    end
end

function enemyclear()
    for i,e in ipairs(enemies) do
        if e.hp>0 then return false end
    end
    return true
end

function allydmg(n,i)
    i=i or 1
    if i==1 then plrdmg(n); return end
    
    if n>=0 then allies[i].blink=12 end

    allies[i].hp=allies[i].hp-n
    if allies[i].hp>allies[i].maxhp then allies[i].hp=allies[i].maxhp end
    if allies[i].hp<0 then allies[i].hp=0 end

    label(tolabel(-n),56+8+5-(i-1)*30)
end

function plrdmg(n,selfinflicted)
  --if n>=0 and (plr.reflect or ((active=='Leech' or enemyatk=='Leech') and enemies[turni].reflect)) then plr.reflect=plr.reflect or 0; plr.reflect=plr.reflect-1; if plr.reflect<=0 then plr.reflect=nil; ins(reflectshout,{'Your Reflect wears out!',orig=plr}) end
        --if plr.reflect then enemies[turni].reflect=enemies[turni].reflect or 0; enemies[turni].reflect=enemies[turni].reflect-1; if enemies[turni].reflect==0 then enemies[turni].reflect=nil; ins(reflectshout,{fmt('%s\'s Reflect wears out!',enemy_name(enemies[i])),orig=enemies[i]}) end return end 
    i=i or enemyi
    i=i or turni
    --trace(plr.reflect)
    --trace(n)
    if n>=0 and plr.reflect then
        shout('Damage to you was reflected!')
        trace('player reflects damage')
        ins(prequeue, 1, function() trace('playerreflect') if plr.reflect then plr.reflect=plr.reflect-1; if plr.reflect==0 then plr.reflect=nil; trace('reflectshout'); ins(reflectshout,1,{'Your Reflect wears out!',orig=plr}) end end 
        local i=turni-1;
        if not rowguess and selfinflicted then 
        i=enemyi
        while not i or enemies[i].hp==0 do
        i=math.random(#enemies)
        end
        end enemydmg(n,i) end)
        return
    end
    if n<0 and (enemyatk=='Leech' or active=='Leech') and (enemies[i].reflect) then
        --shout('Heals to you were reflected!')
        trace('player reflects heals')
        ins(prequeue, 1, function() enemydmg(n,turni-1) end)
        return
    end
    --if plr.reflect and n>=0 then shout('Damage to Player was reflected!'); plr.reflect=plr.reflect-1; if plr.reflect<=0 then plr.reflect=nil; shout('Your Reflect wears out!') end enemydmg(n,turni); return end

    if n>=0 then plr.blink=12 end

    plr.hp=plr.hp-n
    if plr.hp>plr.maxhp then plr.hp=plr.maxhp end
    if plr.hp<0 then plr.hp=0 end

    label(tolabel(-n),56+8+5)
end

labels={}
function label(msg,xpos)
    ins(labels,{msg=msg,x=xpos,y=6*8-12})
end

function tolabel(n)
    if n>0 then return '+'..tostring(n) end
    if n==0 then return '+/-0' end
    return tostring(n)
end

function draw_labels()
    for i=#labels,1,-1 do
        local l=labels[i]
        print(l.msg,l.x,l.y,t*FLASH_SPD)
        l.y=l.y-(l.y-9)*0.1
    end
end

function enemy_name(e)
    local name=e.type
    local similar={}
    for i2,e2 in ipairs(enemies) do
        if e2.type==e.type then
            ins(similar,e2)
        end
    end
    if #similar>1 then
    for i2,e2 in ipairs(similar) do
        if e2==e then name=name..' '..tostring(i2); break end
    end
    end
    return name
end

wldplr={tx=3,ty=42,x=3*8,y=(42-34)*8}

function neighbours(ax,ay)
    local out={}
    if mget(ax+1,ay)==34 then ins(out,{x=ax+3,y=ay}) end
    if mget(ax-1,ay)==34 then ins(out,{x=ax-3,y=ay}) end
    if mget(ax,ay+1)==35 then ins(out,{x=ax,y=ay+3}) end
    if mget(ax,ay-1)==35 then ins(out,{x=ax,y=ay-3}) end
    return out 
end

function pathfind(ent,tx,ty)
    local enc_allowed=false
    ::restart::
    local fx,fy=ent.tx,ent.ty
    local out={{x=fx,y=fy}}
    local final={}

    for i,o in ipairs(out) do
    if i==1 and mget(o.x,o.y)==49 then
        if ent.prevdir=='right' then ins(out,{x=o.x-3,y=o.y,prev=o}) end
        if ent.prevdir=='left' then ins(out,{x=o.x+3,y=o.y,prev=o}) end
        if ent.prevdir=='down' then ins(out,{x=o.x,y=o.y-3,prev=o}) end
        if ent.prevdir=='up' then ins(out,{x=o.x,y=o.y+3,prev=o}) end
        goto skip
    end
    if mget(o.x,o.y)==49 and not enc_allowed then goto skip end
    
    for j,v in ipairs(neighbours(o.x,o.y)) do
        local inlist=false
        for k,q in ipairs(out) do
            if q.x==v.x and q.y==v.y then
                inlist=true
                break
            end
        end
        if not inlist then
        ins(out,v)
        v.prev=o
        end
        if v.x==tx and v.y==ty then
            while v.prev do
                -- the starting tile is skipped
                ins(final,v)
                v=v.prev
            end
            return final
        end
    end
    ::skip::
    if o.x==tx and o.y==ty then
        while o.prev do
            -- the starting tile is skipped
            ins(final,o)
            o=o.prev
        end
        return final
    end
    end

    -- if can't find tx,ty on retry,
    -- return an empty path
    if enc_allowed then return final end

    -- can't find tx,ty:
    -- retry with encounters allowed on path
    -- except for the encounter you're standing on
    enc_allowed=true
    goto restart

end

function fade_pal(c)
    if c==0 then return 0 end
    if c==1 then return 0 end
    if c==2 then return 1 end
    if c==3 then return 2 end
    if c==4 then return 3 end
    if c==5 then return 6 end
    if c==6 then return 7 end
    if c==7 then return 8 end
    if c==8 then return 1 end
    if c==9 then return 8 end
    if c==10 then return 9 end
    if c==11 then return 10 end
    if c==12 then return 13 end
    if c==13 then return 14 end
    if c==14 then return 15 end
    if c==15 then return 1 end
end

fade_palette={
}
for i=0,15 do fade_palette[i]=i end

function flee_fadeout()
    cls(args.bg)
    
    draw_bg()
    draw_board(args)

    if t-sc_t>=120 and header.t==0 then
        if t%16==0 then
            local black=0
            for i=0,15 do
                if fade_palette[i]==0 then black=black+1 end
                fade_palette[i]=fade_pal(fade_palette[i])
                --trace(fmt('%d:%d',i,fade_palette[i]))
                pal(i,fade_palette[i])
            end
            if black==16 then
                reset_encounter()
                sc_t=t+1
                TIC=overworld_roaming
                for i=0,15 do 
                poke4(0x3FF0*2+i,i) 
                fade_palette[i]=i 
                end
                music()
            end
        end
    end

    draw_header()

    t=t+1
end

expgain={
    ['AcroBat']=23,
    ['Maneki']=41,
    ['MunSlime']=34,
    ['Rival']=96,
    ['Burr']=78,
    ['Mimic']=87,
    ['Hidaldi']=82,
    ['Sheebly']=99,
    ['Shaably']=92,
    ['Shoobly']=97,
    ['ShyFairy']=141,
    ['MercRat']=63,
    ['Schwobly']=244,
}

keywords={}

function endofdemo()
    cls(2)
    if peek(0x13FFC)~=1 then music(1) end
    if t-sc_t==0 then dist=200 end
    if t-sc_t>=0 and t-sc_t<550 then
    --local tw=print('End of demo.',0,-6,12)
    --print('End of demo.',120-tw/2-dist,40-12+32,12)
    for i=1,#('End of demo.') do
        print(sub('End of demo.',i,i),-dist+120-(#('End of demo.')*6/2)+(i-1)*6,40+2+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
    end
    local tm=savetime+(endtime-starttime)
    local msg=fmt('Time taken: %.2d:%.2d:%.2d',math.floor(tm/(1000*60*60)),math.floor(tm/(1000*60))%60,math.floor(tm/1000)%60)
    local tw=print(msg,0,-6,12)
    print(msg,120-tw/2+dist,40-12+32+16,12)
    if dist>0 then dist=dist-2 end
    end
    if t-sc_t>=400 and t-sc_t<550 then dist=dist-2 end
    if t-sc_t==550 then TIC=credits; sc_t=t+1 end
    t=t+1
end

function credits()
    cls(2)
    if peek(0x13FFC)~=1 then music(1); poke(0x3FF8,0) end
    
    if t-sc_t==0 then dist=200 end
    if t-sc_t>=0 and t-sc_t<650 then
    spr(425,120-16-dist,40,0,1,0,0,4,4)
    local tw=print('Game by',0,-6,12)
    print('Game by',120-tw/2+dist,40+32+6,12)
    --local tw=print('verysoftwares',0,-6,12)
    for i=1,#('verysoftwares') do
        print(sub('verysoftwares',i,i),dist+120-(#('verysoftwares')*6/2)+(i-1)*6,40+32+6+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
    end
    if dist>0 then dist=dist-2 end
    end
    if t-sc_t>=500 and t-sc_t<650 then
    dist=dist-2
    end
    
    if t-sc_t==650 then dist=200 end
    if t-sc_t>=650 and t-sc_t<650*2 then
    local tw=print('Original concept by',0,-6,12)
    print('Original concept by',120-tw/2-dist,40-12+32,12)
    for i=1,#('Mark Brown') do
        print(sub('Mark Brown',i,i),dist+120-(#('Mark Brown')*6/2)+(i-1)*6,40-12+32+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
    end
    local tw=print('(Game Maker\'s Toolkit)',0,-6,12)
    print('(Game Maker\'s Toolkit)',120-tw/2+dist,40-12+32+16+16,12)
    if dist>0 then dist=dist-2 end
    end
    if t-sc_t>=650+500 and t-sc_t<650*2 then
    dist=dist-2
    end
    
    if t-sc_t==650*2 then dist=200 end
    if t-sc_t>=650*2 and t-sc_t<650*3-140 then
    local tw=print('Additional code by',0,-6,12)
    print('Additional code by',120-tw/2-dist,40-12+32,12)
    for i=1,#('BORB') do
        print(sub('BORB',i,i),dist+120-(#('BORB')*6/2)+(i-1)*6,40-12+32+16+sin(i*0.4+t*0.1)*6,(i*0.1+t*0.3))
    end
    if dist>0 then dist=dist-2 end
    end
    if t-sc_t>=650*2+500-140 and t-sc_t<650*3-140 then
    dist=dist-2
    end
    
    if t-sc_t==650*3-140 then dist=240 end
    if t-sc_t>=650*3-140 and t-sc_t<650*4+120-140 then
    local tw=print('Special thanks to playtesters,',0,-6,12)
    print('Special thanks to playtesters,',120-tw/2-dist,40,12)
    local tw=print('feedback givers & bug finders, including:',0,-6,12)
    print('feedback givers & bug finders, including:',120-tw/2-dist,40+8,12)
    if dist>0 then dist=dist-2 end
    local msg='Immu Suominen, BORB, Amaunator, Surael,'
    local tw=print(msg,0,-6,12)
    print(msg,120-tw/2+dist,40+8+16,12)
    local msg='Arcy, Prox, Dogtopius, Stepan Krapivin,'
    local tw=print(msg,0,-6,12)
    print(msg,120-tw/2+dist,40+8+16+8,12)
    local msg='olenananas, Lexi Zaninetti, YamaNeko,'
    local tw=print(msg,0,-6,12)
    print(msg,120-tw/2+dist,40+8+16+8+8,12)
    local msg='Malandi, insert-penguin, rdeforest, Pjootrz'
    local tw=print(msg,0,-6,12)
    print(msg,120-tw/2+dist,40+8+16+8+8+8,12)
    end
    if t-sc_t>=650*3+500+120-140 and t-sc_t<650*4+120-140 then
    dist=dist-2
    end
    if t-sc_t==650*4+120-140 then --[[dist=0; TIC=titlescr; sel=nil; sb_tgt='Game';]] reset() end
    
    t=t+1
end

options={
    'Text anim',
    'Flashing',
    ['Text anim']={'ON','OFF'},
    ['Flashing']={'MED','FAST','SLOW'},
}

if debug then
    mset(9,42,65); mset(12,42,65); mset(15,45,65); mset(15,39,65); mset(38,37,65); --[[mset(47,34,65); mset(50,40,65);]] mset(38,46,65); mset(56,37,65); mset(76,42,65)
    plrspells={}
    for k,s in pairs(spells) do
    --if not (k=='Query') then
    ins(plrspells,k)
    plrspells[k]=register_spell(k)
    --end
    end
    for i=0,15,5 do
    ins(plrpicross,picross[fmt('%d:%d',i,0)])
    end
    for i,a in ipairs(areas) do
    if i~=2 then
    a.roaming={}
    end
    end
end


src_locations={
    -1,
    {9,42},
    {12,42},
    {15,39},
    {15,45},
    -1,--rival1
    {38,37},
    {38,46},
    {76,42}, 
    {47,46}, 
    {44,40}, 
    {47,34}, 
    {50,40},
    {56,37},
    -1,--ShyFairy
}

src_keywords={
  '[monster generals]','[giant mushroom]','[you]','[Picross magic]','[quest]'
}

spellorder={
'SmolHeal','MedHeal','Meteor','Lightning','Query','Buff','Taunt','Ice','Flame','Spore','AntiSpore','Poison','AntiPsn','Leech','SoulLeech','Mine','Reflect','Flee',
}

shoporder={
    'Potion','Potion','Potion','MedHeal','Attack+','PermaBubble','Sponge','Photo','Photo','IceSword',
}


load_opts()

TIC=titlescr
--TIC=overworld

--pmem(0,0)

-- <TILES>
-- 000:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 005:6666666666666666666666666666666666666666666666666666666666666666
-- 006:3333333333333333333333333333333333333333333333333333333333333333
-- 007:7777777777777777777777777777777766666666666666666666666666666666
-- 008:222222dd22222dcc2222dccc222dccc522dcccc522dcccc52dccccc52dccccc5
-- 009:dddee222ccc6eeee555666dd5556666d55566666555566665555666755556777
-- 010:2222222222222222eeee2222dddeeee2ddddddeeddddddddddddddddddddd555
-- 011:22222222222222222222222222222222e2222222dee22222dddeee2266ddddee
-- 012:2222222222222222222222222222222222222222222222222222222222222222
-- 013:2222222222222222222222222222222222222222222222222222222222222222
-- 014:2222222222222222222222222222222222222222222222222222222222222222
-- 015:2222222222222222222222222222222222222222222222222222222222222222
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 021:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
-- 022:7777777777777777777777777777777777777777777777777777777777777777
-- 023:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
-- 024:dcccccccdccccccc2dcccccc22dccccc222dcccc2222dccc22222dcc222222dd
-- 025:5555577dc55557ddcccccdddcccc5666cc555566c5555566c5555566c5555556
-- 026:ddddd555dddd5556dddd5566dddd6666dddd66666dddd6666ddddd6677ddddd6
-- 027:6666dddd66666ddd666666dd666667dd666677dd66677ddd66677ddd6677dddd
-- 028:eee22222dddeee22dddddeeedddddddeddddddddddddddddddddddd5ddddddd5
-- 029:222222222222222222222222ee222222ddefe222566deffe5666dddf66666ddd
-- 030:222222222222222222222222222222222222222222222222fe222222defff222
-- 031:2222222222222222222222222222222222222222222222222222222222222222
-- 032:22cccc22222cc222c222222ccc2222cccc2222ccc222222c222cc22222cccc22
-- 033:00dccd000cccccc0dcc11ccdcc1111cccc1111ccdcc11ccd0cccccc000dccd00
-- 034:000000000000000000000000cccccccccccccccc000000000000000000000000
-- 035:000cc000000cc000000cc000000cc000000cc000000cc000000cc000000cc000
-- 037:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 038:4444444444444444444444444444444444444444444444444444444444444444
-- 040:2222222222222222222222222222222222222222222222222222222222222222
-- 041:dc5555562ddc5557222dec5722222eed2222222e222222dd222222de222222ed
-- 042:77dddddd7dddddddddddddddddddddddeedddddddfeeedddfddeeffdccddeeef
-- 043:ddddddddddddd666dd556666d5566666555666665566666666666666e6666666
-- 044:dddddd66dddddd666dddddd666dddddd666ddddd666ddddd667ddddd677ddddd
-- 045:66666ddd66667ddd66677dddd67dddddddddddddddddddddddddddddd66dddd7
-- 046:ddddfff2dddde7efdddee777dddee777567eeee7677eeeee777eeeee77eeee77
-- 047:22222222f22222227fff222277eeff2277eefff2eeeefff2eeeefff27eeefff2
-- 048:cccccccccccccccccc2ccc2ccc22c22cccc222cccc22c22ccc2ccc2ccccccccc
-- 049:000cc00000c22c000c1221c0c112211cc111111c0c1221c000c11c00000cc000
-- 050:000000dd000000dd0000dddd0000dddd00dddddd00dddddddddddddddddddddd
-- 056:2222222222222222222222222222222222222222222222222222222222222222
-- 057:22222ccc22222ccf22222ccc2222cced2222ccce2222ccce2222cffc2222cffe
-- 058:ccccddeeffcccdddcccdccddcccccccddcedccccedcecccceececccccecccccc
-- 059:eeffe666eeeeeeffddddddd2ddddddc2cddccccccccccccccccccccccccccccc
-- 060:677dddddffeddddd222effee2222222f22222222222222222222222222222222
-- 061:567ddde766ddeeeeddeeeeeeffffeeee2222ffff222222222222222222222222
-- 062:7eeee777eeeee777eeeeee77eeeeeeeefffffeee22222fff2222222222222222
-- 063:7eeffff27eeffff27efffff2efffff22ffffff22fffff2222222222222222222
-- 064:cccccccccccccccccc2cc2ccccc22cccccc22ccccc2cc2cccccccccccccccccc
-- 065:000cc00000c55c000c7557c0c775577cc777777c0c7557c000c77c00000cc000
-- 066:0000000000000000000000020000002300000033000002330000033300000333
-- 067:0023333223333333333333333333333333333333333202333320000233000000
-- 068:0000000032000000332000003330000033320000333300003333000033330000
-- 069:0000000e0000000e0000000e0000000000000000000000000000000000000000
-- 070:ee0000eeffeeeefffeeeeeefeeeeeeeeeeeeeeeeeffeeffeeeeeeee00eeeee00
-- 071:e0000000e0000000e00000000000000000000000000000000000000000000000
-- 072:2222222222222222222222222222222222222222222222222222222222222222
-- 073:2222cfff22222fff22222fff22222ccc22222cee2222cccc22cccccc2ccccccc
-- 074:ceccccccceccccccccccccccecccccccdccccccccccccccccccccccccccccccc
-- 075:ccccccccccccccccccccccccccccccc2ccccccd2cccdcdd2cccdcccccccccccc
-- 076:2222222222222222222222222222222222222222222222222222222222222222
-- 077:2222222222222222222222222222222222222222222222222222222222222222
-- 078:2222222222222222222222222222222222222222222222222222222222222222
-- 079:2222222222222222222222222222222222222222222222222222222222222222
-- 082:0000033300000333000002330000002300000002000000000000000000000000
-- 083:3300000033000002330000033200023320002333000233330003333300233333
-- 084:3333000033330000333200003320000032000000300000003000000032000000
-- 085:000000000000000c000000cc00000ccc0000ccc2000cccc200cccc220ccccc22
-- 086:0cceecc0cceeeeccc2eee22c222ff22cf24e42f2f22e22f2f24e42f2f22e22f2
-- 087:0000000000000000c0000000cc000000ccc00000cccc00002cccc0002cccc000
-- 088:6666666666666666666666666666666666666666666666666666666666666666
-- 090:1111111111111111111110001011000011000000111000001111111112211111
-- 091:1eeeee11eccccce1ccccccc00ccccc000ccccc00ceeceec0eccccce1e2ccc2e1
-- 092:1111111111111111000111010000001100000111000011111111111111111221
-- 093:111111111111111111111100110110001110000011110000122111112cc2e111
-- 094:11eeeee11eccccce0ccccccc00ccccc000cecec00ccececc1eccccce1e2ccc2e
-- 095:1111111111111111000011100000000100000011000001111111111111111111
-- 099:0033333300233333000233330000022000232000023333200233332000233200
-- 100:3300000032000000200000000000000000000000000000000000000000000000
-- 101:0c0cc022000cc02200cccfff00c0c1110000f11100000ff1000000ff000000ee
-- 102:f24e42f22f2e2f2222fff22ff2eee2f11ffeef11111ff111f111eeeeefffeeee
-- 103:2ccccc0020cc0cc0ffcc000011c0c00011f00000ff000000e0000000e0000000
-- 104:6666666666666666666666666666666666666666666666666666666666666666
-- 106:2cc2eeee2ccccccc2cc2eeee1221111e1111111e111111e2111111ec111111ec
-- 107:cecccececceeecccccccccceccccccceccccccce2ccccc22c2ccc2cccc2c2ccc
-- 108:eeee2cc2ccccccc2eeee2cc21111122111111111e1111111e1111111e1111111
-- 109:2cccceee2cc2eccc12211eee1111111e111111e2111111ec111111ec1111111e
-- 110:11eccceceeceeeccccccccceccccccce2ccccccec2cccc22cc2cc2ccec2c2ccc
-- 111:eee11221ccce2cc2eeecccc2111e2cc211111221e1111111e1111111e1111111
-- 118:5555555555555555555555555555555555555555555555555555555555555555
-- 119:00000000000000000000000a0000000a000000aa000000aa00000aaa0000aaaa
-- 120:0aaa0099aaaa90a9aaaa09a9aaa0909aaaa9090aaa90909aaa090909a0909090
-- 121:0000000090000000990000009900000099000000a9900000a99000009a990000
-- 122:1111111e111111ec11111ecc1111eece1111ece111112c2111112c2111111221
-- 123:ec2e2ceeeee1eecce11111ec1111111e11111111111111111111111111111111
-- 124:11111111e1111111ce111111cee11111ece111112c2111112c21111122111111
-- 125:111111ec11111ecc1111eece1111ece111112c2111112c211111122111111111
-- 126:eeee2ceee111eecc111111ec1111111e11111111111111111111111111111111
-- 127:11111111e1111111ce111111cee11111ece111112c2111112c21111122111111
-- 134:5555555555555555555555555555555555555555555555555555555555555555
-- 135:000aaaaa000aaaaa00aaaaaa00aaaaa000aaaa090aaaaa90aaaa9909999aaaaa
-- 136:a9090909909090900909090990909090090909099090909009090909a999999a
-- 137:0a99000090a9900009a9900090aa9900090a9990909a9990090aaaa9aaaa8888
-- 138:0000000000000000000000ed0000000000000000000000000000000000000000
-- 139:000000000edddddddddddddd000edddd00000ddd000000dd0000002d0000023d
-- 140:00000000dde00000dddd0000ddddd000dddddd00ddddddd0dddddddedddddddd
-- 144:11c1111111cc111111ccc11111cccc1111ccccc111ccc1111111cc111111cc11
-- 150:5555555555555555555555555555555555555555555555555555555555555555
-- 151:0999a9090999a0900099aa0900099aa0000009a90000009a0000000a00000000
-- 152:090909099090909009090909909090900909090990909090a9090909a9900009
-- 153:09aa888890a8888009a888009a8880000a888000a8800000a8000000a0000000
-- 154:0000000000000000000000000000000000000000000000020000002200001233
-- 155:0000233d00022333002233330223333222333322233332203333220033322000
-- 156:dddddddd322ddddd2200dddd20000ddd00000edd000000dd000000ed0000000d
-- 160:0023320003330330230300323002233333322003230030320330333000233200
-- 161:0030000003330000333330000333000003030000000000000000000000000000
-- 163:0002333300000000000000000000000000000000000000000000000000000000
-- 164:3333333302334444000002330000000200232000023432000344430023444300
-- 165:33200000443320004cc3320034cc3300234cc3200234c3300023443000034432
-- 166:0003000000300000000300000000300000030000003430000034300000030000
-- 167:1111111111111111111110001111000011110000111100001110000011100111
-- 168:1111111110000000000000000000000000000000111011100011100010000001
-- 169:1111111101111111000011110000111100000111000001111110011110000111
-- 170:0002233300223333022333330233333202233322002322100002200000000000
-- 171:3322000032100000220000001000000000000000000000000000000000000000
-- 172:0000000e00000000000000000000000000000000000000000000000000000000
-- 176:0066000006007000606c07006066070007007000007700000000000000000000
-- 177:0670000060c70000760700000770000000000000000000000000000000000000
-- 179:0000000200233333233444443444444423444444023444440023344400002344
-- 180:34444320444444304444c4334444cc444444ccc444444cc44444444444444433
-- 181:0002343300002343333203434443224344432033443200233320000320000003
-- 182:0000330000033300003333300332333033322333332222333322223303322330
-- 183:1110000011100011111000111110000011100001111100111111010011110001
-- 184:1100001001000010001001000000000001000100011011101001001010000011
-- 185:0000011111000111110001110000011110000111110001110100111101001111
-- 186:2222222222222222222222222222222222222222222222222222222222222222
-- 187:2222222222222222222222222222222222222222222222222222222222222222
-- 188:2222222222222222222222222222222222222222222222222222222222222222
-- 192:0000000000000000000000000000000000e77777777666767666677700777e00
-- 193:0000000000000000000000000000000077e000006677777776666776e7777777
-- 194:000000000000000000000000000000000e77e000776677006666677777667677
-- 195:0000334400023444002344440034444400344443002344320002332000000000
-- 196:4444443044444432444444433334444320234444000234440000233200000000
-- 197:0000000300000002000000002000000030000000300000000000000000000000
-- 198:0003000000330000003330000333330003323330332223333322233303223330
-- 199:1111001111111000111110001111100011111100111111101111111111111111
-- 200:0000000100111000011111000100010000000000000000000000000111111111
-- 201:0001111110111111001111110111111101111111111111111111111111111111
-- 202:666667667666677677766667667776676667777766677bbb7777bbbbbbbbbbbb
-- 203:6666676676666776777666676677766766677777666773337777333333333333
-- 204:6666676676666776777666676677766766677777666776667777666666666666
-- 205:0ddddddddeeeddddddedddeeddddddeedddddeeedddddeeedddddeee0ddddddd
-- 206:ddddddddeeeeeeeeeeeeeefeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeedddddddd
-- 207:ddddddd0eeeeeffdeeeefffdeeeffffdeeeffffdeeeffffdeefffffdddddddd0
-- 208:0000000c050000cd00550cdd00055cdd0000cd5d000cdd5d0ccdddddcddddddd
-- 209:d0000000c5000000c5500000c5550000cc550000dccc3300dddd3323ddddd322
-- 210:000000000000000000000000000000000000000c0033ccc53233ddcc2233dddc
-- 211:00000000000ccd000dc55c00cc555cd0c55555c0555c55c05cc55cd0cdc55c00
-- 212:0022222202333333023333332222222202333333023333332222222202333333
-- 213:2222220033333320333333202222222232112320321123202211222232112320
-- 214:2222233322223222222323332232333323223333232333333223333332233333
-- 215:3223322223322322322332323333322333333323333333233333332333333322
-- 216:3333333333333323333332323333233232232333233233332332333323333333
-- 217:3333333333333333333333333333333322222222222222222222222222222222
-- 218:0006000000666000006366000636666066666666066360060603360000033000
-- 219:7777777777777777733377773333333377777333777777737777777777777777
-- 220:7777777777777777777733373333333333377777377777777777777777777777
-- 221:000ddddd00dddddd00ddddde00ddddde00ddddde00ddddde00ddddee00ddddee
-- 222:ddddddddeeeeeeeeedeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 223:ddddd000fffffd00effffd00effffd00eefffd00eefffd00eefffd00effffd00
-- 224:cddddcccdcccc00c0000000d0000000000000000000000000000000000000000
-- 225:ddddd322ddddd332cddddd33cdddddd3dcdd33330cdd22220cddccdd0cddcecc
-- 226:223ddddd223ddddd33dddddd3ddddddd3333333322222222ddddccdcccccfcdc
-- 227:c0c55c00c0dc5c00c00cc000c00c000033333333222222220000000000000000
-- 228:0233333322222222023333330223333233333333223322320331103023010030
-- 229:3222232022222222333333202333322033333333233322221003311010003210
-- 230:3223322232332222323322222233222222322222223222222332222223322222
-- 231:3333332233333322233333322333333223333332233333322333333222333332
-- 232:2222222222222222222222222222222222222222222222222222222222222222
-- 233:3333333333333333333333333322332222332233333333333333333333333333
-- 234:0007000000777000007377000737777077777777077370070703370000033000
-- 235:3333333333333333333333333333333333366666366666666666666666666666
-- 236:6666666366666663666666636666663366666633666663336666333366633333
-- 237:000000000000000000000000eeeeeeeeffffffff000000000000000000000000
-- 238:dddddddedeeeeeefdeeeeeefdeeeeeefdeeeeeefdeeeeeefdeeeeeefefffffff
-- 239:feeefeeeeff0eff0eff0eff0e000e000feeefeeeeff0eff0eff0eff0e000e000
-- 241:0cdcce000cdcfe000cdcfe000cdcfe000cdcfe000cccee000cdcfe000cccee00
-- 242:000efcdc000efcdc000efcdc000efcdc000efcdc000eeccc000efcdc000eeccc
-- 244:3010003030100022333333223010000330010003233110030233110300233333
-- 245:1000330133333311110003010100330101003210010330100133110033111000
-- 246:dddddddddeeeeeaddeeeeaaddeeeaaaddeeaaaaddeaaaaaddaaaaaaddddddddd
-- 247:3333333333333222333323333332333333223333332333333223333332233333
-- 248:3333333323322333322332333333322333333323333333233333332333333322
-- 249:3333333333333333333333333333333333333333333333333333333333333333
-- 250:eeeeeeeededdeddeeeeeeeeeddeddeddeeeeeeeededdeddeeeeeeeeeddeddedd
-- 251:eeeeeeeeded11ddeee1111eedd1111ddee1111eede1111deee1111eeddeddedd
-- 252:3666666636666666366666663366666633666666333666663333666633333666
-- 255:cccc0000cccc0000cc000000cc00000000000000000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:2222222220000000200000002000000020000000200000002000000020000000
-- 001:2222000000002220000000020000000000000000000000000000000000000000
-- 002:0000000000000000220000000222000000002220000000020000000000000000
-- 003:0000000000000000000000000000000000000000200000002200000002200000
-- 004:2222220020000222200000022000000020000000200000002000000002000000
-- 005:0000000000000000220000000220000000222000000022000ee00220edee0022
-- 007:000099900009a900009a900000aca00009caa00009c900000ca000009a000000
-- 009:0000000d0000000c00dccc0c0dccd0dc0cc000cc0c000dcc0000dccc00dccccc
-- 010:00000000000000000cccd000d00ccd00c000dc00cd000c00ccd00c00ccccd000
-- 011:000c0000000cd00000dcc0000dccccd0cccccccc0dccccd000dcc000000cd000
-- 012:1111111111111111111111111111111111111111111111111111111111111111
-- 013:0000000003444430343334434334334443444334434444344333444434434443
-- 014:0000000000000000000000000000000000000030303303333333333433333344
-- 015:0000000003444443343333444334433443444434444444344444443444443343
-- 016:2000000020000000200000002000000020000000220000000200000002000000
-- 017:00000000000000ee0000eeee000eedde00eedddd00edeeee0eedeeee0eedeeee
-- 018:0eeeee00eeeeeee0eeedeeeeeeeeeeeedeeeeeeddeeeeeeeeeeeeeeeeeeeeeed
-- 019:0002000000022000e0002200ee000200eee00020eee00020eeee0022ddee0002
-- 020:0200000e0220000e0020000e0002000000022000000022000000002200000002
-- 021:eedee002eddee002eddee002eeede002eeee0002000000200000220022220000
-- 022:0000000000000009000000090000000900009a990009a900000a900000999000
-- 023:99000000aa000000a0000000a0000000999990000aca900000aca00000009900
-- 025:dccccccc000dcccc0cc00dcc0dcd00cc00ccd00c000ccc0c0000000000000000
-- 026:cccccccdccccd000ccd00c00cc00dc00c00dc000c0cc0000c0000000d0000000
-- 028:1111111111111111111111111111111111111111111111111111111111111111
-- 029:0344444300004443000344330004443300344433004444330044443400444434
-- 030:3343444434434444313444111434444114444441444444444441144444444444
-- 031:4444443044444000144443004444443044444440444444404444444044444440
-- 032:0200000000200000002000000022000000020000000220000000200000000200
-- 033:0eeeeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0eeeeeee0eefeeee0eeeeefe
-- 034:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 035:edeee002eedee002eedee002edde0002edee0002eeee0002eeee0002eee00022
-- 038:0990000099000000900000000000000000000000000000000000000000000000
-- 039:000990990009000a0099000900aa9000009c90000099c9000000aa9000000aa0
-- 040:000000000000000000000000900000000900000009a900000009000000009000
-- 041:0006600000677600067777606667766600677600006776000067760000677600
-- 042:0002200000233200023333202223322200233200002332000023320000233200
-- 044:1111111111111111111111111111111111111111111111111111111111111111
-- 045:0044444400434444033444440330034400000034000000000000000000000000
-- 046:4444444441c1c1c14c1c1c1c4444444444444444344444440034444300000000
-- 047:4444444044444344444444334443003344300000430000000000000000000000
-- 048:0000020000000020000000220000000200000000000000000000000000000000
-- 049:00eeeeff000eeeef0000eeee20000eee02200000002200000002200000000222
-- 050:eeeeefeefeeefeeefffffeeeeeeeeee00eee0000000000000000002222222220
-- 051:fee00020ee000220000022000002200002220000220000000000000000000000
-- 055:000000a0000000900000099000000a0000009900000099000000a00000009000
-- 060:2222222222222222222222222222222222222222222222222222222222222222
-- 061:0000000000000000000000fe00000eee0000feee0000eeee000feeee000eeeee
-- 062:00000000fdddddddeeeeeeeeeeeeeeeeeeeeeffeeeeffeefeffeefffeeeeeeee
-- 063:00000000df000000ddf00000eeddf000eefdd000ffeed000eeddd000ddd43000
-- 064:00000000000000000000000a000000aa000008a900080aa900aa0a990aa9aa99
-- 065:0000000000000000a000008aa008aaaaa8aa99a0aaa999a099999a809999aa00
-- 066:00000000000000000000000000000000000000000000a00000aaaa8008a999a0
-- 067:00000000000000000000000a000000aa000008a900000aa9000a8a9900aaaa99
-- 068:0000000000000000a000008aa008aaaaa8aa99a0aaa999a099999a809999aa00
-- 069:000000000000000000000000000000000000000000aa000008aaa0000aa9a000
-- 070:0000000700000005000000750000075600007566000756660005666600756666
-- 071:5555000066657000666655706666665066666657666666656666666666666666
-- 072:0000000000000000000000000000000000000000000000005000000057000000
-- 073:0000000700000075000005560000056600007566000756660075666600556666
-- 074:5557000066657000666655706666665066666657666666656666666666666666
-- 075:0000000000000000000000000000000000000000700000005000000057000000
-- 076:2222222222222222222222222222222222222222222222222222222222222222
-- 077:000eeeef000eeffe000eeeed000ffee40000dfe40000ddf3000eeddf000eeedd
-- 078:fffeedddeedddd44ddd4444434444444343444443334444434444444f4444444
-- 079:d444300041443000414430004144300044444300444443004443300041110000
-- 080:0a999a9a8a999a9aa9999aa9a99999aaa999999aa9999a998a99aa990a9a0aa9
-- 081:9a99a8009a9a800099aa00aa99aaaa99aaa999999999999a999999a89999aa00
-- 082:8a9999a0a99999a89999999a9999999aaaaa999a800a999a0008a99a00008a9a
-- 083:00a99a9a0aa99a9a0a999aa90a9999aa0a9aa99a0a9a8a990aaa0a9908a80aa9
-- 084:9a99a8009a9a808a99aa0aa999aaaa99aaa999aa99999aa899999aa09999aa00
-- 085:a999aa0099999a0099999a0099999a00aa999a0000a99a00000a9a000000aa00
-- 086:0756655605566665056666660566666607566655005665510075651100055511
-- 087:6666655656655666666666666666666655565566115615561156151511551115
-- 088:6550000066570000666500006665700066655000666657006666557066666550
-- 089:0756655605566665056666660566666607566655005665510056651100756511
-- 090:6666655656655666666666666666666655565566115615561156151511551115
-- 091:6570000066570000665500006665000066657000666650006666570066666500
-- 092:2222222222222222222222222222222222222222222222222222222222222222
-- 093:000efeed00fefeee00eefeee00eefeef00effeef00effefe00effefe00efeeee
-- 094:ee444444dde34444edde3333eedddddeeedfffffeedfffffedefffffedffffff
-- 095:444300004430000033000000f0000000ef000000fe000000fe000000fe000000
-- 096:0aaa00a908a8008a00a000080000000000000000000000000000000000000000
-- 097:9999a0009999a800aa99aa800aaaaaa000000000000000000000000000000000
-- 098:000008aa000000a8000000a00000000000000000000000000000000000000000
-- 099:00a000a90000008a000000080000000000000000000000000000000000000000
-- 100:9999a0009999a800aa99aa800aaaaaa000000000000000000000000000000000
-- 101:0000a80000000000000000000000000000000000000000000000000000000000
-- 102:0000555100007551000005550000055500000755000000560000005600000075
-- 103:1115611511115115111156151111565555555655666666666566666655555555
-- 104:6666665066666650666666506666665066666650666666506666665055555570
-- 105:0005651100056511000555110007565100005565000075660000075600000075
-- 106:1115611511115115111156151111565555555655666666666656666655555555
-- 107:6666657066666650666666506666665066666570666665006665570055570000
-- 108:2222222222222222222222222222222222222222222222222222222222222222
-- 109:0005565500075556000007550055555565666666555555565700656600005665
-- 110:5700000065557000666557555666555656666565666666656666665756666555
-- 111:0000000000000000556000005570000057000000666670007776600056776700
-- 112:000000cc000000c2ccce00c2cccc00c2cccd0ec2dddc0cccccccecccccccdccc
-- 113:e000000ece0000ec2ce00ecc2cccccc2cccccccc55ccc55c51ccc51ccccccccc
-- 114:cc000000cc0000002c0000002c0000002ce00000ccc00000ccce0000cccc0000
-- 115:000000ccccce00c2cccc00c2cccd00c2dddc0ec2ccccecccccccdcccccccdccc
-- 116:e000000ece0000ec2ce00ecc2cccccc2cccccccc55ccc55c15ccc15ccccccccc
-- 117:cc000000cc0000002c0000002c0000002ce00000ccc00000ccce0000cccc0000
-- 118:00000000000000000000000000000000000000ed0000eddc00eddccc0ddcc222
-- 119:000000dd0000eddd00edddcdeddccccddcccc221cccc22212ccc222222cccc22
-- 120:e0000000de000000dd000000dde00000ddd000001cde00001dcd0000ccdde000
-- 121:2222222222222222222222222222222222222222222222222222222222222222
-- 122:2222222222222222222222222222222222222222222222222222222222222222
-- 123:2222222222222222222222222222222222222222222222222222222222222222
-- 124:2222222222222222222222222222222222222222222222222222222222222222
-- 125:0000565500005554000055410000554400005544000055410000534400006344
-- 126:4666666644665555446444411444441411444114741417417444474444444444
-- 127:6577660065677600555776004557760045577600445776004437660043376000
-- 128:ccccdccccccccddccccccccccccccccccccccccceccccccc0ecccccc000ecccc
-- 129:ccccccccc2c2c2cccc2c2cccddcccddcccdddccccccccccdccccccdcccc44ddc
-- 130:cccc0000ddde0000ccccce00cdcccc00ddcccc00cccccc00cccccc00ccccce00
-- 131:ccccdccccccccddccccccccccccccccceccccccc0ecccccc0000eccc0000cccc
-- 132:ccccccccc2c2c2cccc2c2cccddcccddcccdddccccccccccdccccccdcccc44ddc
-- 133:cccc0000ddde0000ccccce00cdcccc00ddcccc00cccccc00cccccc00ccccce00
-- 134:ddcc2222dccc2222ddccc22cedcccddd0ddcdeee0edddeec00edddec000edddc
-- 135:22cccccc2ccc222cccc22222dddd2222eeeeedddceccceeececccecccecccecc
-- 136:cc1dd000c221de00cc21cde0ccc2ddd0ccccddddddcccdddeeddccddcceddcdd
-- 137:2222222222222222222222222222222222222222222222222222222222222222
-- 140:2222222222222222222222222222222222222222222222222222222222222222
-- 141:0000034400000344000003440000004400000034000000030000000000000000
-- 142:4433444444444c444444cc444ccccc4444444444444444433444443003333300
-- 143:4336600043366700437776663377676733776760367766600676766006660000
-- 144:000ecccc000ccccc000ccccc000ccddd000cdccc000ecccc0000cc2c0000ec2c
-- 145:cc44dccccc44dcccc444ddccc44444ddc44444ccc44444cc2c444ec22e4400e2
-- 146:cccde000cddc0000ddcc0000dddc0000cccd0000cccc0000c2ce0000c2e00000
-- 147:000ecccc000ccccc000ccccc000ccddd000cdccc000ecccc0000cc2c0000ec2c
-- 148:cc44dccccc44dcccc444ddccc44444ddc44444ccc44444cc2c444ec22e4400e2
-- 149:cccde000cddc0000ddcc0000dddc0000cccd0000cccc0000c2ce0000c2e00000
-- 150:00000edc00ddd0dd00d1d0ed00ddd00e000000dd00000ed20000ed2d0000dddd
-- 151:ccccccccccccccccccccccccdccccccc1ddddddd2dd000d2dd000d2de000ddde
-- 152:cccedddeccddde00cdde0000ddeddd00dd0d2d001d0ddd00de00000000000000
-- 153:2222222222222222222222222222222222222222222222222222222222222222
-- 156:1111111111111111111111111111111111111111111111111111111111111111
-- 157:1111111111111111111111111111111111111111111111111111111111111111
-- 158:1111111111111111111111111111111111111111111111111111111111111111
-- 159:1111111111111111111111111111111111111111111111111111111111111111
-- 160:1111111111111111111111111111111111111111111111111100101111000010
-- 161:1111101111110001111000011100d0001000cd00000dcc0000dcccd00dcccccd
-- 162:1111111111111111111111111111111101111111011111110010100100100001
-- 166:000000000000000000000000000000000000000000000000000d0d00000d0d00
-- 167:000000000000110000001100000feef0000eeee0000eeee000feeeef00ee11ee
-- 168:00000000000000000000000000000000000000000000000000d0d00000d0d000
-- 169:ccccccccccccccccccccccceccccccecccccccecccccccceccccccceceececec
-- 170:cccccccccccccccceccccccccecccccccecccccceccccccceccccccccecccccc
-- 171:cccccccccccccccccccccceecccccecccccccecccccccceecccccceecccccecc
-- 172:cccccccccccccccccccccccceccccccceccccccccccccccccccccccceccceece
-- 173:1111111111111111111111111111111111111111111111111111111111111111
-- 174:1111111111111111111111111111111111111111111111111111111111111111
-- 175:1111111111111111111111111111111111111111111111111111111111111111
-- 176:1110d0001110dd001110e00d1110000c111000dc111000cc110d000c100dde00
-- 177:0cccccccdcccccccc000c0000c0ccc0cccccccccccc00cccccc00ccccccccccc
-- 178:d000d011c00dd011cd00d0110c00e011ccd00011cc000111c0000111000ed011
-- 182:000eee00000eeef0000feeef0000eeee0000feee00000fee000000fe00000000
-- 183:0fe1111e0ee1ee1e0eeeeeeeffeeeeeeeeeeeeeeeeedddeeeedeeedeeedededf
-- 184:f0eee000e0eee000efeef000feee0000eeef0000eef00000f000000000000000
-- 185:ecceccecccccceccccccceeecccceccccccceccccccccccccccccccccccccccc
-- 186:cecccccccceccccceeecccccccceccccccceccccccccccccccccceeecccccccc
-- 187:cccccecccccceccccccceeeecccecccccccecccccccccccceeeccccccccccccc
-- 188:eccecceccecccccceecccccccceccccccceccccccccccccccccccccccccccccc
-- 189:1111111111111111111111111111111111111111111111111111111111111111
-- 190:1111111111111111111111111111111111111111111111111111111111111111
-- 191:1111111111111111111111111111111111111111111111111111111111111111
-- 192:10dde000000000001111110e1111100d111100dd11100ddd1110dde011100001
-- 193:eedcccdeeeeeeeeeddd000dddde000edde00100ee00111000111111111111111
-- 194:e000ed01e0000000de011111dd001111ddd001110edd0111000ed01111000011
-- 198:00000000000000000000000f000000fe000000fe000033ee0033003e00000033
-- 199:fedddedefeedeedeeeeeedeeeeeeeeeeeeeeeeeeee3333ee3300033e00000033
-- 200:f0000000f0000000f0000000ef000000ef000000e33300003300300030000000
-- 201:cccccccccccccccccccccccccccccccccccccccccccccccccceeeeeecccccccc
-- 202:cccccccccccccccccccecccccccecccccccecccccccecccceccccccccccccccc
-- 203:cccccccccccccccccccecccccccecccccccecccccccecccccccccceecccccccc
-- 204:cccccccccccccccccccccccccccccccccccccccccccccccceeeeeccccccccccc
-- 206:000000dd00000ddd00000ded00000d0d1ddd0ded000ddd0e0004444000441144
-- 207:0000000000ddddd00dd0e0d00d0e0e0d0de0e0edde0e0e0dd0e0e0ed0e0e0e0d
-- 208:000000000000000000000000000000000000000f0000000e0000000e0000000e
-- 209:0fddd000feeeed00eefffdd0efe44430ee444430fe344430ede33300edddfe00
-- 211:000000000000000000000000000000000000000f0000000e0000000e0000000e
-- 212:0fddd000feeeed00eefffdd0efe44430ee444430fe344430ede33300edddffee
-- 213:00000000000000000000000000000000000000000000000000000000eeeee400
-- 214:0000000000000003000000040000004400000044000000040000000000000000
-- 215:3344000034340000444400004444000044430000443300004444000044440000
-- 217:cccccccccccccccccceeeeeecccccccccccccccccccccccccccccccccccccccc
-- 218:ccccccccccccceeeeccccccccccccccccccccccccccccccccccccccccccccccc
-- 219:cccccccceecccccccccccceecccccccccccccccccccccccccccccccccccccccc
-- 220:cccccccccccccccceeeeeccccccccccccccccccccccccccccccccccccccccccc
-- 222:0444a4140444a444044444440044444e00000de0004400dd0044000000000000
-- 223:e0e0e0ed0e0e0e0dede0e0edddde0ed0d0dddd00440000004400000000000000
-- 224:0000000e0000000e0000000e0000000e0000000e0000000e000000fe000000ee
-- 225:fdeffe00fdfefe00fdfefef0edfeffe0edfeffe0eedeefe0eedfeee0eedff430
-- 227:0000000e0000000e0000000e0000000e0000000e0000000e000000fe000000ee
-- 228:fdfffffffdfefffffdffeeeeedffffe0edffffe0eedeeee0eedfffe0eedfffe0
-- 229:ffffe300fffee000eeee00000000000000000000000000000000000000000000
-- 230:0000000300000004000000040000000400000003000000030000000300000003
-- 231:4444000044443000444440034344400443444304434444344344444443444440
-- 232:0000000044300000444000000040000000400000004000000040000003030000
-- 236:1111111111111111111111111111111111111111111111111111111111111111
-- 238:000000dd000000dd000000dd000000dd1ddd00dd000dd0de0004444000441144
-- 239:000000000ddddd00dde0edd0de0e0ed0d0e0e0d0de0e0ed0d0e0e0d00e0e0ed0
-- 240:000000ee000000ee00000fef00000eef00000eff00000eee00000ddd00000000
-- 241:efdfffe0efdffef0efdffe00efdffe00efdeef00eedffe00dedffeefdddffffe
-- 243:000000ee000000ee00000fef00000eef00000eff00000eee00000ddd00000000
-- 244:efdfffe0efdffef0efdffe00efdffe00efdeef00eedffe00dedffeefdddffffe
-- 246:0000000300000000000000000000000000000000000000000000000000000003
-- 247:4344444033444440303444400004444000044440004444303444440044444400
-- 248:0333000000000000000000000000000000000000000000000000000000000000
-- 249:00deef000deefff0deeeeeefe414414e34144143344444430344443000333300
-- 250:444004444343343444334444043441404414414444411444344cc44300444400
-- 251:1ddd0000000dd00000044440004411440444a4140444a4440444444400444440
-- 252:1111111111111111111111111111111111111111111111111111111111111111
-- 253:1111111111111111111111111111111111111111111111111111111111111111
-- 254:0444a4140444a444044444440044444e000000d00044000d0044000000000000
-- 255:e0e0e0d00e0e0ed0ede0edd0dd0edd00d0ddd000440000004400000000000000
-- </SPRITES>

-- <MAP>
-- 000:000100010000000100000000010000000101010100000101000000000101010100000000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:010101010100010001000001010001010000000001010101010100000100000100000000000000000000000000010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:010001000100010101000101000101010001000101000101000101010101010100000000000000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:000101010001010101010001010001010000000100000101000001010101000100000000000000000000000001010001010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:000001000001000100010000010000010001010100010101010001000001000000000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:000000000000000000000000000000000000000000010000010001000001000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:dcecfceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedcecfc51515151acccccccbcac515151515151515151515151acccccac515151518e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e8e6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:ddedfdfefedcecfcfefefefefefefefefefefefefefedcecfcfefeddedfd515151acccbcccbccccc51ccac51515151515151bc51acbcbcccac5151518e8e8e8e8e8e8e8e8e6d7d8e8e8e8e8e8e8e8e8e8e8e8e6d7d8e8e8e8e8e717171717171717171717171717171717171717171717171717171717171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:ddedfd0101ddedfd0101010101010101010101010101ddedfd0101ddedfd70707070cccc60becc707060707070707070707060707060cccc707070709d8d9d9d8d8d9d9d8d6e7e8d8d9d9d8d9d9d8d8d9d9d8d6e7e8d8d9d9d8d717171717171717171717171717171717171717171717171717171717171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:ddedfddededdedfddededededededededededededededdedfddededdedfd61616161bd6060cd6161616161616161616161616161bd6060cd616161619f9f8d9f9f9f8d9f9f9f8d9f9f9f8d9f9f9f8d9f9f9f8d9f9f9f8d9f9f9f525252525252525252525252525252525252525252525252525252525252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:ddedfdfefedcecfcfefefefefefefefefefefefefefedcecfcfefeddedfd50505050ce6060cf5050505050505050505050505050ce6060cf505050509f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f525252525252525252525252525252525252525252525252525252525252000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:dcecfceeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedcecfc6161616161616161616161616161616161616161616161616161616161619f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f9f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 034:fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe010101adadadadad0101010101011222221322221201adadad012301010101010101010101010101010101010101010101010101010101010101010101010101010101010101afbfafafafafafbfaf0101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 035:eefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefe0101010101aeaeaeaeaeae010101320101010101320101aeaeae32aeae0101010101010101010101018d0101010101018d010101010101010101010101010101010101010101afafafafafafafafaf0101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 036:01eeeeee01eeeeee01eeeeee01eeeeee01eeeeee01eeeeee01eeeeee01ee01010101010101adadadadad010132010101010132010101adad32adad0101010101018d0101010101010123010101010101010101018d010101010101010101010101010101afbfafafafafafbfaf0101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 037:0101ee01ee01ee01ee01ee010101ee010101ee01ee01ee01ee01ee010101010123222212222213222212222212010101010112222212222213ae010101018d01010101018d0101010132010101010101018d01010101018d010101010101010101010101afafafafafafafafaf0101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 038:010101eeeeee01eeeeee010101010101010101eeeeee01eeeeee01010101010101010101010132adadadadad32adadad0101320101010101010101010101010101010101010101010132010101010101010101010101010101010101010101010101010101afafaf23afafaf010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 039:01010101ee010101ee0101011222221301010101ee010101ee010123010101010101010101013201aeaeaeae32aeaeaeae01320101010101010101010101010123222212017f8f01011222221201017f8f011222222301010101010101010101010101010101010132010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 040:0101010101010101010101013201013201010101010101010101013201010101010101010101120101adadad13adadadadad130101010101010101010101010101010132016e7e01013201013201016e7e0132010101010101010101010101010101010101016f6f326f6f01010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 041:010101010101010101010101320101320101010101010101010101320101010101010101010132010101aeae32aeaeaeaeae3201010101010101010101010101010101320101010101327f8f32010101010132010101010101010101010101122222132222126f6f136f6f12222213222212010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 042:01010112222212222213222213010112222212222223010101010112010101010101010101013201010101ad32adadadadad3201010101010101010101010101010101122222120101126e7e13010112222212010101010101010101010101326f6f6f6f6f326f6f326f6f326f6f6f6f6f32010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 043:010101010101010101010101320101320101010101010101010101320101010101010101010112010101010112222212222212ae010101010101010101010101010101010101328d0132010132018d32010101010101010101010101010101326f6f6f6f6f326f6f326f6f326f6f6f6f6f32010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 044:01010101010101010101010132010132010101010101010101010132010101010101010101ad32adad0101010101ad32adadadadadad01010101010101010101018d0101010132010132010132010132010101018d01010101010101010101126f6f122222132222122222132222126f6f12010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 045:0101ee010101ee010101010112222213010101010101ee01010101130101010101010101aeae32aeaeaeae010101013201aeaeaeaeaeae010101010101018d01010101018d0113010112222212010113018d01010101018d01010101010101326f6f326f6f6f6f6f326f6f6f6f6f326f6f32010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 046:01eeeeee01eeeeee01010101010101010101010101eeeeee010101010101010101010112222213222212adad01010113010101adadadadad010101010101010101010101010132010101010101010132010101010101010101010101010101326f6f326f6f6f6f6f326f6f6f6f6f326f6f32010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 047:ee01ee01ee01ee01ee010101ee010101ee010101ee01ee01ee010101ee01010101010132010101aeae32aeaeae0101320101010101aeaeaeae01010101010101010101010101320101018d8d01010132010101010101010101010101232222122222130101016f6f136f6f01010113222212222223010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 048:eeee01eeeeee01eeeeee01eeeeee01eeeeee01eeeeee01eeeeee01eeeeee010101010132010101010132adad01010132010101010101adadadadad010101010101010101010112222212222212222212010101010101010101010101010101010101010101016f6f326f6f01010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 049:eefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefeeefe0101010101230101010101122222122222120101010101010101aeaeae010101010101018d010101010101010101010101010101018d010101010101010101010101010101010101010132010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 050:fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010123010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 054:000000006262000000000000626200000000000000000000626262626262626262620000626262626262626200000000626262626262626262620000000000000000000000006262000000000000626200000000000000000000626262626262626262620000626262626262626200000000626262626262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 055:000000626262620000000000626200000000000000000000626262626262626262620000626262626262626262000000626262626262626262620000000000000000000000626262620000000000626200000000000000000000626262626262626262620000626262626262626262000000626262626262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 056:000062626262626200000000626200000000000000000000626200000000000000000000626200000000006262620000000000006262000000000000000000000000000062626262626200000000626200000000000000000000626200000000000000000000626200000000006262620000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 057:006262620000626262000000626200000000000000000000626200000000000000000000626200000000000062620000000000006262000000000000000000000000006262620000626262000000626200000000000000000000626200000000000000000000626200000000000062620000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 058:626262000000006262620000626200000000000000000000626200000000000000000000626200000000000062620000000000006262000000000000000000000000626262000000006262620000626200000000000000000000626200000000000000000000626200000000000062620000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 059:626200000000000062620000626200000000000000000000626200000000000000000000626200000000006262620000000000006262000000000000000000000000626200000000000062620000626200000000000000000000626200000000000000000000626200000000006262620000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 060:626200000000000062620000626200000000000000000000626262626262626200000000626262626262626262000000000000006262000000000000000000000000626200000000000062620000626200000000000000000000626262626262626200000000626262626262626262000000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 061:626200000000000062620000626200000000000000000000626262626262626200000000626262626262626200000000000000006262000000000000000000000000626200000000000062620000626200000000000000000000626262626262626200000000626262626262626200000000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 062:626262626262626262620000626200000000000000000000626200000000000000000000626200626262000000000000000000006262000000000000000000000000626262626262626262620000626200000000000000000000626200000000000000000000626200626262000000000000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 063:626262626262626262620000626200000000000000000000626200000000000000000000626200006262620000000000000000006262000000000000000000000000626262626262626262620000626200000000000000000000626200000000000000000000626200006262620000000000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 064:626200000000000062620000626200000000000000000000626200000000000000000000626200000062626200000000000000006262000000000000000000000000626200000000000062620000626200000000000000000000626200000000000000000000626200000062626200000000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 065:626200000000000062620000626200000000000000000000626200000000000000000000626200000000626262000000000000006262000000000000000000000000626200000000000062620000626200000000000000000000626200000000000000000000626200000000626262000000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 066:626200000000000062620000626262626262626262620000626262626262626262620000626200000000006262620000000000006262000000000000000000000000626200000000000062620000626262626262626262620000626262626262626262620000626200000000006262620000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 067:626200000000000062620000626262626262626262620000626262626262626262620000626200000000000062620000000000006262000000000000000000000000626200000000000062620000626262626262626262620000626262626262626262620000626200000000000062620000000000006262000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 071:000062626262626200000000626262626262626262620000626200000000000062620000626262626262626262620000626262626262626200000000000000006262000000000000626200000000000000000000000000000000000062626262626200000000626262626262626262620000626200000000000062620000626262626262626262620000626262626262626200000000000000006262000000000000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 072:006262626262626262000000626262626262626262620000626200000000000062620000626262626262626262620000626262626262626262000000000000626262620000000000626200000000000000000000000000000000006262626262626262000000626262626262626262620000626200000000000062620000626262626262626262620000626262626262626262000000000000626262620000000000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 073:626200000000000062620000626200000000000000000000626200000000000062620000626200000000000000000000626200000000006262620000000062626262626200000000626200000000000000000000000000000000626200000000000062620000626200000000000000000000626200000000000062620000626200000000000000000000626200000000006262620000000062626262626200000000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 074:626200000000000062620000626200000000000000000000626262000000000062620000626200000000000000000000626200000000000062620000006262620000626262000000626200000000000000000000000000000000626200000000000062620000626200000000000000000000626262000000000062620000626200000000000000000000626200000000000062620000006262620000626262000000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 075:626200000000000000000000626200000000000000000000626262620000000062620000626200000000000000000000626200000000000062620000626262000000006262620000626200000000000000000000000000000000626200000000000000000000626200000000000000000000626262620000000062620000626200000000000000000000626200000000000062620000626262000000006262620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 076:626200000000000000000000626200000000000000000000626262626200000062620000626200000000000000000000626200000000006262620000626200000000000062620000626200000000000000000000000000000000626200000000000000000000626200000000000000000000626262626200000062620000626200000000000000000000626200000000006262620000626200000000000062620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 077:626200000062626262620000626262626262626200000000626200626262000062620000626262626262626200000000626262626262626262000000626200000000000062620000626200000000000000000000000000000000626200000062626262620000626262626262626200000000626200626262000062620000626262626262626200000000626262626262626262000000626200000000000062620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 078:626200000062626262620000626262626262626200000000626200006262620062620000626262626262626200000000626262626262626200000000626200000000000062620000626200000000000000000000000000000000626200000062626262620000626262626262626200000000626200006262620062620000626262626262626200000000626262626262626200000000626200000000000062620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 079:626200000000000062620000626200000000000000000000626200000062626262620000626200000000000000000000626200626262000000000000626262626262626262620000626200000000000000000000000000000000626200000000000062620000626200000000000000000000626200000062626262620000626200000000000000000000626200626262000000000000626262626262626262620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 080:626200000000000062620000626200000000000000000000626200000000626262620000626200000000000000000000626200006262620000000000626262626262626262620000626200000000000000000000000000000000626200000000000062620000626200000000000000000000626200000000626262620000626200000000000000000000626200006262620000000000626262626262626262620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 081:626200000000000062620000626200000000000000000000626200000000006262620000626200000000000000000000626200000062626200000000626200000000000062620000626200000000000000000000000000000000626200000000000062620000626200000000000000000000626200000000006262620000626200000000000000000000626200000062626200000000626200000000000062620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 082:626262000000006262620000626200000000000000000000626200000000000062620000626200000000000000000000626200000000626262000000626200000000000062620000626200000000000000000000000000000000626262000000006262620000626200000000000000000000626200000000000062620000626200000000000000000000626200000000626262000000626200000000000062620000626200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 083:006262626262626262000000626262626262626262620000626200000000000062620000626262626262626262620000626200000000006262620000626200000000000062620000626262626262626262620000000000000000006262626262626262000000626262626262626262620000626200000000000062620000626262626262626262620000626200000000006262620000626200000000000062620000626262626262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 084:000062626262626200000000626262626262626262620000626200000000000062620000626262626262626262620000626200000000000062620000626200000000000062620000626262626262626262620000000000000000000062626262626200000000626262626262626262620000626200000000000062620000626262626262626262620000626200000000000062620000626200000000000062620000626262626262626262620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 102:010100000001000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 103:010001000100010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 104:010101000100010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 105:010100000100010001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 106:010001000001000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 108:000001010000010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 109:000001000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 110:000001010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 111:000001000100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 112:000001010000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 114:010100000001000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 115:010001000100010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 116:010101000100010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 117:010100000100010001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 118:010001000001000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 004:03589aabbbbbbba98776555555566666
-- 005:69bcdeffffeedb9653211122335568a0
-- 006:0000025befffc8300002579aceefeb50
-- 007:0035789999876555567789abccdcca97
-- 008:00000ffffff000000000000000000000
-- 009:0000000fffffffffffff000000000000
-- 010:79bcdeffffeedb965321112233556789
-- </WAVES>

-- <WAVES1>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 004:03589aabbbbbbba98776555555566666
-- 005:89abccdeeeffedca8765432112234467
-- 006:0000025befffc8300002579aceefeb50
-- 007:0035789999876555567789abccdcca97
-- 008:00000ffffff000000000000000000000
-- 009:0000000fffffffffffff000000000000
-- 010:79bcdeffffeedb965321112233556789
-- </WAVES1>

-- <SFX>
-- 000:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300305000000000
-- 001:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000000000000
-- 002:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400000000000000
-- 003:030013001300230023003300430043005300530063007300830093009300a300b300b300c300c300d300d300d300e300e300f300f300f300f300f300000000000000
-- 004:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000000
-- 005:011001300150016001800180019001b001c001c001c001c001c001c001c001c001c00100010001000100010001000100010001000100010001000100382000000000
-- 006:060026003600460066007600b600e600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600000000000000
-- 007:070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700300000000000
-- 008:03100330038003d003f003f003f003f00300030003000300030003000300030003000300030003000300030003000300030003000300030003000300587000000000
-- 009:0000000e000d000b00090008000800080008000800080008000800080008000800080008000800080008000000000000000000000000000000000000b02000000052
-- 010:03000300030023003300430053009300a300b300d300e300f30003000300030003000300030003000300030003000300030003000300030003000300309000000000
-- 011:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000000000000
-- 012:080038005800680068006800680068005800580058005800680068006800680008000800080008000800080008000800080008000800080008000800300000880000
-- 013:090029004900590069006900790079000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900309000440000
-- 014:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000000
-- 015:c700b7008700570027001700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700409000000000
-- 016:01070106010501040104010301020100010f010e010e010c010c010a01090108010801080108010801080108010a010b010d010e010f010f01000100c09000000000
-- 017:0a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00300000000000
-- </SFX>

-- <SFX1>
-- 000:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300305000000000
-- 001:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000000000000
-- 002:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400000000000000
-- 003:030013001300230023003300430043005300530063007300830093009300a300b300b300c300c300d300d300d300e300e300f300f300f300f300f300000000000000
-- 004:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100307000000000
-- 005:011001300150016001800180019001b001c001c001c001c001c001c001c001c001c00100010001000100010001000100010001000100010001000100382000000000
-- 006:060026003600460066007600b600e600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600000000000000
-- 007:070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700300000000000
-- 008:03100330038003d003f003f003f003f00300030003000300030003000300030003000300030003000300030003000300030003000300030003000300587000000000
-- 009:0000000e000d000b00090008000800080008000800080008000800080008000800080008000800080008000000000000000000000000000000000000b02000000052
-- 010:03000300030023003300430053009300a300b300d300e300f30003000300030003000300030003000300030003000300030003000300030003000300309000000000
-- 011:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100000000000000
-- 012:050035005500650065006500650065005500550055005500650065006500650005000500050005000500050005000500050005000500050005000500300000880000
-- 013:090029004900590069006900790079000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900309000440000
-- 014:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000000
-- 015:c700b7008700570027001700070007000700070007000700070007000700070007000700070007000700070007000700070007000700070007000700409000000000
-- 016:01070106010501040104010301020100010f010e010e010c010c010a01090108010801080108010801080108010a010b010d010e010f010f01000100c09000000000
-- 017:0a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00000000000000
-- 018:060016002600260046004600560056000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600307000620000
-- </SFX1>

-- <PATTERNS>
-- 000:fff166000000f88166f551668ff168000000888168855168aff168000000a88168a55168fff168000000f88168f551685ff168000000588168555168aff168000000a88168a55168dff168000000d88168d55168cff168000000c88168c55168fff166000000f88166f551668ff168000000888168855168aff168000000a88168a55168fff168080000f88168f551685ff168008000588168555168aff168000000a88168a55168dff168000000d88168d55168cff168000000c88168c55168
-- 001:dff166000000d88166d551666ff1680000006881686551688ff168000000888168855168dff168000000d88168d55168fff166000000f88166f551668ff168000000888168855168bff168000000b88168b55168aff168000000a88168a55168dff166000000d88166d551666ff1680000006881686551688ff168000000888168855168dff168080000d88168d55168fff166000000f88166f551668ff168000000888168855168bff168000000b88168b55168aff168000000a88168a55168
-- 002:f00072000000100000000000000000000000000000000000000000000000000000000000a00074000000100000000000d00072000000100000000000000000000000a00074000000d00072000000c00072100000d00072000000c00072100000f00072000000100000000000000000000000000000000000000000000000a00074000000100000000000d00074000000800074000000100000000000000000000000000000000000d00074000000100000000000c00074000000100000000000
-- 003:dff166100000d881660000001000000000000000000000006ff1680000006881680000001000000000000000000000008ff168000000888168000000100070000000000000100000dff168000000d881680000001000701000000000000000004ff16a00000048816a000000100070000000000000000000dff168100000d881680000001000000000000000000000008ff16a00000088816a0000001000000000000000000000006ff16a00000068816a000000100000000000000000000000
-- 004:d00072000000100000000000000000000000000000000000000000000000000000000000800074000000100000000000b00072000000100000000000000000000000800074000000b00072000000a00072100000b00072000000a00072100000d00072000000100000000000000000000000000000000000000000000000800074000000100000000000b00074000000600074000000100000000000000000000000000000000000b00074000000100000000000a00074000000100000000000
-- 005:6000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:6000e40000000000000000009000e40000006000960000001000000000009000e41000006000e40000000000000000009000e41000006000960000001000000000009000e41000006000e4000000000000000000d000e4100000600096000000100000000000d000e4100000000000000000000000000000b000e41000006000960000001000000000004000e4100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:6000ba0000000000001000006000ba0000009000ba0000008000ba0000004000ba0000006000ba000000000000000000000000000000000000100000000000000000000000000000d000b8000000000000100000d000b81000004000ba0000009000ba000000d000ba0000006000bc000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:6372c80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008472c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:9472c8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b572c8000000100000000000b572c8000000100000000000b572c8b572c8b572c8000000b572c8000000100000000000b572c8000000100000000000b572c8000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:6000da0000009000da0000001000000000009000da000000000000000000000000000000d000da0000006000da000000d000da100000d000da100000d000da0000001000000000008000da000000000000000000b000da0000008000da000000000000000000b000da0000006000da000000000000000000b000da0000004000da0000008000da0000009000daa000da000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:b000ca0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000da0000008000da000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:6000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000a80000008000a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:67c2dc10000067c0dc10000097c0dc1000009000dc0000001000000000009000dc0000008000dc0000006000dc0000008000dc1000004000dc0000001000000000004000dc0000006000dc000000d000da000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:67c2dc1000006000dc1000009000dc1000009000dc0000000000000000001000000000000000000000000000000000000000001000009000dc0000008000dc0000009000dc100000b000dc0000004000dc0000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000006002dc0000004000dc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:e000da000000100000000000e000da100000e000da1000006000dc0000001000000000004000dc000000000000000000100000000000000000000000000000000000000000000000e000da0000004000dc0000006000dc0000006000dc0000000000000000008000dc0000009000cc1000009000cc100000b000cc000000000000000000100000000000b000cc0000006000da0000004000da000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:6372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:6372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000006372ca0000000000000000000000001000008472ca0000000000000000000000001000008472ca0000000000000000000000001000008472ca0000000000000000000000001000008472ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:e472c8000000000000000000000000000000000000000000000000000000000000000000d472c8000000000000000000000000000000000000000000000000000000000000000000e472c80000000000000000000000000000000000000000000000000000000000000000004472ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:9000dc0000008000dc0000006000dc0000001000000000006000dc0000001000000000006000dc0000008000dc0000009000dc0000009000dc0000008000dc0000001000000000009000dc0000000000000000008000dc0000000000000000006000dc0000001000000000006000dc000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:4372ca0000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000070005482ca0000000000000000000000000000000000000000000000000000000000000000006572ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:6000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa0000006000960000008000aa0000008000aa0000008000a80000008000aa0000008000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:67c2dc1000006000dc1000009000dc1000009000dc0000001000000000009000dc0000008000dc0000006000dc0000008000dc1000009000dc0000008000dc0000009000dc100000b000dc0000004000dc000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:64410f00000060000f60000fd0000d000000d0000dd0000d90000d00000090000d90000d60000d00000060000d60000dd0000b000000d0000bd0000b90000b00000090000b90000b60000b00000060000b60000bd00009000000d00009000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:6ff166000000688166000000000000000000000000000000bff166000000b88166000000000000000000000000000000dff166000000d881660000000000000000000000000000006ff1680000006881680000000000000000000000000000009ff1680000009881680000000000000000000000000000006ff168000000688168000000000000000000000000000000dff168000000d88168000000000000000000000000000000bff168000000b88168000000000000000000000000000000
-- 025:8881a80000008000a80000001000000000000000000000008000a88000a88000aa0000008000a88000a88000aa0000008000a80000008000a80000001000000000000000000000008000a88000a88000aa0000008000a88000a88000aa0000008000a80000008000a80000001000000000000000000000008000a88000a88000aa0000008000a88000a88000aa0000008000a80000008000a80000001000000000000000000000008000a88000a88000aa0000008000a88000a88000aa000000
-- 026:e000da000000100000000000e000da100000e000da1000006000dc0000001000000000004000dc000000000000000000100000000000000000000000000000000000000000000000e000da0000004000dc0000006000dc0000006000dc0000000000000000008000dc0000009000cc1000009000cc100000d000cc000000000000000000100000000000b000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 027:9000dc0000008000dc0000006000dc1000006000dc0000008000dc0000009000dc100000b000dc0000008000dc0000009000dc100000d000dc000000000000000000b000dc0000005000de0000000000000000004000de000000000000000000e000dc0000000000000000004000de0000000000000000008000dc1000009000dc000000b000dc0000006000dc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 028:6000e20000009000e2000000d000e20000006000e40000009000e40000006000e40000006000e20000009000e2000000d000e20000006000e40000009000e40000006000e40000008000e20000000000001000008000e20000000000001000008000e21000008000e21000008000e2000000100000000000000000000000000000000000f000e0000000b000e2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 029:9000e20000000000001000004000e2000000d000e20000004000e40000009000e4000000d000e20000004000e40000009000e40000004000e40000009000e4000000d000e4000000b000e40000000000000000006000e41000006000e41000006000e41000006000e40000005000e4000000000000000000d000e20000001000000000008000e2000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 030:6000e40000000000000000009000e40000006000960000001000000000009000e41000006000e40000000000000000009000e41000006000960000001000000000009000e41000006000e4000000000000000000e000e4100000600096000000100000000000e000e4100000d000e4b000e4100000000000b000e41000006000960000009000e41000004000e4100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 031:4000e40000000000000000009000e40000006000960000001000000000009000e41000004000e40000000000000000009000e41000006000960000001000000000009000e41000006000e4000000000000000000e000e2100000600096000000100000000000e000e2100000000000000000b000e4100000b000e41000006000960000008000e41000004000e4100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 032:6000e40000000000000000009000e40000006000960000001000000000009000e41000006000e40000000000000000009000e41000006000960000001000000000009000e41000004000e4000000000000000000d000e4100000600096000000100000000000d000e4100000000000000000000000000000b000e41000006000960000001000000000004000e4100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 033:c000f80000006000f8000000b000f80000009000f8000000b7c0fa000000000000b000fa000000000000b000fa000000b000fa000000000000d000fa000000000000e000fa000000b000fa0000001000009000fa0000000000006000fa0000000000000000001000000000006000fa0000000000000000007000fa000000000000000000f000f84000fa6000fa7000fab000fa0000000000009000fa0000000000007000fa0000009000fa0000001000000000006000fa000000100000000000
-- 034:8000aa0000008000a80000008000a88000a88000a80000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000a8000000
-- 035:0000000000006000f80000009000f80000007000f80000007000fa0000000000006000fa0000000000004000fa0000006000fa0000000000007000fa000000000000b000fa0000007000fa0000000000009000fa000000000000b000fa000000b000fa000000000000000000000000000000000000000000f000fa0000000000004000fc0000000000006000fc000000000000000000000000000000f000fa0000000000000000009000fc0000007000fc0000009000fc000000f000fa000000
-- 036:b000fa000000f000f80000009000fa0000006000fa000000b000fa000000000000b000fa000000000000b000fa000000b000fa000000000000d000fa000000000000e000fa000000b000fa0000001000009000fa0000000000006000fa0000000000000000001000000000000000000000000000000000007000fa000000000000000000f000f84000fa6000fa7000fab000fa0000000000009000fa0000000000007000fa0000009000fa0000001000000000006000fa000000100000000000
-- 037:8000aa0000000000000000008000aa0000000000000000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000000000000000001000000000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa0000008000a80000008000aa0000008000a88000a88000aa8000aa
-- 038:0000000000006000f80000009000f80000007000f80000007000fa0000000000006000fa0000000000004000fa0000006000fa0000000000007000fa000000000000b000fa0000007000fa0000000000009000fa000000000000b000fa000000b000fa000000000000000000000000000000000000000000f000fa0000000000004000fc0000000000006000fc0000000000000000000000000000009000fc000000000000000000b000fc0000009000fc0000006000fc000000f000fa000000
-- 039:b000fa0000009000fa0000006000fa000000f000f80000007000fa0000000000000000007000fa0000000000007000fa0000000000007000fa0000007000fa0000000000000000006000fa0000000000000000006000fa0000000000006000fa0000000000006000fa0000006000fa0000006000fa7000fa9000fa0000000000000000004000fa0000000000000000007000fa0000000000006000fa000000000000d000f8000000f000f8000000000000000000f000f8000000000000000000
-- 040:7000fa0000004000fa000000f000f8000000c000f80000007000fa0000000000000000007000fa0000000000007000fa0000000000007000fa0000007000fa0000000000000000006000fa0000000000000000006000fa0000000000006000fa0000000000006000fa0000000000000000006000fa8000fa9000fa0000000000000000004000fa0000000000000000008000fa0000009000fa000000d000fa000000c000fa000000f000fa0000004000fc000000f000fa000000c000fa000000
-- 041:8000aa0000000000000000008000aa0000000000000000008000a80000008000a88000aa8000a88000aa0000001000008000a80000001000000000008000a80000000000000000008000a80000008000a88000aa8000a88000aa0000001000008000a80000001000000000008000a80000000000000000008000a80000008000a88000aa8000a88000aa0000001000008000a80000001000000000008000a80000000000000000008000a88000aa8000a88000aa8000a88000aa000000000000
-- 042:c000e61000006000e41000006000e61000009000e4100000b000e4000000000000000000000000000000000000000000000000000000000000d000e4000000100000e000e41000009000e40000000000000000000000000000000000000000000000000000007000e4000000e000e40000009000e40000007000e40000001000007000e40000001000007000e41000007000e40000000000009000e40000001000007000e41000009000e40000001000000000006000e4000000000000000000
-- 043:0000000000000000000000000000000000000000000000007000e40000000000006000e40000000000004000e4000000e000e4000000000000000000000000000000000000000000b000e4000000000000d000e4000000000000e000e4000000d000e4000000000000000000000000000000000000000000f000e40000000000000000000000000000000000000000000000004000e66000e60000000000000000006000e6000000b000e4000000000000000000000000000000000000000000
-- 044:0000000000006000e40000000000000000009000e4000000b000e4000000000000000000000000000000000000000000000000000000000000d000e4000000100000e000e41000009000e40000000000000000000000000000000000000000000000000000001000000000000000000000000000000000007000e40000000000007000e40000000000007000e40000000000000000000000009000e40000001000007000e41000009000e40000001000000000006000e4000000000000000000
-- 045:0000000000000000000000000000000000000000000000006372c80000000000000000000000000000001000000000006572c80000000000000000000000000000001000000000004372c80000000000000000000000000000001000000000006372c8000000000000000000100000000000000000000000e372c6000000000000000000000000000000100000000000e472c6000000000000000000000000000000100000000000d372c6000000000000000000000000000000000000000000
-- 046:000000000000000000000000000000000000000000000000e372c60000000000000000000000000000001000000000009372c80000000000000000000000000000001000000000007472c80000000000000000000000000000001000000000006372c8000000000000000000000000000000100000000000f372c60000000000000000000000000000001000000000004372c80000000000000000000000000000001000000000009472c8000000000000000000000000000000000000000000
-- 047:0000000000000000000000000000000000000000000000007000e61000007000e41000007000e61000007000e41000007000e61000007000e41000007000e61000007000e41000006000e61000006000e41000006000e61000006000e41000006000e61000006000e41000006000e61000007000e61000009000e61000009000e41000009000e61000009000e41000009000e61000009000e41000009000e61000009000e4100000b000e6100000b000e4100000b000e6100000b000e4100000
-- 048:aff166100000a88166000000100000000000000000000000fff166000000f881660000001000000000000000000000005ff168000000588168000000100070000000000000100000aff168000000a88168000000100070100000000000000000dff168000000d88168000000100070000000000000000000aff168100000a881680000001000000000000000000000005ff16a00000058816a000000100000000000000000000000fff168000000f88168000000100000000000000000000000
-- 049:7000e61000007000e41000006000e61000006000e41000007000e61000007000e41000007000e61000007000e41000007000e61000007000e41000007000e61000007000e41000009000e61000009000e41000009000e61000009000e41000009000e61000009000e41000009000e61000009000e4100000b000e6100000b000e4100000b000e6100000b000e4100000b000e6100000b000e4100000b000e6100000c000e6100000f000e61000004000e8100000f000e6100000c000e6100000
-- 050:4372ca0000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000070006372ca0000000000000000000000000000000000000000000000000000000000000000006572ca000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 051:fff164000000f881640000000000000000000000000000008ff166000000888166000000000000000000000000000000aff166000000a88166000000000000000000000000000000fff166000000f881660000000000000000000000000000006ff168000000688168000000000000000000000000000000fff166000000f88166000000000000000000000000000000aff168000000a881680000000000000000000000000000008ff168000000888168000000000000000000000000000000
-- 052:d881e4100000d000e41000000000000000000000000000006000e61000006000e61000000000000000000000000000008000e61000008000e6100000000000000000000000000000d000e6100000d000e61000000000000000000000000000004000e81000004000e8100000000000000000000000000000d000e6100000d000e61000000000000000000000000000008000e81000008000e81000000000000000000000000000006000e81000006000e8100000000000000000000000000000
-- 053:a881e4100000a000e4100000000000000000000000000000f000e4100000f000e41000000000000000000000000000005000e61000005000e6100000000000000000000000000000a000e6100000a000e6100000000000000000000000000000d000e6100000d000e6100000000000000000000000000000a000e6100000a000e61000000000000000000000000000005000e81000005000e8100000000000000000000000000000f000e6100000f000e6100000000000000000000000000000
-- </PATTERNS>

-- <PATTERNS1>
-- 000:800056000000800056000000100000000000800056800056800056000000100000000000800054000000100000000000800056000000800056000000100000000000800056000000800056000000000000100000000000000000000000000000800056000000800056000000100000000000800056000000800056000000100000000000800054000000100000000000800056000000800056000000800056800056800056000000800056000000000000100000000000000000000000000000
-- 001:000000000000537219000000000000000000537219100000000000000000537219100000000000000000537219100000000000000000637219000000000000000000637219100000000000000000637219100000000000000000637219100000647219000000000000000000100000000000647219000000000000000000100000000000437219000000000000000000747219000000000000000000000000000000000000000000837219000000000000000000847219000000000000000000
-- 002:57c017000000c00017000000800017000000500017000000d00017000000800017000000500017000000c00017000000800017000000600017100000600017100000600017000000a00017000000d00017000000c0001700000060001700000057c017000000c00017000000800017000000500017000000d00017000000800017000000500017000000c00017000000800017000000600017100000600017100000600017000000a00017000000d00017000000c00017000000600017000000
-- 003:57c217000000c00017000000800017000000500017000000d00017000000800017000000500017000000c00017000000800017000000600017100000600017100000600017000000a00017000000d00017000000c0001700000060001700000057c017000000c00017000000800017000000500017000000d00017000000800017000000500017000000c00017000000800017000000600017100000600017100000600017000000a00017000000d00017000000c00017000000600017000000
-- 004:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600038000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000
-- 006:00000000000053721b00000000000000000053721b10000000000000000053721b10000000000000000053721b10000000000000000053721b00000000000000000053721b10000000000000000053721b10000000000000000053721b10000063721b00000000000000000010000000000063721b00000000000000000010000000000063721b00000000000000000074721b00000000000000000000000000000000000000000083721b000000000000000000000000000000000000000000
-- 007:500027000000000000000000800027000000c00027000000000000000000800027000000500027000000000000000000600027000000000000000000900027000000d00027000000000000000000900027000000600027000000000000000000600027000000000000000000600027000000a00027000000000000000000d00027000000b00027000000000000000000700027000000000000000000700027000000b00027000000800027000000000000000000800027000000c00027000000
-- 008:8000aa0000008000aa0000001000000000008000aa8000aa8000aa0000008000aa0000008000a80000001000000000008000aa0000008000aa8000aa8000aa0000008000aa8000aa8000aa0000008000aa0000008000a80000008000a8000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:8881aa8000aa8000a80000008000aa8000aa8000aa0000008000aa8000aa8000aa0000008000a88000aa8000aa0000008880aa8000aa8000a80000008000aa8000aa8000aa0000008000aa8000aa8000aa0000008000a88000aa8000aa0000008880aa8000aa8000a80000008000aa8000aa8000aa0000008000aa8000aa8000aa0000008000a88000aa8000aa0000008880aa8000aa8000a80000008000aa8000aa8000aa0000008000aa8000aa8000aa0000008000a88000aa8000aa000000
-- 010:1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008881aa8000aa8000aa0000008000aa8000aa
-- 011:00000000000053721b00000000000000000053721b10000000000000000053721b10000000000000000053721b10000000000000000063721b00000000000000000063721b10000000000000000063721b10000000000000000063721b10000064721b00000000000000000010000000000064721b00000000000000000010000000000043721b00000000000000000074721b00000000000000000000000000000000000000000083721b00000000000000000084721b000000000000000000
-- 012:53701b00000000000000000000000000000010000000000000000000000000000000000050001b00000000000000000080001b00000000000000000000000000000070001b00000000000000000000000000000050001b00000000000080301ba0001b100000a0001b000000000000000000100000000000a0001b000000c0001b000000d0001b000000c0001b00000070001b00000080001b000000a0001b00000080001b00000040001b000000000000000000000000000000100000000000
-- 013:800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000800056000000000000100000
-- 014:50001b000000000000000000000000000000000000102300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:c00019000000000000000000700019000000c00019000000000000000000d00019000000f0001900000050001b000000f00019000000d00019000000000000000000c00019000000000000000000000000000000100000000000000000000000c00019000000000000000000700019000000c00019000000000000000000d00019000000f0001900000050001b000000f00019000000d00019000000000000000000c00019000000000000000000000000000000700019000000000000000000
-- 016:c0001900000000000000000000000000000000000000000050001900000000000000000000000000000000000000000050001b10000000000000000050001b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 017:53701b00000000000000000010000000000053701b10000050001b00000010000000000050001b00000000000000000080001b00000000000000000000000000000070001b00000000000000000000000000000050001b000000000000000000d03019000000000000000000000000000000100000000000d00019000000f0001900000050001b000000d00019000000c00019000000d00019000000f00019000000a00019000000c00019000000000000000000000000000000100000000000
-- 018:53701b00000000000000000010000000000053701b10000050001b00000010000000000050001b00000000000000000080001b00000000000000000000000000000070001b00000000000000000000000000000050001b000000000000000000d03019000000000000000000000000000000100000000000d00019000000f0001900000050001b000000d00019000000c00019000000d00019000000f00019000000a00019000000c00019000000000000000000000000000000100000010300
-- </PATTERNS1>

-- <TRACKS>
-- 001:1c00001c00002418100000000000000000000000000000000000000000000000000000000000000000000000000000003d0000
-- 002:4465b64465b613d6b613d6b6000000000000000000000000000000000000000000000000000000000000000000000000a00000
-- 003:900d91a00e53e447857941a5e44785f841630d4f954dc0a5bd4f95c550630000000000000000000000000000000000006f01ef
-- 004:000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:2abbe84ebce85abda97ebce88200ba9202ba000000000000000000000000000000000000000000000000000000000000500000
-- </TRACKS>

-- <TRACKS1>
-- 000:1000411008c21008821808821038820c00000010001430821840821430821c4082000000000000000000000000000000c10000
-- </TRACKS1>

-- <SCREEN>
-- 000:777777777777777777777777777677777776777777767777777677777776777777777777777777777777777777777777777777777777777777dccd777777777777777777777cc777777777777777777777dccd777777777777767777777677777776777777777777777777dd777777777777777777777777
-- 001:77777777777777777777777777666777776667777766677777666777776667777777777777777777777777777777777777777777777777777cccccc7777777777777777777c22c7777777777777777777cccccc77777777777666777776667777766677777777777777777dd777777777777777777777777
-- 002:7777777777777777777777777763667777636677776366777763667777636677777777777777777777777777777777777777777777777777dcc11ccd77777777777777777c1221c77777777777777777dcc11ccd77777777776366777763667777636677777777777777dddd777777777777777777777777
-- 003:7777777777777777777777777636666776366667763666677636666776366667777777777777777777777777777777777777777777777777cc1111ccccccccccccccccccc112211ccccccccccccccccccc1111cc77777777763666677636666776366667777777777777dddd777777777777777777777777
-- 004:7777777777777777777777776666666666666666666666666666666666666666777777777777777777777777777777777777777777777777cc1111ccccccccccccccccccc111111ccccccccccccccccccc1111cc777777776666666666666666666666667777777777dddddd777777777777777777777777
-- 005:7777777777777777777777777663677676636776766367767663677676636776777777777777777777777777777777777777777777777777dcc11ccd77777777777777777c1221c77777777777777777dcc11ccd777777777663677676636776766367767777777777dddddd777777777777777777777777
-- 006:77777777777777777777777776733677767336777673367776733677767336777777777777777777777777777777777777777777777777777cccccc7777777777777777777c11c7777777777777777777cccccc77777777776733677767336777673367777777777dddddddd777777777777777777777777
-- 007:777777777777777777777777777337777773377777733777777337777773377777777777777777777777777777777777777777777777777777dccd777777777777777777777cc777777777777777777777dccd777777777777733777777337777773377777777777dddddddd777777777777777777777777
-- 008:6666666666666666666666666666666666666666666766666667666666676666666766666667666666676666666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666666766666667666666676666666cc666666766666667666666666666
-- 009:6666666666666666666666666666666666666666667776666677766666777666667776666677766666777666666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666667776666677766666777666666cc666667776666677766666666666
-- 010:6666666666666666666666666666666666666666667377666673776666737766667377666673776666737766666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666667377666673776666737766666cc666667377666673776666666666
-- 011:6666666666666666666666666666666666666666673777766737777667377776673777766737777667377776666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666673777766737777667377776666cc666673777766737777666666666
-- 012:6666666666666666666666666666666666666666777777777777777777777777777777777777777777777777666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666777777777777777777777777666cc666777777777777777766666666
-- 013:6666666666666666666666666666666666666666677376676773766767737667677376676773766767737667666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666677376676773766767737667666cc666677376676773766766666666
-- 014:6666666666666666666666666666666666666666676337666763376667633766676337666763376667633766666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666676337666763376667633766666cc666676337666763376666666666
-- 015:6666666666666666666666666666666666666666666336666663366666633666666336666663366666633666666666666666666666666666666cc6666666666666666666666666666666666666666666666cc6666666666666666666666336666663366666633666666cc666666336666663366666666666
-- 016:7777777777777777777777777777777777777777777777777777777777767777777677777776777777767777777677777777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777776777777767777777cc777777677777776777777777777
-- 017:7777777777777777777777777777777777777777777777777777777777666777776667777766677777666777776667777777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777766677777666777777cc777776667777766677777777777
-- 018:7777777777777777777777777777777777777777777777777777777777636677776366777763667777636677776366777777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777763667777636677777cc777776366777763667777777777
-- 019:7777777777777777777777777777777777777777777777777777777776366667763666677636666776366667763666677777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777636666776366667777cc777763666677636666777777777
-- 020:7777777777777777777777777777777777777777777777777777777766666666666666666666666666666666666666667777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777776666666666666666777cc777666666666666666677777777
-- 021:7777777777777777777777777777777777777777777777777777777776636776766367767663677676636776766367767777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777663677676636776777cc777766367767663677677777777
-- 022:7777777777777777777777777777777777777777777777777777777776733677767336777673367776733677767336777777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777673367776733677777cc777767336777673367777777777
-- 023:7777777777777777777777777777777777777777777777777777777777733777777337777773377777733777777337777777777777777777777cc7777777777777777777777777777777777777777777777cc7777777777777777777777777777773377777733777777cc777777337777773377777777777
-- 024:666666666666666666deefdd666666666666666666dccd666666666666666666666cc666666666666666666666dccd66666666666666666666dccd66666666666666666666666666666666666666666666dccd66666666666666666666dccd666666666666666666666cc666666766666666666666666666
-- 025:66666666666666666deefffd66666666666666666cccccc6666666666666666666c55c6666666666666666666cccccc666666666666666666cccccc666666666666666666666666666666666666666666cccccc666666666666666666cccccc6666666666666666666c55c66667776666666666666666666
-- 026:6666666666666666deeeeeef6666666666666666dcc11ccd66666666666666666c7557c66666666666666666dcc11ccd6666666666666666dcc11ccd6666666666666666666666666666666666666666dcc11ccd6666666666666666dcc11ccd66666666666666666c7557c6667377666666666666666666
-- 027:6666666666666666e414414ecccccccccccccccccc1111ccccccccccccccccccc775577ccccccccccccccccccc1111cccccccccccccccccccc1111cc6666666666666666666666666666666666666666cc1111cccccccccccccccccccc1111ccccccccccccccccccc775577c673777766666666666666666
-- 028:666666666666666634144143cccccccccccccccccc1111ccccccccccccccccccc777777ccccccccccccccccccc1111cccccccccccccccccccc1111cc6666666666666666666666666666666666666666cc1111cccccccccccccccccccc1111ccccccccccccccccccc777777c777777776666666666666666
-- 029:6666666666666666344444436666666666666666dcc11ccd66666666666666666c7557c66666666666666666dcc11ccd6666666666666666dcc11ccd6666666666666666666666666666666666666666dcc11ccd6666666666666666dcc11ccd66666666666666666c7557c6677376676666666666666666
-- 030:6666666666666666d344443d66666666666666666cccccc6666666666666666666c77c6666666666666666666cccccc666666666666666666cccccc666666666666666666666666666666666666666666cccccc666666666666666666cccccc6666666666666666666c77c66676337666666666666666666
-- 031:6666666666666666dd3333dd666666666666666666dccd666666666666666666666cc666666666666666666666dccd66666666666666666666dccd66666666666666666666666666666666666666666666dccd66666666666666666666dccd666666666666666666666cc666666336666666666666666666
-- 032:7777777777777777777777777777777777777777777777777777777777777777777cc7777776777777767777777677777776777777767777777cc7777776777777767777777677777777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 033:7777777777777777777777777777777777777777777777777777777777777777777cc7777766677777666777776667777766677777666777777cc7777766677777666777776667777777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 034:7777777777777777777777777777777777777777777777777777777777777777777cc7777763667777636677776366777763667777636677777cc7777763667777636677776366777777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 035:7777777777777777777777777777777777777777777777777777777777777777777cc7777636666776366667763666677636666776366667777cc7777636666776366667763666677777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 036:7777777777777777777777777777777777777777777777777777777777777777777cc7776666666666666666666666666666666666666666777cc7776666666666666666666666667777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 037:7777777777777777777777777777777777777777777777777777777777777777777cc7777663677676636776766367767663677676636776777cc7777663677676636776766367767777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 038:7777777777777777777777777777777777777777777777777777777777777777777cc7777673367776733677767336777673367776733677777cc7777673367776733677767336777777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 039:7777777777777777777777777777777777777777777777777777777777777777777cc7777773377777733777777337777773377777733777777cc7777773377777733777777337777777777777777777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 040:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666676666666766666667666666676666666cc6666667666666676666666766666667666666666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 041:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666777666667776666677766666777666666cc6666677766666777666667776666677766666666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 042:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666737766667377666673776666737766666cc6666673776666737766667377666673776666666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 043:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666667377776673777766737777667377776666cc6666737777667377776673777766737777666666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 044:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666677777777777777777777777777777777666cc6667777777777777777777777777777777766666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 045:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666667737667677376676773766767737667666cc6666773766767737667677376676773766766666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 046:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666667633766676337666763376667633766666cc6666763376667633766676337666763376666666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 047:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666633666666336666663366666633666666cc6666663366666633666666336666663366666666666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 048:777777777777777777777777777777777777777777777777777777777777777777dccd777777777777777777777677777776777777767777777cc7777776777777767777777677777776777777767777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 049:77777777777777777777777777777777777777777777777777777777777777777cccccc7777777777777777777666777776667777766677777c22c77776667777766677777666777776667777766677777c22c77777777777777777777777777777777777777777777777777777777777777777777777777
-- 050:7777777777777777777777777777777777777777777777777777777777777777dcc11ccd77777777777777777763667777636677776366777c1221c777636677776366777763667777636677776366777c1221c7777777777777777777777777777777777777777777777777777777777777777777777777
-- 051:7777777777777777777777777777777777777777777777777777777777777777cc1111cc7777777777777777763666677636666776366667c112211c7636666776366667763666677636666776366667c112211c777777777777777777777777777777777777777777777777777777777777777777777777
-- 052:7777777777777777777777777777777777777777777777777777777777777777cc1111cc7777777777777777666666666666666666666666c111111c6666666666666666666666666666666666666666c111111c777777777777777777777777777777777777777777777777777777777777777777777777
-- 053:7777777777777777777777777777777777777777777777777777777777777777dcc11ccd77777777777777777663677676636776766367767c1221c776636776766367767663677676636776766367767c1221c7777777777777777777777777777777777777777777777777777777777777777777777777
-- 054:77777777777777777777777777777777777777777777777777777777777777777cccccc7777777777777777776733677767336777673367777c11c77767336777673367776733677767336777673367777c11c77777777777777777777777777777777777777777777777777777777777777777777777777
-- 055:777777777777777777777777777777777777777777777777777777777777777777dccd777777777777777777777337777773377777733777777cc7777773377777733777777337777773377777733777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 056:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666667666666676666666cc6666667666666676666666766666667666666676666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 057:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666677766666777666666cc6666677766666777666667776666677766666777666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 058:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666673776666737766666cc6666673776666737766667377666673776666737766666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 059:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666737777667377776666cc6666737777667377776673777766737777667377776666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 060:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666667777777777777777666cc6667777777777777777777777777777777777777777666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 061:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666773766767737667666cc6666773766767737667677376676773766767737667666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 062:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666763376667633766666cc6666763376667633766676337666763376667633766666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 063:6666666666666666666666666666666666666666666666666666666666666666666cc6666666666666666666666666666663366666633666666cc6666663366666633666666336666663366666633666666cc666666666666666666666666666666666666666666666666666666666666666666666666666
-- 064:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777777767777777cc7777776777777767777777677777776777777767777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 065:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777777666777777cc7777766677777666777776667777766677777666777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 066:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777777636677777cc7777763667777636677776366777763667777636677777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 067:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777776366667777cc7777636666776366667763666677636666776366667777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 068:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777766666666777cc7776666666666666666666666666666666666666666777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 069:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777776636776777cc7777663677676636776766367767663677676636776777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 070:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777776733677777cc7777673367776733677767336777673367776733677777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 071:7777777777777777777777777777777777777777777777777777777777777777777cc7777777777777777777777777777777777777733777777cc7777773377777733777777337777773377777733777777cc777777777777777777777777777777777777777777777777777777777777777777777777777
-- 072:666666666666666666666666666666666666666666666666666666666666666666dccd66666666666666666666666666666666666666666666dccd66666666666666666666dccd66666666666666666666233266666766666666666666666666666666666666666666666666666666666666666666666666
-- 073:66666666666666666666666666666666666666666666666666666666666666666cccccc666666666666666666666666666666666666666666cccccc666666666666666666cccccc666666666666666666333c336667776666666666666666666666666666666666666666666666666666666666666666666
-- 074:6666666666666666666666666666666666666666666666666666666666666666dcc11ccd6666666666666666666666666666666666666666dcc11ccd6666666666666666dcc11ccd666666666666666623c31c32667377666666666666666666666666666666666666666666666666666666666666666666
-- 075:6666666666666666666666666666666666666666666666666666666666666666cc1111cc6666666666666666666666666666666666666666cc1111cccccccccccccccccccc1111cccccccccccccccccc3c122333673777766666666666666666666666666666666666666666666666666666666666666666
-- 076:6666666666666666666666666666666666666666666666666666666666666666cc1111cc6666666666666666666666666666666666666666cc1111cccccccccccccccccccc1111cccccccccccccccccc333221c3777777776666666666666666666666666666666666666666666666666666666666666666
-- 077:6666666666666666666666666666666666666666666666666666666666666666dcc11ccd6666666666666666666666666666666666666666dcc11ccd6666666666666666dcc11ccd666666666666666623c13c32677376676666666666666666666666666666666666666666666666666666666666666666
-- 078:66666666666666666666666666666666666666666666666666666666666666666cccccc666666666666666666666666666666666666666666cccccc666666666666666666cccccc66666666666666666633c3336676337666666666666666666666666666666666666666666666666666666666666666666
-- 079:666666666666666666666666666666666666666666666666666666666666666666dccd66666666666666666666666666666666666666666666dccd66666666666666666666dccd66666666666666666666233266666336666666666666666666666666666666666666666666666666666666666666666666
-- 080:7777777777777777777777777777777777777777777777777777777777767777777cc7777776777777767777777777777777777777777777777777777777777777767777777cc777777677777776777777767777777677777776777777767777777777777777777777777777777777777777777777777777
-- 081:7777777777777777777777777777777777777777777777777777777777666777777cc7777766677777666777777777777777777777777777777777777777777777666777777cc777776667777766677777666777776667777766677777666777777777777777777777777777777777777777777777777777
-- 082:7777777777777777777777777777777777777777777777777777777777636677777cc7777763667777636677777777777777777777777777777777777777777777636677777cc777776366777763667777636677776366777763667777636677777777777777777777777777777777777777777777777777
-- 083:7777777777777777777777777777777777777777777777777777777776366667777cc7777636666776366667777777777777777777777777777777777777777776366667777cc777763666677636666776366667763666677636666776366667777777777777777777777777777777777777777777777777
-- 084:7777777777777777777777777777777777777777777777777777777766666666777cc7776666666666666666777777777777777777777777777777777777777766666666777cc777666666666666666666666666666666666666666666666666777777777777777777777777777777777777777777777777
-- 085:7777777777777777777777777777777777777777777777777777777776636776777cc7777663677676636776777777777777777777777777777777777777777776636776777cc777766367767663677676636776766367767663677676636776777777777777777777777777777777777777777777777777
-- 086:7777777777777777777777777777777777777777777777777777777776733677777cc7777673367776733677777777777777777777777777777777777777777776733677777cc777767336777673367776733677767336777673367776733677777777777777777777777777777777777777777777777777
-- 087:7777777777777777777777777777777777777777777777777777777777733777777cc7777773377777733777777777777777777777777777777777777777777777733777777cc777777337777773377777733777777337777773377777733777777777777777777777777777777777777777777777777777
-- 088:6666666666666666666666666666666666666666666666666667666666676666666cc6666667666666676666666766666667666666666666666666666666666666666666666cc666666666666667666666676666666766666667666666676666666766666666666666666666666666666666666666666666
-- 089:6666666666666666666666666666666666666666666666666677766666777666666cc6666677766666777666667776666677766666666666666666666666666666666666666cc666666666666677766666777666667776666677766666777666667776666666666666666666666666666666666666666666
-- 090:6666666666666666666666666666666666666666666666666673776666737766666cc6666673776666737766667377666673776666666666666666666666666666666666666cc666666666666673776666737766667377666673776666737766667377666666666666666666666666666666666666666666
-- 091:6666666666666666666666666666666666666666666666666737777667377776666cc6666737777667377776673777766737777666666666666666666666666666666666666cc666666666666737777667377776673777766737777667377776673777766666666666666666666666666666666666666666
-- 092:6666666666666666666666666666666666666666666666667777777777777777666cc6667777777777777777777777777777777766666666666666666666666666666666666cc666666666667777777777777777777777777777777777777777777777776666666666666666666666666666666666666666
-- 093:6666666666666666666666666666666666666666666666666773766767737667666cc6666773766767737667677376676773766766666666666666666666666666666666666cc666666666666773766767737667677376676773766767737667677376676666666666666666666666666666666666666666
-- 094:6666666666666666666666666666666666666666666666666763376667633766666cc6666763376667633766676337666763376666666666666666666666666666666666666cc666666666666763376667633766676337666763376667633766676337666666666666666666666666666666666666666666
-- 095:6666666666666666666666666666666666666666666666666663366666633666666cc6666663366666633666666336666663366666666666666666666666666666666666666cc666666666666663366666633666666336666663366666633666666336666666666666666666666666666666666666666666
-- 096:777777777777777777777777777777777777777777dccd7777777777777777771dddc777777777777777777777dccd777776777777767777777777777777777777777777777cc777777777777777777777777777777677777776777777767777777677777776777777777777777777777777777777777777
-- 097:77777777777777777777777777777777777777777cccccc7777777777777777777cddc7777777777777777777cccccc7776667777766677777777777777777777777777777c22c77777777777777777777777777776667777766677777666777776667777766677777777777777777777777777777777777
-- 098:7777777777777777777777777777777777777777dcc11ccd77777777777777777c7444477777777777777777dcc11ccd77636677776366777777777777777777777777777c1221c7777777777777777777777777776366777763667777636677776366777763667777777777777777777777777777777777
-- 099:7777777777777777777777777777777777777777cc1111ccccccccccccccccccc7441144cccccccccccccccccc1111cc7636666776366667777777777777777777777777c112211c777777777777777777777777763666677636666776366667763666677636666777777777777777777777777777777777
-- 100:7777777777777777777777777777777777777777cc1111ccccccccccccccccccc444a414cccccccccccccccccc1111cc6666666666666666777777777777777777777777c111111c777777777777777777777777666666666666666666666666666666666666666677777777777777777777777777777777
-- 101:7777777777777777777777777777777777777777dcc11ccd77777777777777777444a4447777777777777777dcc11ccd76636776766367767777777777777777777777777c1221c7777777777777777777777777766367767663677676636776766367767663677677777777777777777777777777777777
-- 102:77777777777777777777777777777777777777777cccccc777777777777777777444444477777777777777777cccccc7767336777673367777777777777777777777777777c11c77777777777777777777777777767336777673367776733677767336777673367777777777777777777777777777777777
-- 103:777777777777777777777777777777777777777777dccd77777777777777777777444447777777777777777777dccd777773377777733777777777777777777777777777777cc777777777777777777777777777777337777773377777733777777337777773377777777777777777777777777777777777
-- 104:6666666666666666666666666666666666666666666cc6666666666666666666666666666667666666676666666cc6666667666666676666666766666666666666666666666cc666666666666666666666666666666666666666666666676666666766666667666666676666666666666666666666666666
-- 105:6666666666666666666666666666666666666666666cc6666666666666666666666666666677766666777666666cc6666677766666777666667776666666666666666666666cc666666666666666666666666666666666666666666666777666667776666677766666777666666666666666666666666666
-- 106:6666666666666666666666666666666666666666666cc6666666666666666666666666666673776666737766666cc6666673776666737766667377666666666666666666666cc666666666666666666666666666666666666666666666737766667377666673776666737766666666666666666666666666
-- 107:6666666666666666666666666666666666666666666cc6666666666666666666666666666737777667377776666cc6666737777667377776673777766666666666666666666cc666666666666666666666666666666666666666666667377776673777766737777667377776666666666666666666666666
-- 108:6666666666666666666666666666666666666666666cc6666666666666666666666666667777777777777777666cc6667777777777777777777777776666666666666666666cc666666666666666666666666666666666666666666677777777777777777777777777777777666666666666666666666666
-- 109:6666666666666666666666666666666666666666666cc6666666666666666666666666666773766767737667666cc6666773766767737667677376676666666666666666666cc666666666666666666666666666666666666666666667737667677376676773766767737667666666666666666666666666
-- 110:6666666666666666666666666666666666666666666cc6666666666666666666666666666763376667633766666cc6666763376667633766676337666666666666666666666cc666666666666666666666666666666666666666666667633766676337666763376667633766666666666666666666666666
-- 111:6666666666666666666666666666666666666666666cc6666666666666666666666666666663366666633666666cc6666663366666633666666336666666666666666666666cc666666666666666666666666666666666666666666666633666666336666663366666633666666666666666666666666666
-- 112:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777776777777767777777777777777777777777777777cc777777777777777777777777777777777777777777777777777777677777776777777767777777677777776777777777777
-- 113:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777766677777666777777777777777777777777777777cc777777777777777777777777777777777777777777777777777776667777766677777666777776667777766677777777777
-- 114:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777763667777636677777777777777777777777777777cc777777777777777777777777777777777777777777777777777776366777763667777636677776366777763667777777777
-- 115:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777636666776366667777777777777777777777777777cc777777777777777777777777777777777777777777777777777763666677636666776366667763666677636666777777777
-- 116:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7776666666666666666777777777777777777777777777cc777777777777777777777777777777777777777777777777777666666666666666666666666666666666666666677777777
-- 117:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777663677676636776777777777777777777777777777cc777777777777777777777777777777777777777777777777777766367767663677676636776766367767663677677777777
-- 118:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777673367776733677777777777777777777777777777cc777777777777777777777777777777777777777777777777777767336777673367776733677767336777673367777777777
-- 119:7777777777777777777777777777777777777777777cc7777777777777777777777777777777777777777777777cc7777773377777733777777777777777777777777777777cc777777777777777777777777777777777777777777777777777777337777773377777733777777337777773377777777777
-- 120:6666666666666666666666666666666666666666666666dd666666666666666666666666666666666666666666dccd66666666666666666666dccd66666666666666666666dccd66666666666666666666666666666666666666666666666666666666666666666666676666666766666667666666666666
-- 121:6666666666666666666666666666666666666666666666dd66666666666666666666666666666666666666666cccccc666666666666666666cccccc666666666666666666cccccc6666666666666666666666666666666666666666666666666666666666666666666777666667776666677766666666666
-- 122:66666666666666666666666666666666666666666666dddd6666666666666666666666666666666666666666dcc11ccd6666666666666666dcc11ccd6666666666666666dcc11ccd666666666666666666666666666666666666666666666666666666666666666666737766667377666673776666666666
-- 123:66666666666666666666666666666666666666666666dddd6666666666666666666666666666666666666666cc1111cccccccccccccccccccc1111cccccccccccccccccccc1111cc666666666666666666666666666666666666666666666666666666666666666667377776673777766737777666666666
-- 124:666666666666666666666666666666666666666666dddddd6666666666666666666666666666666666666666cc1111cccccccccccccccccccc1111cccccccccccccccccccc1111cc666666666666666666666666666666666666666666666666666666666666666677777777777777777777777766666666
-- 125:666666666666666666666666666666666666666666dddddd6666666666666666666666666666666666666666dcc11ccd6666666666666666dcc11ccd6666666666666666dcc11ccd666666666666666666666666666666666666666666666666666666666666666667737667677376676773766766666666
-- 126:6666666666666666666666666666666666666666dddddddd66666666666666666666666666666666666666666cccccc666666666666666666cccccc666666666666666666cccccc6666666666666666666666666666666666666666666666666666666666666666667633766676337666763376666666666
-- 127:6661116666666666666116666666616616666666ddd11dd1666661666666166666666666666666166666666666dccd66666666666666666666dccd66666666666666666666dccd66666666666666666666666666666666666666666666666666666666666666666666633666666336666663366666666666
-- 128:771ccc1777177171771cc17711771c11c1777777111cc11c17111c117771c17717777711711771c17711717177711777117171777117717177117117777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 129:77711c1771c11c1c1771c171cc11c11ccc111171cc11c17171cc1c1c171ccc11c17771cc1cc11ccc11cc1c1c171cc171cc1c1c171cc11c1c11cc1cc1777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 130:7771c1771c1c1cc17771c11c1c1ccc11c11ccc1c1171c11c1c111cc17771c11c1c171c1c1c1c11c11c1c1cc1771c1c1c1c1c1c1771cc1cc11c1c11cc177777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 131:771c11771c1c1c177771c11cc171c171c171111c1171c11c1c111cc17771c11c1c171cc11c1c11c11cc11c17771c1c1cc11ccc171c1c1c171cc11c1c177777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 132:771ccc1771c11c17771ccc11cc11c1771c177771cc1ccc1c11cc1c1c17771c11c17771cc1c1c171c11cc1c17771c1c11cc1ccc171ccc1c1771cc1ccc177777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 133:777111777717717777711177117717777177777711711171771171717777717717777711717177717711717777717177117111777111717777117111777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 134:777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- 135:777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

