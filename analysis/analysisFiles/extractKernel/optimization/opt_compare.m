close all
clear all

%% Side-by-side comparisons of threed_fast efficiency

%% Data processing - only need to do this once

processData = 0;
maxTau = 60;
inVar = 1;

if processData 
    dataPath = 'C:\Users\labuser\Documents\Data\paths\2014\07_03\08_53_05\path5flies.mat';
    D = grabData(dataPath);
    D.analysisParams.stimUpdate = D.data.params.flickerFreq; 
    D.analysisParams.interp = 'linear';
    
    kernelData = getKernelData(D);
    stimTraces = kernelData.stimTraces;
    turnTraces = kernelData.turnTraces;
    numFiles = kernelData.numFiles;

    for q = 1:numFiles
        stimTraces(:,:,q) = (stimTraces(:,:,q)) - mean(mean(stimTraces(:,:,q)));
          for r = 1:5          
                turnTraces(:,r,q) = turnTraces(:,r,q) - mean(mean(turnTraces(:,r,q)));
          end
    end
    
    save('optData','stimTraces','numFiles','turnTraces','kernelData');    
else
    load optData
end
    
%% Compare the two scripts

k3_reg = zeros(maxTau^3,numFiles*5);
k3_opt = zeros(maxTau^3,numFiles*5);

for q = 1:numFiles
    stim = (stimTraces(:,:,q)); 
    for r = 1:5  
         flyID = (q-1)*5+r;
         turn = turnTraces(:,r,q);
         tic
         k3_reg(:,flyID) = threed_fast(maxTau,inVar,stim(:,1),stim(:,1),stim(:,2),turn);
         toc
%          tic
%          k3_opt = threed_fast_opt(maxTau,inVar,stim(:,1),stim(:,1),stim(:,2),turn);
%          toc
         tic
         k3_opt(:,flyID) = hugDiagonal3(maxTau,inVar,stim(:,1),stim(:,1),stim(:,2),turn);
         toc
    end
end

k3_reg = mean(k3_reg,2);
k3_reg = reshape(k3_reg,maxTau,maxTau,maxTau);            
k3_opt = mean(k3_opt,2);
k3_opt = reshape(k3_opt,maxTau,maxTau,maxTau);