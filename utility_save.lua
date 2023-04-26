-- save/load funcs by BORB
    flr=math.floor
    function has(tbl,val)--returns which key
      for k,v in pairs(tbl)do if v==val then return k end end
      return false
    end
    function boolToBin(b)return b and 1 or 0 end
    function binToBool(b)return b==1 and true or false end
    function to32(tbl,bit,j)
      for i,v in ipairs(tbl) do
        if has({"boolean","nil"},type(v))then
          bit=bit+(boolToBin(v)<<j)
          j=j+1
        elseif type(v)=="number" then
          bit=bit+(flr(v)<<j)
          j=j+8--8-bit integers 0..255
        elseif type(v)=="table" then
          bit,j=to32(v,bit,j)
        end
        if j>32 then trace("liian iso taulukko")end
      end
      return bit,j
    end
    function from32(val,tbl,j)
      for i,v in ipairs(tbl) do
        if has({"boolean","nil"},type(v))then
          tbl[i]=binToBool(val>>j&1)
          j=j+1
        elseif type(v)=="number" then
          tbl[i]=val>>j&255
          j=j+8
        elseif type(v)=="table" then
          tbl[i],j=from32(val,tbl[i],j)
        end
      end
      return tbl,j
    end
