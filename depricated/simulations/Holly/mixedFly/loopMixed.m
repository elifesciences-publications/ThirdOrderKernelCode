close all
clear all

%% Run mixedFly a bunch of times

dur = 1e4; whichOrder = [0 1 1];

for q = 1:10
    [ OLS2(:,:,q) OLS3(:,:,:,q) XC2(:,:,q) XC3(:,:,:,q) ] = mixedFly_function(dur,whichOrder);
end

figure; imagesc(mean(OLS2,3));
figure; imagesc(mean(XC2,3));

threeDvisualize_slices(length(XC3),9,removeDiag(mean(XC3,4)));
threeDvisualize_slices(length(OLS3),9,mean(OLS3,4));

save('mixedFlyLoop_save','OLS2','OLS3','XC2','XC3');