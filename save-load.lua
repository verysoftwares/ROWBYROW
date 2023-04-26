savetime=0

function savedata()
    --pmem(0-2): encounters
    --pmem(3-4): spells
    --pmem(5): cur area, plr hp 
    --         and world progress
    --pmem(6): merchant data
    --pmem(7): experience
    --pmem(8): game options
    --pmem(9-13): Picross state 
    --pmem(14-15): Picross abilities
    --pmem(16): level & dialogue progress
    --pmem(17): elapsed time
    --pmem(18): keywords
    local locations={
    }
    for i,v in ipairs(src_locations) do
        if v~=-1 then
        locations[i]=mget(v[1],v[2])==65
        else
        if i==1 then locations[i]=true 
        elseif i==5+1 then locations[i]=#(areas[1].roaming)==0
        elseif i==14+1 then
            locations[14+1]=true
            for i,v in ipairs(areas[2].roaming) do
                if v.sp==507 then locations[14+1]=false; break end
            end
        end
        end
    end
    local out1,out2=to32(locations,0,0)
    pmem(0,out1)
    
    local savespells={
    }
    for i,v in ipairs(spellorder) do
        if find(plrspells,v) then savespells[i]=true
        else savespells[i]=false end
    end
    local out1,out2=to32(savespells,0,0)
    pmem(3,out1)
    
    local savearea={
    }
    for i,v in ipairs(areas) do
        if v==area then savearea[1]=i; break end
    end
    ins(savearea,plr.hp)
    ins(savearea,plr.maxhp)
    ins(savearea,shrooms==3)
    local out1,out2=to32(savearea,0,0)
    pmem(5,out1)
    
    local merch={
    }
    local i=1
    local j=1
    while i<=#shoporder do
        if (shop_inv[j]==shoporder[i]) then
            --trace(fmt('shop_inv[%d]: %s',j,shop_inv[j]))
            --trace(fmt('shoporder[%d]: %s',i,shoporder[i]))
            merch[i]=false
            --trace(fmt('merch[%d]=%s',i,tostring(merch[i])))
            i=i+1
            j=j+1
        else
            merch[i]=true
            --trace(fmt('merch[%d]=%s',i,tostring(merch[i])))
            i=i+1
        end
        --trace('\n')
    end
    local out1,out2=to32(merch,0,0)
    --trace(out1)
    pmem(6,out1)
    --trace(out2)
    
    pmem(7,exp)
    local proglist={cur_lv,lvl_tgt,has_read('sc_2_feedback'),diag_db['sc_2_avenge']~=nil,has_read('sc_2_shroom_bros2'),has_read('sc_2_shroom_bros'),has_read('sc_2_merch_intro')}
    local out1,out2=to32(proglist,0,0)
    pmem(16,out1)
    
    --pmem(8) is saved during options
    
    save_pic1={mx,my,mw,mh}
    save_pic2={}
    save_pic3={}
    save_pic4={}
    save_pic5={}
    
    local tg=save_pic2
    local i=0
    for sqy=0,mh-1 do
    for sqx=0,mw-1 do
        ins(tg,mget(239-mw*2+1+sqx,135-mh+1+sqy)==16)
        i=i+1
        if i>=32 then tg=save_pic3 end
        if i>=64 then tg=save_pic4 end
        if i>=96 then tg=save_pic5 end
    end
    end
    
    for i=1,5 do
    local out1,out2=to32(_G['save_pic'..tostring(i)],0,0)
    pmem(9+i-1,out1)
    end
    
    local save_abl1={}
    local save_abl2={}
    local tg=save_abl1
    for i,p in ipairs(plrpicross) do
        ins(tg,picno[p])
        if i>=4 then tg=save_abl2 end
        if i>=8 then break end
    end
    
    local out1,out2=to32(save_abl1,0,0)
    pmem(14,out1)
    local out1,out2=to32(save_abl2,0,0)
    pmem(15,out1)
    
    pmem(17,math.floor(savetime+(time()-starttime)))
    trace(fmt('savetime: %d',math.floor(savetime+(time()-starttime))))
    
    local savewords={}
    for i,v in ipairs(src_keywords) do
        if find(keywords,v) then savewords[i]=true
        else savewords[i]=false end
    end
    local out1,out2=to32(savewords,0,0)
    pmem(18,out1)
    
    shout('Game saved!')
end

function loaddata()
    if pmem(0)==0 then shout('Game not loaded...') return end
    --else shout('Game loaded!') end

    reset_encounter()
    
    local locations={
    }
    for i=1,15 do ins(locations,false) end
    
    from32(pmem(0),locations,0)
    trace('Loaded')
    for i,v in ipairs(locations) do
        if src_locations[i]~=-1 then
            if v then mset(src_locations[i][1],src_locations[i][2],65)
            else mset(src_locations[i][1],src_locations[i][2],49) end
        else
            if i==1 then
                -- just a placeholder to mark existing save file
            elseif i==5+1 then
                if v then areas[1].roaming={} 
                else areas[1].roaming={{sp=506,tx=21,ty=42,x=21*8,y=(42-34)*8,spawn=function() 
                start_dialogue('sc_1_telepathy')
                end}}
                end
            elseif i==14+1 then
                if v then
                  areas[2].roaming={{sp=160,tx=47,ty=43,x=(47-30)*8,y=(43-34)*8,spawn=function()
                    TIC=overworld_fadeout; cur_encounter=encounters['merchant1']; fr=260; fa=21
                    end}}
                else
                  areas[2].roaming={{sp=507,tx=38,ty=43,x=(38-30)*8,y=(43-34)*8,spawn=function()
                    TIC=overworld_fadeout; cur_encounter=encounters['sc_2_shyfairy']; fr=260; fa=21
                    end},
                    {sp=160,tx=47,ty=43,x=(47-30)*8,y=(43-34)*8,spawn=function()
                    TIC=overworld_fadeout; cur_encounter=encounters['merchant1']; fr=260; fa=21
                    end}}
                end
            end
        end
    end

    local savespells={
    }
    for i=1,#spellorder do
    savespells[i]=false
    end
    from32(pmem(3),savespells,0)
    plrspells={}
    for i,v in ipairs(savespells) do
        if v then ins(plrspells,spellorder[i]);
        plrspells[spellorder[i]]=register_spell(spellorder[i])
        end
    end
    
    local savearea={0,0,0,false}
    from32(pmem(5),savearea,0)
    area=areas[savearea[1]]
    --if area==nil then area=areas[1] end
    if area==areas[1] then wldplr.tx=3; wldplr.ty=42; wldplr.x=(3-0)*8; wldplr.y=(42-34)*8 end
    if area==areas[2] then wldplr.tx=32; wldplr.ty=37; wldplr.x=(32-30)*8; wldplr.y=(37-34)*8 end
    if area==areas[3] then wldplr.tx=73; wldplr.ty=36; wldplr.x=(73-60)*8; wldplr.y=(36-34)*8 end
    if area==areas[4] then wldplr.tx=104; wldplr.ty=49; wldplr.x=(104-90)*8; wldplr.y=(49-34)*8 end
    plr.hp=savearea[2]
    plr.maxhp=savearea[3]
    plr.origmaxhp=plr.maxhp
    if savearea[4] then for i,v in ipairs({{tx=53,ty=38,id=35},{tx=53,ty=39,id=35},{tx=53,ty=40,id=33},{tx=54,ty=40,id=34},{tx=55,ty=40,id=34},{tx=56,ty=40,id=33},{tx=56,ty=41,id=35},{tx=56,ty=42,id=35},{tx=56,ty=43,id=49}}) do mset(v.tx,v.ty,v.id) end end

    local merch={}
    for i=1,#shoporder do
        merch[i]=false
    end
    from32(pmem(6),merch,0)
    while #shop_inv>0 do
        rem(shop_inv,1)
    end
    for i,v in ipairs(merch) do
        -- not bought/bought
        if not v then ins(shop_inv,shoporder[i]) 
        else 
        if shoporder[i]=='Sponge' then
            plr.sponge=true
        elseif shoporder[i]=='PermaBubble' then
            plr.permabubble=true
        elseif shoporder[i]=='Attack+' then
            plr.minatk=2; plr.maxatk=7
        elseif shoporder[i]=='IceSword' then
            plr.icesword=true
        end
        end
    end
    
    exp=pmem(7)
    local proglist={0,0,false,false,false,false,false}
    from32(pmem(16),proglist,0)
    cur_lv=proglist[1]
    lvl_tgt=proglist[2]
    if proglist[3] then diag_db['sc_2_feedback'].i=1 end
    if proglist[4] then diag_db['sc_2_avenge']={i=1} end
    if proglist[5] then diag_db['sc_2_shroom_bros2'].i=1 end
    if proglist[6] then diag_db['sc_2_shroom_bros'].i=1 end
    if proglist[7] then diag_db['sc_2_merch_intro'].i=1 end
    --cur_lv=0
    --for i,v in ipairs(levels) do
    --    if v>exp then lvl_tgt=i; break end
    --    cur_lv=cur_lv+1
    --end
        
    wldplr.tgt=nil
    
    load_opts()
    
    TIC=overworld_roaming
    sc_t=t+1
    header={msg={},t=0}

    clear_picross()

    local save_pic1={mx,my,mw,mh}
    from32(pmem(9),save_pic1,0)
    mx=save_pic1[1]; my=save_pic1[2]; mw=save_pic1[3]; mh=save_pic1[4]
    if mw==5 then grid=12 end
    if mw==6 then grid=10 end
    if mw==7 then grid=8 end
    if mw==8 then grid=7 end
    if mw==9 then grid=6 end
    if mw==10 then grid=5 end
    
    save_pic2={}
    save_pic3={}
    save_pic4={}
    save_pic5={}
    
    local tg=save_pic2
    local i=0
    for sqy=0,mh-1 do
    for sqx=0,mw-1 do
        ins(tg,false)
        i=i+1
        if i>=32 then tg=save_pic3 end
        if i>=64 then tg=save_pic4 end
        if i>=96 then tg=save_pic5 end
    end
    end
    
    for i=2,5 do
    from32(pmem(9+i-1),_ENV['save_pic'..tostring(i)],0,0)
    end
    
    local i=0
    local ioff=0
    local tg=save_pic2
    for sqy=0,mh-1 do
    for sqx=0,mw-1 do
        if tg[i-ioff+1] then mset(239-mw*2+1+sqx,135-mh+1+sqy,16); mset(239-mw+1+sqx,135-mh+1+sqy,16)
        else mset(239-mw*2+1+sqx,135-mh+1+sqy,0); mset(239-mw+1+sqx,135-mh+1+sqy,0) end
        i=i+1
        if i>=32 then ioff=32; tg=save_pic3 end
        if i>=64 then ioff=64; tg=save_pic4 end
        if i>=96 then ioff=96; tg=save_pic5 end
    end
    end

    plrpicross={}

    local save_abl1={0,0,0,0}
    local save_abl2={0,0,0,0}
    local tg=save_abl1
    from32(pmem(14),save_abl1,0)
    from32(pmem(15),save_abl2,0)
    local ioff=0
    for i=0,7 do
        --trace(i-ioff+1)
        --trace(tg[i-ioff+1])
        --trace(rev_picno(tg[i-ioff+1]))
        if tg[i-ioff+1]~=0 then ins(plrpicross,rev_picno(tg[i-ioff+1])) end
        if i>=3 then ioff=4; tg=save_abl2 end
    end
    
    local savewords={false,false,false,false,false}
    from32(pmem(18),savewords,0)
    keywords={}
    for i,v in ipairs(savewords) do
        if v then ins(keywords,src_keywords[i]) end
    end
    
    savetime=pmem(17)
    trace(fmt('savetime: %d',savetime))
    
    starttime=time()
    
    shout('Game loaded!')
end

function load_opts()
    if pmem(8)==0 then return end
    local opts={0,0}
    from32(pmem(8),opts,0)
    local tgt=({'ON','OFF'})[opts[1]]
    local cyc=options['Text anim'][1]
    while cyc~=tgt do
    rem(options['Text anim'],1)
    ins(options['Text anim'],cyc)
    cyc=options['Text anim'][1]
    end
    if cyc=='ON' then TEXT_WOB=true end
    if cyc=='OFF' then TEXT_WOB=false end
    local tgt=({'MED','FAST','SLOW'})[opts[2]]
    local cyc=options['Flashing'][1]
    while cyc~=tgt do
    rem(options['Flashing'],1)
    ins(options['Flashing'],cyc)
    cyc=options['Flashing'][1]
    end
    if cyc=='SLOW' then FLASH_SPD=0.08 end
    if cyc=='MED' then FLASH_SPD=0.3 end
    if cyc=='FAST' then FLASH_SPD=1 end
end
