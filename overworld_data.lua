encounters={
    ['9:42']={spawn=function()
    enemies={{type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4}}
    shout('An AcroBat blocks the way!')
    end},
    ['12:42']={spawn=function() 
    enemies={{type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4},
             {type='AcroBat',hp=10,maxhp=10,minatk=1,maxatk=4}}
    shout('Gah! Now there\'s two of them!')
    end},
    ['15:39']={spawn=function() 
    enemies={{type='Maneki',hp=25,maxhp=25,minatk=1,maxatk=4}}
    shout('How\'d this cat get lost in the dungeon?')
    end},
    ['15:45']={spawn=function() 
    enemies={{type='MunSlime',hp=15,maxhp=15,minatk=2,maxatk=5}}
    shout('Eww, slime!')
    end},
    ['21:42']={spawn=function() 
    area=areas[2]
    wldplr={tx=32,ty=37,x=(32-30)*8,y=(37-34)*8}
    --for i,r in ipairs(area.roaming) do
    --  r.x=(r.tx-area.x)*8; r.y=(r.ty-area.y)*8
    --end
    --old_roaming=roaming
    --roaming={}
    overworld()
    if not has_read('sc_2_feedback') then
    start_dialogue('sc_2_feedback')
    TIC()
    else sc_t=t+1; TIC=overworld_roaming end
    end},
    ['32:37']={spawn=function()
    area=areas[1]
    wldplr={tx=21,ty=42,x=21*8,y=(42-34)*8}
    --roaming={}
    sc_t=t+1
    TIC=overworld_roaming
    end},
    ['rival1']={spawn=function() 
        enemies={{type='Rival',hp=35,maxhp=35,minatk=1,maxatk=6,spells={'Buff',['Buff']={maxcool=3,cooldown=0}},ai=function()
            if enemy_cast('Buff') then
            else enemy_attack()
            end
        end}}
    end},
    ['merchant1']={spawn=function()
        --TIC=shoppe
        if not has_read('sc_2_merch_intro') then start_dialogue('sc_2_merch_intro')
        else TIC=shoppe end
        sb_cam.y=0; sb_tgt='Buy'
        enemies={{type='Merchant',hp=60,maxhp=60,minatk=1,maxatk=9}}
        shoppe()
        TIC()
    end},
    ['sc_2_shyfairy']={spawn=function()
        --for i,r in ipairs(area.roaming) do
            --if r.tx==wldplr.tx and r.ty==wldplr.ty then
                --r.spawned=false
                --r.steps=5
            --end
        --end
        enemies={{type='ShyFairy',hp=10,maxhp=10,minatk=1,maxatk=3,spells={'Flee','Reflect',['Flee']={maxcool=3,cooldown=0},['Reflect']={maxcool=2,cooldown=0}},ai=function()
            enemy_cast('Flee')
        end}}
    end},
    ['35:49']={spawn=function() 
    area=areas[3]
    wldplr={tx=73,ty=36,x=(73-60)*8,y=(36-34)*8}
    --roaming={}
    sc_t=t+1
    TIC=overworld_roaming
    end},
    ['76:42']={spawn=function() enemies={{type='Mimic',adaptor=true,hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Mine',['Mine']={maxcool=0,cooldown=0}},ai=function()
        if not enemies[turni].mined then
        if enemy_cast('Mine') then
        enemies[turni].mined=true
        return
        end
        end
        local sp=enemies[turni].spells[math.random(#enemies[turni].spells)]
        while (enemies[turni].force and find(enemies[turni].force,sp)) or enemies[turni].spells[sp].cooldown>0 or enemies[turni].spells[sp].justcooled or (enemies[turni].queried and sp=='Query') do
            sp=enemies[turni].spells[math.random(#enemies[turni].spells)]
        end
        if enemy_cast(sp) then
        if sp=='Query' then enemies[turni].queried=true end
        else enemy_attack() end
    end}} 
    end},
    ['56:34']={spawn=function() start_dialogue('sc_2_demoarea') end},
    --{spawn=function()
    --    area=areas[4]
    --    wldplr={tx=104,ty=49,x=(104-90)*8,y=(49-34)*8}
    --    sc_t=t+1
    --    TIC=overworld_roaming
    --end},
    ['38:37']={spawn=function()
    enemies={{type='MercRat',hp=17,maxhp=17,minatk=1,maxatk=3,spells={'Meteor','Query','Lightning',['Meteor']={maxcool=spells['Meteor'].maxcool,cooldown=0},['Query']={maxcool=spells['Query'].maxcool,cooldown=0},['Lightning']={maxcool=spells['Lightning'].maxcool,cooldown=0}},phase=1,ai=function() 
        if enemies[turni].hp<enemies[turni].maxhp and not has_read('sc_2_rat_attack') then
            start_dialogue('sc_2_rat_attack')
            enemies[turni].minatk=3; enemies[turni].maxatk=5
            enemies[turni].phase=-1
            return
        end

        if enemies[turni].phase==-1 then
        if enemy_cast('Meteor') then
        elseif enemy_cast('Lightning') then
        else enemy_attack() end
        return
        end

        if enemies[turni].phase==1 or enemies[turni].phase==2 or enemies[turni].phase==3 then
        enemy_cast('Query')
        end
    end}}
    turn()
    start_dialogue('sc_2_rat_intro')
    TIC()
    end
    },
    ['44:40']={spawn=function() 
    enemies={{type='Sheebly',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Leech','SoulLeech',['Leech']={maxcool=1,cooldown=0},['SoulLeech']={maxcool=4,cooldown=0}},ai=function() 

        if enemies[turni].hp<=enemies[turni].maxhp/3 and plr.hp>enemies[turni].hp then
            if enemy_cast('SoulLeech') then
            return
            end
        end

        if enemy_cast('Leech') then
        else enemy_attack()
        end
    end}}
    end},
    --['47:34']={spawn=function()
    --    start_dialogue('sc_2_shroom_bros')
    --end},
    ['47:34']={spawn=function()
    enemies={{type='Shoobly',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Poison','AntiPsn',['Poison']={maxcool=3,cooldown=0},['AntiPsn']={maxcool=2,cooldown=0}},ai=function()

        if enemies[turni].poisonstack and enemies[turni].poisonstack>=8 then
            if enemy_cast('AntiPsn') then 
            return
            end
        end

        if enemy_cast('Poison') then    
        else enemy_attack()
        end
    end}}
    end},
    --['50:40']={spawn=function()
    --    start_dialogue('sc_2_shroom_bros2')
    --end},
    ['50:40']={spawn=function()
    enemies={{type='Shaably',hp=28,maxhp=28,minatk=1,maxatk=4,spells={'Spore','AntiSpore',['Spore']={maxcool=3,cooldown=0},['AntiSpore']={maxcool=3,cooldown=0}},ai=function()

        if enemies[turni].sporestack and enemies[turni].sporestack>=4 then
            if enemy_cast('AntiSpore') then
            return
            end
        end

        if enemy_cast('Spore') then
        else enemy_attack()
        end
    end}}
    end},
    ['38:46']={spawn=function()
        shout('You\'re gonna """love""" this encounter.')
        enemies={{type='Burr',hp=15,maxhp=15,minatk=1,maxatk=4,spells={'Taunt',['Taunt']={maxcool=3,cooldown=0}},ai=function() 
        if enemy_cast('Taunt') then
        else enemy_attack()
        end
    end}}
    end},
    ['73:36']={spawn=function()
    area=areas[2]
    wldplr={tx=35,ty=49,x=(35-30)*8,y=(49-34)*8}
    --roaming={}
    sc_t=t+1
    TIC=overworld_roaming
    end},
    ['56:43']={
    spawn=function()
    enemies={{type='Schwobly',hp=60,maxhp=60,minatk=1,maxatk=7,spells={'Poison','AntiPsn','Flame','Summon',['Flame']={maxcool=3,cooldown=0},['Poison']={maxcool=spells['Poison'].maxcool,cooldown=0},['AntiPsn']={maxcool=spells['AntiPsn'].maxcool,cooldown=0},['Summon']={maxcool=3,cooldown=0}},ai=function()
    if enemies[turni].phase==1 then
        if enemy_cast('Flame') then
            enemies[turni].phase=2
            return
        end
    end
    if enemies[turni].phase==2 then
        if enemy_cast('Poison') then
            TIC=attack_anim_poison
            oldactive=active
            active='Poison'
            enemyi=turni
            new=1
            enemies[turni].phase=3
            nmy_backfire=true
            return
        end
    end
    if enemies[turni].phase==3 then
        if enemy_cast('AntiPsn') then
            return
        end
    end
    end
    }}
    --TIC()
    --start_dialogue('sc_2_bosstest')
    --TIC()
    sc_t=t+1
    TIC=bossintro
    for i,sp in ipairs(enemies[1].spells) do
        for j,k in pairs(spells[sp]) do
            enemies[1].spells[sp][j]=k
        end
    end
    end},
    --spawn=function() endtime=time(); sc_t=t+1; TIC=endofdemo end},

    ['47:46']={spawn=function() 
    enemies={{type='Hidaldi',hp=20,maxhp=20,minatk=1,maxatk=5,spells={'Ice','Flame',['Ice']={maxcool=3,cooldown=0},['Flame']={maxcool=3,cooldown=0}},ai=function()

        enemies[turni].flamestack=enemies[turni].flamestack or 0
        if enemies[turni].icestack and enemies[turni].icestack-enemies[turni].flamestack>=4 then
            if enemy_cast('Flame') then
            return
            end
        end

        if enemy_cast('Ice') then
        else enemy_attack()
        end
    end}}
    end},
    ['56:37']={spawn=function()
    shout('Burr and Hidaldi have joined forces!')
    enemies={{type='Burr',hp=15,maxhp=15,minatk=1,maxatk=4,spells={'Taunt',['Taunt']={maxcool=3,cooldown=0}},ai=function()
        if enemy_cast('Taunt') then
        else enemy_attack()
        end
    end},{type='Hidaldi',hp=20,maxhp=20,minatk=1,maxatk=5,spells={'Ice','Flame',['Ice']={maxcool=3,cooldown=0},['Flame']={maxcool=3,cooldown=0}},ai=function()

        enemies[turni].flamestack=enemies[turni].flamestack or 0
        if enemies[turni].icestack and enemies[turni].icestack-enemies[turni].flamestack>=4 then
            if enemy_cast('Flame') then
            return
            end
        end

        if enemy_cast('Ice') then
        else enemy_attack() 
        end
    end}}
    end},
}

areas={
{x=0,y=34,c=15,
roaming={{sp=506,tx=21,ty=42,x=21*8,y=(42-34)*8,spawn=function() 
start_dialogue('sc_1_telepathy')
end}}},
{x=30,y=34,c=6,
roaming={{sp=507,tx=38,ty=43,x=(38-30)*8,y=(43-34)*8,spawn=function()
TIC=overworld_fadeout; cur_encounter=encounters['sc_2_shyfairy']; fr=260; fa=21
end},
{sp=160,tx=47,ty=43,x=(47-30)*8,y=(43-34)*8,spawn=function()
TIC=overworld_fadeout; cur_encounter=encounters['merchant1']; fr=260; fa=21
end}
}},
{x=60,y=34,c=3,roaming={}},
{x=90,y=34,c=14,roaming={}}}

area=areas[1]
