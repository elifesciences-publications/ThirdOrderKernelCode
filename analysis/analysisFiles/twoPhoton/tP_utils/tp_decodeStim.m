function [ totalStim ] = tp_decodeStim( alignedStimulusData, kernelInds )
% Takes in aligned stimulus data that is coded (many binary digits -> one
% big decimal number), outputs aligned binary data.

    nStimCodewords = size(alignedStimulusData,2) - 1;
    nRoi = size(alignedStimulusData{1},2);
    
    tic;
    %% Decode each word
    for q = 2:nStimCodewords+1 % first column is correlated sign
        for r = 1:nRoi
            totalCol{q,r} = [];
            thisCol = alignedStimulusData{q}(kernelInds,r);
            binCol = dec2bin(thisCol);
            nBits = size(binCol,2);
            for s = 1:nBits
                totalCol{q,r} = cat(2,totalCol{q,r},str2num(binCol(:,s)));
            end 
        end
        fprintf('Finished codeword %i out of %i. ', q-1, nStimCodewords); toc;
    end
    %% Concatenate
    for q = 1:nRoi
        totalStim{q} = [];
        for r = 2:9
            totalStim{q} = cat(2,totalStim{q},totalCol{r,q});
        end
        totalStim{q} = totalStim{q}*2-1;
    end

end

