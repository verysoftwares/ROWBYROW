require('picross_data')
require('picross_board')

function picross_unlock()
    cls(2)
    if tri_a==nil then
    tri_a=120-2*13-6
    tri_b=68
    tri_w=13*5-2+1
    end
    
    textri(tri_a,tri_b,tri_a+tri_w,tri_b,tri_a,tri_b+tri_w,8*mx+0,8*my+0,8*mx+8*mw,8*my+0,8*mx+0,8*my+8*mh,true)
    textri(tri_a,tri_b+tri_w,tri_a+tri_w,tri_b,tri_a+tri_w,tri_b+tri_w,8*mx+0,8*my+8*mh,8*mx+8*mw,8*my+0,8*mx+8*mw,8*my+8*mh,true)
    
    tri_a=tri_a+(120-1*13-6-tri_a)*0.1
    tri_w=tri_w+(13*10-2-tri_w)*0.1
    tri_b=tri_b+(4-tri_b)*0.1
    
    if t-sc_t>=60 then
        for i=1,#picross[fmt('%d:%d',mx,my)] do
            print(sub(picross[fmt('%d:%d',mx,my)],i,i),8+i*6,136/2+sin(t*0.2+i)*4,t*0.2+i)
        end
    end
    if t-sc_t==240 then
        TIC=allyturn
        allyi=2
        sc_t=t+1
        ins(plrpicross,picross[fmt('%d:%d',mx,my)])
        if active~='Buff' and active~='SmolHeal' and active~='Taunt' and active~='Ice' and active~='Spore' and active~='Poison' and active~='AntiPsn' and active~='SoulLeech' and active~='AntiSpore' then sfx(8,12*6,6,3) end
        -- fresh Picross board
        clear_picross()
        if mw==5 then
        mx=mx+5
        if mx>=20 then mx=0 end
        end
        if mw==6 then
        mx=mx+6
        if mx>=32 then mx=20 end
        end
        if active=='Buff' then plr.buff=3; plr.done2=true end
        if active=='Taunt' then enemies[enemyi].taunt=3; enemies[enemyi].done3=true end
        if active=='Ice' then enemies[enemyi].ice=3; enemies[enemyi].icestack=enemies[enemyi].icestack or 0; enemies[enemyi].icestack=enemies[enemyi].icestack+2; enemies[enemyi].flamestack=enemies[enemyi].flamestack or 0; enemies[enemyi].done4=true end
        if active=='Spore' then enemies[enemyi].spore=3; enemies[enemyi].sporestack=enemies[enemyi].sporestack or 0; enemies[enemyi].sporestack=enemies[enemyi].sporestack+2; enemies[enemyi].done5=true end
        if active=='Poison' then enemies[enemyi].poison=4; enemies[enemyi].poisonstack=enemies[enemyi].poisonstack or 0; enemies[enemyi].poisonstack=enemies[enemyi].poisonstack+new; enemies[enemyi].done6=true end
        if active=='AntiPsn' then if plr.poison then plr.poisonstack=plr.poisonstack-new end end
        if active=='Leech' then plrdmg(-new*2); enemydmg(new*2) end
        if active=='SoulLeech' then plr.old_hp=plr.hp; plr.old_maxhp=plr.maxhp; plr.hp=enemies[enemyi].hp; plr.maxhp=enemies[enemyi].maxhp; enemies[enemyi].hp=plr.old_hp; enemies[enemyi].maxhp=plr.old_maxhp end
      if active=='AntiSpore' then plr.spore=3; plr.done5=true; plr.sporestack=plr.sporestack or 0; plr.sporestack=plr.sporestack-2 end
      if active=='Flame' then plr.flame=3; plr.done19=true; plr.flamestack=plr.flamestack or 0; plr.flamestack=plr.flamestack+2; plr.icestack=plr.icestack or 0 end
        if active=='Mine' then enemies[enemyi].force=plrspells end
        if active=='Reflect' then plr.reflect=3 end 
        if active=='Flee' then sc_t=t+1; TIC=flee_fadeout end
        if active=='Query' then sc_t=t+1; TIC=turn_query end
        if active=='Lightning' then for i,e in ipairs(enemies) do
        enemydmg(new*plrspells[active].mult,i)
        end end
        if active=='Meteor' then 
        enemydmg(new*plrspells[active].mult)
        end
        if active=='SmolHeal' or active=='MedHeal' then
        plrdmg(new*plrspells[active].mult)
        end
        if cur_encounter==encounters['56:43'] then
            cls(args.bg)
            draw_board(args)
            draw_header()
        end
    end
    
    t=t+1
end

function all(type,comp,sqx,sqy)
    if comp=='row' then 
        for sqxx=0,mw-1 do
            if mget(239-mw+1+sqxx,135-mh+1+sqy)~=type then
                return false
            end
        end
        return true
    end
    if comp=='column' then 
        for sqyy=0,mh-1 do
            if mget(239-mw+1+sqx,135-mh+1+sqyy)~=type then
                return false
            end
        end
        return true
    end
end

function only1(type,args,sqx,sqy)
    if args.select=='row' then 
        local c=0
        local out={}
        for sqxx=0,args.mw-1 do
            if mget(args.bx+sqxx,args.by+sqy)==0 and mget(args.ax+sqxx,args.ay+sqy)==type then
                c=c+1
                out.x=sqxx; out.y=sqy
            end
        end
        if c==1 then return out end
    elseif args.select=='column' then 
        local c=0
        local out={}
        for sqyy=0,args.mh-1 do
            if mget(args.bx+sqx,args.by+sqyy)==0 and mget(args.ax+sqx,args.ay+sqyy)==type then
                c=c+1
                out.x=sqx; out.y=sqyy
            end
        end
        if c==1 then return out end
    end
end

function clear_picross()
    for sqx=0,mw-1 do
    for sqy=0,mh-1 do
        mset(239-mw*2+1+sqx,135-mh+1+sqy,0)
        mset(239-mw+1+sqx,135-mh*2+1+sqy,0)
        mset(239-mw+1+sqx,135-mh+1+sqy,0)
    end
    end
    state=nil
end

function solved()
    for sqx=0,mw-1 do
    for sqy=0,mh-1 do
        if mget(mx+sqx,my+sqy)~=mget(239-mw+1+sqx,135-mh+1+sqy) then
            return false
        end
    end
    end
    return true
end

