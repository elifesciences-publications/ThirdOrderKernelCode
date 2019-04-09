close all
clear all

%% Test genPol and reshapePol

startDiag = 1;
maxTau = 5;
endDiag = 5;
wingSpan = 5;
whichOrder = [ 1 1 1 ];
stimVar = 1.32;
dist = 1;
tDur = 1e3;
x = randInput(stimVar,dist,tDur)';
y = randInput(stimVar,dist,tDur)';
stimTraces = [x y];

filters = exampleFilters(whichOrder,maxTau);
filters{3} = ones(5,5,5);
resp = flyResp(whichOrder,filters,maxTau,x,y,0,[1 0]);
[ locs,margin,seqInd ] = pickPol( whichOrder,startDiag,endDiag,wingSpan,1 );
[ polMat ] = genPol( locs,margin,seqInd,stimTraces,whichOrder );
coeffVect = polMat \ resp(margin:end);
[ k1_x_sh,k1_y_sh,k2_xy_sh,k3_xxy_sh,k3_yyx_sh ] = reshapePol( coeffVect, locs, margin, seqInd );

figure; subplot(2,1,1); plot(k1_x_sh(1:maxTau)); subplot(2,1,2), plot(filters{1});
figure; subplot(2,1,1); 
k2_xy = reshape(k2_xy_sh,[margin margin]);
imagesc(k2_xy(1:maxTau,1:maxTau)); title('extracted');
subplot(2,1,2); imagesc(filters{2}); title('original');
k3_xxy = reshape(k3_xxy_sh,[margin margin margin]);
threeDvisualize_slices(maxTau,maxTau,k3_xxy(1:maxTau,1:maxTau,1:maxTau));
threeDvisualize_slices(maxTau,maxTau,filters{3});
