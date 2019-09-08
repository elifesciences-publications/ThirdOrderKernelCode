function Dout = LimitTime(Din, range)

    Dout = Din;
    if(range(2)-range(1) > 0)
        Dout.data.resp = Dout.data.resp(range(1):range(2),:);
        Dout.data.stim = Dout.data.stim(range(1):range(2),:);
    end
end