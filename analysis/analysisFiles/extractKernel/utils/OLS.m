function [ kernels,margin ] = OLS( whichOrder,startDiag,endDiag,wingSpan,stimTraces,resp,visualize )
% Start-to-finish OLS fitting of an up-to-third order Volterra model

if nargin < 7
    visualize = 0;
end

%% Assemble Polynomial Matrix

[ locs,margin,seqInd ] = pickPol( whichOrder,startDiag,endDiag,wingSpan );
respLen = size(stimTraces,1)-(margin-1);       
   
if whichOrder(1)
    for zz = 1:seqInd(1)                
        x = locs{1}.x(zz);
        polMat(:,zz) = stimTraces(x:x+respLen-1,1);
        polMat(:,zz+seqInd(1)) = stimTraces(x:x+respLen-1,2);
    end  
end

if whichOrder(2)
    for zz = 1:seqInd(2)                
        x1 = locs{2}.x1(zz);
        x2 = locs{2}.x2(zz);
        polMat(:,2*seqInd(1)+zz) = stimTraces(x1:x1+respLen-1,1).* stimTraces(x2:x2+respLen-1,2);
    end
end   

if whichOrder(3)
    for zz = 1:seqInd(3)                
        x1 = locs{3}.x1(zz);
        x2 = locs{3}.x2(zz);
        y = locs{3}.y(zz);
        polMat(:,2*seqInd(1)+seqInd(2)+zz) = stimTraces(x1:x1+respLen-1,1).* stimTraces(x2:x2+respLen-1,1).* ...
            stimTraces(y:y+respLen-1,2);   
        polMat(:,2*seqInd(1)+seqInd(2)+seqInd(3)+zz) = stimTraces(x1:x1+respLen-1,2).* stimTraces(x2:x2+respLen-1,2).* ...
            stimTraces(y:y+respLen-1,1); 
    end
end         

%% Backslash
% keyboard
allKernel = polMat\resp(margin:end);

%% Reassemble Kernels

kernels.x = allKernel(1:seqInd(1));
kernels.y = allKernel(seqInd(1)+1:2*seqInd(1)); 

k_xy = allKernel(2*seqInd(1)+1:2*seqInd(1)+seqInd(2));
k_xxy = allKernel(2*seqInd(1)+seqInd(2)+1:2*seqInd(1)+seqInd(2)+seqInd(3)); 
k_yyx = allKernel(2*seqInd(1)+seqInd(2)+seqInd(3)+1:2*seqInd(1)+seqInd(2)+2*seqInd(3)); 

prek2_xy = zeros(margin,margin);
prek3_xxy = zeros(margin,margin,margin);
prek3_yyx = zeros(margin,margin,margin);
        
for rr = 1:seqInd(2)
    thisX = locs{2}.tau1(rr) + 1;
    thisY = locs{2}.tau2(rr) + 1;
    prek2_xy(thisX,thisY) =  k_xy(rr);
    kernels.xy = prek2_xy(:);
end                     
                
for rr = 1:seqInd(3)
    thisX1 = locs{3}.tau1(rr) + 1;
    thisX2 = locs{3}.tau2(rr) + 1;
    thisY = locs{3}.tau3(rr) + 1;
    prek3_xxy(thisX1,thisX2,thisY) = k_xxy(rr);
    prek3_xxy(thisX2,thisX1,thisY) = k_xxy(rr);
    prek3_yyx(thisX1,thisX2,thisY) = k_yyx(rr);
    prek3_yyx(thisX2,thisX1,thisY) = k_yyx(rr);
    kernels.xxy = prek3_xxy(:);
    kernels.yyx = prek3_yyx(:);
end  
       
%% Optionally, visualize

if visualize
    
    if whichOrder(1)
        figure; 
        subplot(2,1,1);
        plot(kernels.x);
        subplot(2,1,2);
        plot(kernels.y);
    end

    if whichOrder(2)
        figure; 
        imagesc(reshape(prek2_xy,[margin margin]));
    end

    if whichOrder(3)
        threeDvisualize_slices(margin,9,reshape(kernels.xxy,[margin margin margin]));
    end
    
end

end

