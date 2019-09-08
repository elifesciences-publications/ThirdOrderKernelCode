function [OLSMat] = tp_Compute_OLSMat_Rep(respData,stimData,stimIndexes,varargin)
% comput OLS Matrix used for kernel extraction.

% tp_kernels_OLS(respData,stimData,stimIndexes,'order',1,'maxTau',30,'nMultiBars',20,'reverseKernelFlag',false);
order = 1;
maxTau = 30;
nMultiBars = 20;
reverseKernelFlag = false;
reverseMaxTau = 0;
% there should also be a flag, which controls the direction of conting.

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
        for rr = 1:1:nRoi
            % for each roi, response will be shared between different bars.
            resp = respData{rr};  % could be put out. but more clear here.
            stimIndexesThisRoi = stimIndexes{rr};
            
            nT = length(respData{rr});
            %             RR = zeros(nTMat,1);
            %             stimInd = zeros(nTMat,reverseMaxTau + maxTau);
            %
            % instead of for loop, you can do it pretty fast. cool. Thanks,
            % Emilio!
            startInd = maxTau;
            endInd = nT - reverseMaxTau;
            nTMat = endInd - startInd + 1;
            
            % because it is really fast to calculate, do not store it?
            RR = resp(startInd:1:endInd);
            RR = RR - mean(RR);
            
            stimIndStart =  int32(stimIndexesThisRoi((startInd:1:endInd)));
            offSet = int32(0:1:maxTau - 1); % row vector.
            if reverseKernelFlag
                offSet = int32(-reverseMaxTau:1:maxTau - 1);
                stimIndStart = int32(stimIndStart);
            end
            offSet = repmat(offSet,[nTMat,1]);
            stimInd = bsxfun(@minus,stimIndStart,offSet);
            
            for qq = 1:1:nMultiBars
                stim = stimData(:,qq);
                SS = stim(stimInd);
                stimMatrix{qq,rr} = SS;
                
            end
            respMatrix{rr} = RR;
            
        end
        % for the second order...worry about that later...
    case 2
        for rr = 1:1:nRoi
            
            nT = length(respData{rr});
            %             RR = zeros(nT - maxTau + 1,1);
            %             stimInd = zeros(nT - maxTau + 1,maxTau);
            resp = respData{rr};  % could be put out. but more clear here.
            stimIndexesThisRoi = stimIndexes{rr};
            
            RR = resp(maxTau:1:nT);
            RR = RR - mean(RR);
            
            stimIndStart =  uint32(stimIndexesThisRoi((maxTau:1:nT)));
            offSet = uint32(0:1:maxTau - 1); % row vector.

            offSet = repmat(offSet,[nT - maxTau + 1,1]);
            stimInd = bsxfun(@minus,stimIndStart,offSet);
            % all the bars shared the same stimInd and response.
            
            for qq = 1:1:nMultiBars;
                stim_1 = stimData(:,qq);
                stim_2 = stimData(:,mod(qq,nMultiBars) + dx); % watch out for q == 20; if q == 20, q + 1 = 21? no mod(q+1,20)
                %                 SS_1 = zeros(nT - maxTau + 1,maxTau);
                %                 SS_2 = zeros(nT - maxTau + 1,maxTau);
                %                  SS = zeros(nT - maxTau + 1, maxTau^2);
                SS_1 = stim_1(stimInd);
                SS_2 = stim_2(stimInd);
                SS = OLSGenerationSS_OneDToTwoD(SS_1,SS_2);
                
                stimMatrix{qq,rr} = SS;
            end
            respMatrix{rr} = RR;
        end
end

OLSMat.stim = stimMatrix;
OLSMat.resp = respMatrix;