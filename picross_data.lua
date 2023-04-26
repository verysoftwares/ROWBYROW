picross={['0:0']='CatHead',
         ['5:0']='Rocket',
         ['10:0']='Piranha',
         ['15:0']='OwlEye',
                  
         ['20:0']='Humanoid',
         ['26:0']='ComfyBed',
                  
         ['44:0']='PalmTree',
                
         ['CatHead']={w=5,h=5},
         ['Rocket']={w=5,h=5},
         ['Piranha']={w=5,h=5},
         ['OwlEye']={w=5,h=5},
         
         ['Humanoid']={w=6,h=6},
         ['ComfyBed']={w=6,h=6},

         ['PalmTree']={w=7,h=7},
         
         ['Upgrade']={},
}

picno={
  ['CatHead']=1,
  ['Rocket']=2,
  ['Piranha']=3,
  ['OwlEye']=4,
  ['Humanoid']=5,
  ['ComfyBed']=6,
  ['Upgrade']=7,
}

function rev_picno(i)
  for k,v in pairs(picno) do
    if v==i then return k end
  end
end

plrpicross={}
grid=12
