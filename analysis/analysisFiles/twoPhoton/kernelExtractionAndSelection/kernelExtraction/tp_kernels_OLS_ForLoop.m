function [KK,OLSMat] = tp_kernels_OLS_ForLoop(respData,stimData,stimIndexes,varargin)
% Extracts and saves kernels from the output of tp_flickerSelectAndAlign
% loadFlexibleInputs(Z);
% get the resp and stim from Z.

% tp_kernels_OLS(respData,stimData,stimIndexes,'order',1,'maxTau',30,'nMultiBars',20);
order = 1;
maxTau = 30;
nMultiBars = 20;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% for each roi, there would be new response and new stimulus indexes.
% mean subtraction ?

nRoi = length(respData);
stimMatrix = cell(nMultiBars,nRoi); % content of each cell is a matrix.
respMatrix = cell(nMultiBars,nRoi); % content of each cell is a vector.
switch order
    case 1
        % You have to store the response and stimulu, so that you do not have to
        % recalculate them again.
        KK = zeros(maxTau,nMultiBars,nRoi);
        % how should I organize the data structure so that Omer could use it??
        for rr = 1:1:nRoi
            for qq = 1:1:nMultiBars
                
                resp = respData{rr};  % could be put out. but more clear here.
                stim = stimData(:,qq);
                stimIndexesThisRoi = stimIndexes{rr};
                
                nT = length(respData{rr});
                RR = zeros(nT - maxTau + 1,1);
                SS = zeros(nT - maxTau + 1,maxTau);
                
                % %         test code. If the the response and stimulus was aligned
                % %         correctly, I am using the correct data....
                %         k = rand(30,1);
                %         respFake = filter(k,1,stim);
                %         resp = respFake(stimIndexesThisRoi);
                
                for ii = maxTau:1:nT
                    jj = ii - maxTau + 1;
                    RR(jj) = resp(ii);
                    stimInd =  stimIndexesThisRoi(ii):-1:(stimIndexesThisRoi(ii) - maxTau + 1); % the stimulus is in 60Hz, stimIndexes(ii + 1) ~= stimIndexes(ii) + 1;
                    SS(jj,:) = stim(stimInd)';
                end

                RR = RR - mean(RR);
                kernel = SS\RR;
                
                KK(:,qq,rr) = kernel;
                stimMatrix{qq,rr} = SS;
                respMatrix{qq,rr} = RR;
            end
        end
        
        % for the second order...worry about that later...
    case 2 
        KK = zeros(maxTau^2,nMultiBars,nRoi);
        
        for rr = 1:1:nRoi
            for qq = 1:1:nMultiBars;
                resp = respData{rr};
                stim_1 = stimData(:,qq);
                stim_2 = stimData(:,mod(qq,nMultiBars) + 1); % watch out for q == 20; if q == 20, q + 1 = 21? no mod(q+1,20)
                stimIndexesThisRoi = stimIndexes{rr};
                % % test code
                % k = rand(maxTau,maxTau);
                % respFake = ARMA2D_Pred(stim_1,stim_2,k,0);
                % resp = respFake(stimIndexesThisRoi);
                %%
                nT = length(respData{rr});
                RR = zeros(nT - maxTau + 1,1);
                SS_1 = zeros(nT - maxTau + 1,maxTau);
                SS_2 = zeros(nT - maxTau + 1,maxTau);
                SS = zeros(nT - maxTau + 1, maxTau^2);
                
                for ii = maxTau:1:nT
                    jj = ii - maxTau + 1;
                    RR(jj) = resp(ii);
                    % tricky part. double check whether it works or not.
                    % this would also appear in the LN prediction. do you want to store
                    % that? probably.
                    stimInd =  stimIndexesThisRoi(ii):-1:(stimIndexesThisRoi(ii) - maxTau + 1); % the stimulus is in 60Hz, stimIndexes(ii + 1) ~= stimIndexes(ii) + 1;
                    SS_1(jj,:) = stim_1(stimInd)';
                    SS_2(jj,:) = stim_2(stimInd)';
                    
                    % depends on how do you define your filter....k(tau1,tau2); tau1 is the
                    % left, tau2 is the right. Always.
                    
                    [SS_1_Mesh,SS_2_Mesh] = ndgrid(SS_1(jj,:)',SS_2(jj,:));
                    SSTemp = SS_1_Mesh .* SS_2_Mesh;
                    SS(jj,:) = SSTemp(:);
                end
                RR = RR - mean(RR);
                kernel = SS\RR;
                
                KK(:,qq,rr) = kernel;
                stimMatrix{qq,rr} = SS;
                respMatrix{qq,rr} = RR;
            end
            keyboard;
        end
end

OLSMat.stim = stimMatrix;
OLSMat.resp = respMatrix;