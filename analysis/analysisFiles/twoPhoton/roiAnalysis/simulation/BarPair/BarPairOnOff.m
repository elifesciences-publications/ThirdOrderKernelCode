function [ind1, ind2] = BarPairOnOff(t)
on1 = [200;650]/1000; % second;
ind1 = on1(1)<t & on1(2)>t;
on2 = [350;650]/1000; % second;
ind2 = on2(1)<t & on2(2)>t;
end