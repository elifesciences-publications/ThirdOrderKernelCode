function Z = tp_phaseAnalysis( Z )
% Computes Fourier transform of traces during cardinal direction epochs.
% The idea is to look for a peak in the power spectrum at 1 hz (the
% frequency of the test sine wave) and to compare the phases at this peak
% over space. 

%     if ~strcmp(Z.params.ROImethod,'differentialWatershed')
%         error([ 'Aborting: decomposePhases analysis can only be ' ...
%             'performed with differentialWatershed ROI selection' ]);
%     end
    
    loadFlexibleInputs
    
    % Get indices for left- and right- regions of cardinal epochs stim
    nFtPad = 1e3+1;
    nDir = size(Z.diffEp.differentialImages,3);
    nRoi = size(Z.ROI.roiMasks,3)-1; % minus one - the background!
    fs = Z.params.fs;
    fftAxis = linspace(-(nFtPad-1)/2*fs/nFtPad,(nFtPad-1)/2*fs/nFtPad,nFtPad);
    for q = 1:nDir
        breakPts = find(diff(Z.diffEp.lowerInds{q}) > 1);
        startMin = 1;
        for r = 1:length(breakPts)+1  
            if r == length(breakPts)+1
                inds{q,r} = Z.diffEp.lowerInds{q}(startMin:end);
            else
                inds{q,r} = Z.diffEp.lowerInds{q}(startMin:breakPts(r));
                startMin = breakPts(r) + 1;
            end            
            traces{q,r} = Z.filtered.roi_avg_intensity_filtered_normalized(inds{q,r},:); 
            traceLen(q,r) = size(traces{q,r},1);
        end 
    end
    
    % Pad with zeros so that all traces are the same length, then make into
    % a matrix because cells are less convenient
    maxLen = max(traceLen(:));
    realAxis = [1:1:maxLen] * 1/fs;
    tracesMat = zeros(maxLen,nRoi,size(traces,2));
    for q = 1:size(traces,1)
        for r = 1:size(traces,2)
            tracesMat(1:size(traces{q,r},1),:,q,r) = traces{q,r}(:,1:nRoi);
        end
    end
    
    % Average repeated presentations
    traceMeans = mean(tracesMat,4);
    traceMeans_ms = traceMeans - ...
        repmat(mean(traceMeans,1),[maxLen 1 1]);
%     traceMeans_ms = traceMeans;
    

    for q = 1:size(traceMeans,2)
        for r = 1:size(traceMeans,3)
            fts(:,q,r) = fft(traceMeans_ms(:,q,r),nFtPad);
            pwr(:,q,r) = fftshift(fts(:,q,r) .* conj(fts(:,q,r)));
            phase(:,q,r) = fftshift(atan2(imag(fts(:,q,r)),real(fts(:,q,r))));
        end
    end
%     
%     decoyAxis = [1:maxLen]/fs; % seconds
%     decoyCosine = cos(2*pi*decoyAxis);
%     decoyFt = fft(decoyCosine);
%     decoyFtAxis = linspace(-maxLen/2,maxLen/2,maxLen) * fs/maxLen;
% %     decoyFtAxis = [-(N-1)/2:1:(N-1)/2]*fs/N;
% %     decoyFt = fft(decoyCosine,N);
% %     decoyFtAxis = [-(N-1)/2:1:(N-1)/2]*fs/N;
%     figure; 
%     subplot(2,1,1); plot(decoyAxis,decoyCosine);
%     subplot(2,1,2); plot(decoyFtAxis,fftshift(abs(decoyFt)));
    
%     traces_ms{q,r} = traces{q,r} - mean(traces{q,r}(:));
%     fts{q,r} = fft(traces_ms{q,r},N);
    
    
    % select ds epochs
    nS = 3;
    [ valsL mostL ] = sort(Z.ROI.Lds(1:end-1));
    most{1} = mostL(end-nS+1:end);
    [ valsR mostR ] = sort(Z.ROI.Rds(1:end-1));
    most{2} = mostR(end-nS+1:end);
       
    figure;
    subplot(2,1,1);
    plot(repmat(realAxis,[nS 1])',traceMeans_ms(:,most{1},1)); 
    xlabel('time (s)'); ylabel('delta f/f');
    title('Top Traces: Left');
    subplot(2,1,2);
    plot(repmat(fftAxis,[nS 1])',abs(pwr(:,most{1},1)));
    xlabel('frequency (hz)'); ylabel('power');
    title('Top Traces FT: Left');
    
    figure;
    subplot(2,1,1);
    plot(repmat(realAxis,[nS 1])',traceMeans_ms(:,most{2},2));
    xlabel('time (s)'); ylabel('delta f/f');
    title('Top Traces: Right');
    subplot(2,1,2);
    plot(repmat(fftAxis,[nS 1])',abs(pwr(:,most{2},2))); 
    xlabel('frequency (hz)'); ylabel('power');
    title('Top Traces FT: Right');
    
    % plot phase on original image
    [ oneHzIndDisp oneHzPivot ] = min(abs(fftAxis-1)); % find neighborhood of one hz
    phaseMap = zeros(imgSize(1),imgSize(2),nDir);
%     colormap_gen;
%     par = mymap;
%     parula_wrap = vertcat(par,flipud(par));
    figure;
    for r = 1:nDir
        phaseImg{r} = ones(imgSize(1),imgSize(2),3);
        for q = 1:nRoi
%         for q = find(Z.ROI.shedIDs == r)
            [ peakVal oneHzInd(q,r) ] = max(pwr(oneHzPivot-9:oneHzPivot+9,q,r));
            oneHzInd(q,r) = oneHzInd(q,r) + (oneHzPivot-8);
%             figure; plot(fftAxis,pwr(:,q,r));
%             thisTitle = sprintf('Peak at %0.5g',fftAxis(oneHzInd(q,r)));
%             title(thisTitle);
            oneHzPhase(q,r) = phase(oneHzInd(q,r),q,r);
            phaseMap(:,:,r) = phaseMap(:,:,r) + ...
            	Z.ROI.roiMasks(:,:,q) * oneHzPhase(q,r);
            phaseImg{r}(:,:,1) = phaseImg{r}(:,:,1) - ...
                Z.ROI.roiMasks(:,:,q) * cos(oneHzPhase(q,r));
            phaseImg{r}(:,:,2) = phaseImg{r}(:,:,2) - ...
                Z.ROI.roiMasks(:,:,q) * sin(oneHzPhase(q,r));
        end
        subplot(2,2,r); 
        imagesc(phaseMap(:,:,r));
%         image(phaseImg{r});
%         colormap(parula_wrap);
    end   
    
    
%     for r = 1
%         figure;
%         for q = 1:nRoi
% %         for q = find(Z.ROI.shedIDs == r)
%             phaseX(q,r) = cos(oneHzPhase(q,r));
%             phaseY(q,r) = sin(oneHzPhase(q,r));
%         end
%         quiver(Z.ROI.roiCenterOfMass(1:end-1,2),Z.ROI.roiCenterOfMass(1:end-1,1),...
%             phaseX(:,r),phaseY(:,r));
%         axis ij
%         colormap(parula_wrap);
%     end
%     
%     
    
%     subplot(2,1,2);
%     plot(abs(pwr(:,mostR(end-2:end),2)));
    
    % debug: does this look right:
    
%     compTrace = zeros(size(Z.filtered.roi_avg_intensity_filtered_normalized,1),2);
%     for q = 1:2
%         for r = 1:size(inds,2)
%             compTrace(inds{q,r},q) = 1;
%         end
%         figure; plot(compTrace(:,q)); 
%         hold all;
%         plot(Z.filtered.roi_avg_intensity_filtered_normalized(:,most{q})); 
%         hold off;
%     end
%     
   
%     for q = 1:2
%         tracesCat{q} = [];
%         tracesFtCat{q} = [];
%         for r = 1:2
%             if size(traces{q,r},1) < maxLen
%              traces{q,r}(maxLen,:) = 0;
%             end
%             tracesCat{q} = cat(2,tracesCat{q},traces{q,r}(:,most{q}));
%             tracesFtCat{q} = cat(2,tracesFtCat{q},fts{q,r}(:,most{q}));
%         end
%     end


%     
%     figure; 
%     subplot(2,1,1); plot([1:maxLen],abs(tracesCat{1})); title('Traces');
%     subplot(2,1,2); plot(fftAxis,abs(tracesFtCat{1})); title('FT');
%     figure;
%     subplot(2,1,1); plot([1:maxLen],abs(tracesCat{2})); title('Traces');
%     subplot(2,1,2); plot(fftAxis,abs(tracesFtCat{2})); title('FT');
    
    
    % take Fourier transform of each
%     watershedTracesFFT = fft(catPlotDeMean,N,1);
%     watershedTracesPwr = watershedTracesFFT .* conj(watershedTracesFFT);
%     watershedTracesPhase = atan2(imag(watershedTracesFFT),real(watershedTracesFFT));
%     figure; plot(fftAxis,fftshift(watershedTracesPwr));
%     xlabel('hz'); ylabel('magnitude (non-sphered)'); title('Power Spectrum of Watershed Traces');
% 
%     plusTraces = zeros(1,size(imgFrames,3));
%     plusTraces(lowerInds{phaseAnalysisEpoch}) = 1;
%     figure; plot(plusTraces);
keyboard
    Z.phaseAnalysis.watershedTracesFFT = watershedTracesFFT;
    Z.phaseAnalysis.watershedTracesPwr = watershedTracesPwr;
    Z.phaseAnalysis.watershedTracesFFT = watershedTracesFFT;
    
end

