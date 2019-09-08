function [badImage] = AnaExtremImage(v,imageID,p)
% go ovet the velocity and find the imageID which gives out outliesrs
[~,indHRC] = PerV(p,v.HRC);
[~,indk2] = PerV(p,v.k2);
[~,indk3] = PerV(p,v.k3);
ind = indHRC & indk2 & indk3;

makeFigure;
h = histogram(imageID(~ind));
h.BinWidth = 1;
h.BinLimits = [1,422];
badImage = h.Values;
end