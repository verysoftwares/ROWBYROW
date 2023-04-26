footer={msg=nil,t=0}

function describe(msg)
    footer.msg=msg
    footer.t=1
end

function draw_footer()
    if footer.t>0 then
        rect(0,136-7,240,7,13)
        local tw=print(footer.msg,0,-6,12,false,1,true)
        print(footer.msg,120-tw/2,136-7+1,12,false,1,true)
        footer.t=footer.t-1
    end
end

header={msg={},t=0}

function shout(msg)
    if not header.msg[1] then header.t=170 end
    ins(header.msg,msg)
end

function draw_header()
    if header.t>0 then
        local rc=2
        local tc=12
        if header.t>=160 or header.t<=10 then 
        rc=1; tc=13
        end
        
        rect(0,0,240,7,rc)
        local tw=print(header.msg[1],0,-6,tc,false,1,true)
        print(header.msg[1],120-tw/2,1,tc,false,1,true)
        header.t=header.t-1
        if header.t==0 then
            rem(header.msg,1)
            if header.msg[1] then header.t=170 end
        end
    end
end

