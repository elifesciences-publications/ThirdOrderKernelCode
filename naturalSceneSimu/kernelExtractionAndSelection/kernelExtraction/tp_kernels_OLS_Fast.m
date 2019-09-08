function [KK,OLSMat] = tp_kernels_OLS_Fast(respData,stimData,stimIndexes,varargin)
% Extracts and saves kernels from the output of tp_flickerSelectAndAlign
% loadFlexibleInputs(Z);
% get the resp and stim from Z.

% tp_kernels_OLS(respData,stimData,stimIndexes,'order',1,'maxTau',30,'nMultiBars',20);
order = 1;
maxTau = 30;
nMultiBars = 20;
dx = 1; % this might be useful in the future.
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% for each roi, there would be new response and new stimulus indexes.
% mean subtraction ?

nRoi = length(respData);
stimMatrix = cell(nMultiBars,nRoi); % content of each cell is a matrix.
respMatrix = cell(nRoi,1); % content of each cell is a vector.
switch order
    case 1
        tic
        % You have to store the response and stimulu, so that you do not have to
        % recalculate them again.
        KK = zeros(maxTau,nMultiBars,nRoi);
        % how should I organize the data structure so that Omer could use it??
        for rr = 1:1:nRoi
            % for each roi, response will be shared between different bars.
            resp = respData{rr};  % could be put out. but more clear here.
            stimIndexesThisRoi = stimIndexes{rr};
            
            nT = length(respData{rr});
            %             RR = zeros(nT - maxTau + 1,1);
            %             stimInd = zeros(nT - maxTau + 1,maxTau);
            %
            % instead of for loop, you can do it pretty fast. cool. Thanks,
            % Emilio!
            
            % because it is really fast to calculate, do not store it?
            RR = resp(maxTau:1:nT);
            RR = RR - mean(RR);
            
            stimIndStart =  stimIndexesThisRoi((maxTau:1:nT));
            offSet = uint32(0:1:maxTau - 1); % row vector.
            offSet = repmat(offSet,[nT - maxTau + 1,1]);
            stimInd = bsxfun(@minus,stimIndStart,offSet);
            
            for qq = 1:1:nMultiBars
                
                stim = stimData(:,qq);
                SS = stim(stimInd);
                
                kernel = SS\RR;
                
                KK(:,qq,rr) = kernel;
                stimMatrix{qq,rr} = SS;
                
            end
            respMatrix{rr} = RR;
            
        end
        toc
        % for the second order...worry about that later...
    case 2
        
        KK = zeros(maxTau^2,nMultiBars,nRoi);
        for rr = 1:1:nRoi
            
            nT = length(respData{rr});
            %             RR = zeros(nT - maxTau + 1,1);
            %             stimInd = zeros(nT - maxTau + 1,maxTau);
            resp = respData{rr};  % could be put out. but more clear here.
            stimIndexesThisRoi = stimIndexes{rr};
            
            RR = resp(maxTau:1:nT);
            RR = RR - mean(RR);
            
            stimIndStart =  stimIndexesThisRoi((maxTau:1:nT));
            offSet = uint32(0:1:maxTau - 1); % row vector.
            offSet = repmat(offSet,[nT - maxTau + 1,1]);
            stimInd = bsxfun(@minus,stimIndStart,offSet);
            
            
            for qq = 1:1:nMultiBars;
                stim_1 = stimData(:,qq);
                stim_2 = stimData(:,mod(qq,nMultiBars) + dx); % watch out for q == 20; if q == 20, q + 1 = 21? no mod(q+1,20)
                
                %                 SS_1 = zeros(nT - maxTau + 1,maxTau);
                %                 SS_2 = zeros(nT - maxTau + 1,maxTau);
                %                  SS = zeros(nT - maxTau + 1, maxTau^2);
                SS_1 = stim_1(stimInd);
                SS_2 = stim_2(stimInd);
                SS = OLSGenerationSS_OneDToTwoD(SS_1,SS_2);
                
                RR = RR - mean(RR);
                kernel = SS\RR;
                
                KK(:,qq,rr) = kernel;
                stimMatrix{qq,rr} = SS;
                
            end
            respMatrix{rr} = RR;
        end
end

OLSMat.stim = stimMatrix;
OLSMat.resp = respMatrix;