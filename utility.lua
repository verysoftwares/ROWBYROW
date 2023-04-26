-- from somebody online
    function deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
            setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end

function find(tb,what)
    for i,v in ipairs(tb) do 
        if v==what then return i end
    end
    return nil
end

function AABB(x1,y1,w1,h1, x2,y2,w2,h2)
    return (x1 < x2 + w2 and
            x1 + w1 > x2 and
            y1 < y2 + h2 and
            y1 + h1 > y2)
end

-- palette swapping by BORB
    function pal(c0,c1)
      if(c0==nil and c1==nil)then if TIC~=flee_fadeout then for i=0,15 do poke4(0x3FF0*2+i,i) end else for i=0,15 do poke4(0x3FF0*2+i,fade_palette[i]) end end
      else poke4(0x3FF0*2+c0,c1) end
    end
