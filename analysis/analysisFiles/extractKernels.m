function all_kernels = extractKernels(stimulusData, responseData, fsHere, plot_title_description, Z)
%Stimulus data and response data should already be appropriately
%interpolated to match in length!

filterLengthSeconds = 1; %in seconds
kernelOrder = 1;

loadFlexibleInputs(Z)

maxTau = round(filterLengthSeconds*fsHere);

if iscell(stimulusData)
    stimulusDataCell = stimulusData;
    responseDataCell = responseData;
    kernelsCell = cell(1, length(stimulusDataCell));
    for cell_ind=1:length(stimulusDataCell)
        stimulusData = stimulusDataCell{cell_ind};
        responseData = responseDataCell{cell_ind};
        
        kernels = zeros(maxTau, size(responseData, 2));
        stimulusRoll = rollup(stimulusData, maxTau);
        for i=1:size(responseData, 2)
            kernels(:, i) = extractTheKernels(kernelOrder, responseData(:, i), stimulusRoll, maxTau, fsHere);
        end
        kernelsCell{cell_ind} = kernels;
    end
    
    all_kernels = cell2mat(kernelsCell);%should work....
    
    %We're going to be plotting the SEMs using Matt's plot_err_patch
    %function
    std_all_kernels = std(all_kernels, 0, 2);
    sem_all_kernels = std_all_kernels/sqrt(size(all_kernels, 2));
    
    %Include the mean of the all the values; confusing terms: avg_ is
    %the average over the triggers; mean_ is the mean over the neurons
    %(averaged over the triggers)
    mean_kernels = mean(all_kernels, 2);
    all_kernels = [mean_kernels, all_kernels]'; %transpose for twoPhotonPlotter
    steps_back = 0;
    
%     figure_handle = figure;
%     
%     plot_title = sprintf('Order %d Kernel Extraction for %s', kernelOrder, plot_title_description);
%     twoPhotonPlotter(plot_title, all_kernels, sem_all_kernels', steps_back, fs, 'Stochastic Flashing', figure_handle, varargin{:}, 'plot_rois', false, 'combine_plots', true)

else
%     kernels = zeros(maxTau, size(responseData, 2));
    if size(stimulusData, 2)==1
        stimulusRoll = rollup(stimulusData, maxTau);
    end
    for i=1:size(responseData, 2)
        if size(stimulusData, 2) > 1
            stimulusRoll = rollup(stimulusData(:, i), maxTau);
        end
        all_kernels(:, i) = extractTheKernels(kernelOrder, responseData(:, i), stimulusRoll, maxTau, fsHere);
    end
    steps_back = 0;
    figure_handle = figure;
    
    plot_title = sprintf('Order %d Kernel Extraction for %s', kernelOrder, plot_title_description);
%     twoPhotonPlotter(plot_title, all_kernels', sem_kernels', steps_back, fs, 'Stochastic Flashing', figure_handle, varargin{:}, 'plot_rois', false, 'combine_plots', true)
    twoPhotonPlotter(plot_title, all_kernels', steps_back, fs, 'Stochastic Flashing', figure_handle, Z,  'plot_rois', false, 'combine_plots', true)
end
% hold on
%
% plot_dist = mean(max(kernel)-min(kernel));
% for i = 1:size(kernel, 2)
%     plot(linspace(0, filterLengthSeconds, length(kernel)), kernel(:, i)+plot_dist*(i-1));
% end
% title(sprintf('Order %d Kernel Extraction for %s', kernelOrder, fn));
% xlabel('Time (s)')
% hold off

end

% Many thanks to Holly "Captain Quaternion" Mandel for the guts of this kernel extraction code
function kernel = extractTheKernels(kernelOrder, responseData, stimulusRoll, maxTau, fs)
switch kernelOrder
    
    case 1
        stimulusPresentationRate = 180; %in Hz
        trialLen = length(responseData);
%         kernel = zeros(maxTau, length(responseData));
        normConst = (trialLen - (maxTau - 1))*fs/stimulusPresentationRate; %* inVar was here before... don't know what inVar was, though apparently it was usually 1
        respCut = responseData(maxTau:end);
        kernel = (stimulusRoll * respCut / normConst)';
    case 2
        
        evalc(['k2_xy_all(:,(qq-1)*freqRatio+rr) = twod_fast(maxTau,inVar,stim(:,1),stim(:,2),' sprintf('%s',whichBehav) ');']);
        D.kernels.k2_xy_all = k2_xy_all;
        
        if doRedundant
            evalc(['k2_xx_all(:,(qq-1)*freqRatio+rr) = twod_fast(maxTau,inVar,stim(:,1),stim(:,1),' sprintf('%s',whichBehav) ');']);
            evalc(['k2_yy_all(:,(qq-1)*freqRatio+rr) = twod_fast(maxTau,inVar,stim(:,2),stim(:,2),' sprintf('%s',whichBehav) ');']);
            D.kernels.k2_xx_all = k2_xx_all;
            D.kernels.k2_yy_all = k2_yy_all;
        end
        
    case 3
        
        evalc(['k3_xxy_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,1),stim(:,1),stim(:,2),' sprintf('%s',whichBehav) ');']);
        evalc(['k3_yyx_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,2),stim(:,2),stim(:,1),' sprintf('%s',whichBehav) ');']);
        D.kernels.k3_xxy_all = k3_xxy_all;
        D.kernels.k3_yyx_all = k3_yyx_all;
        
        if doRedundant
            evalc(['k3_xxx_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,1),stim(:,1),stim(:,1),' sprintf('%s',whichBehav) ');']);
            evalc(['k3_yyy_all(:,(qq-1)*freqRatio+rr) = threed_fast(maxTau,inVar,stim(:,2),stim(:,2),stim(:,2),' sprintf('%s',whichBehav) ');']);
            D.kernels.k3_xxx_all = k3_xxx_all;
            D.kernels.k3_yyy_all = k3_yyy_all;
        end
end
end


function [ matout ] = rollup( vector,depth )
%Rolls M x 1 vector into M x depth matrix where past time points lie along
%i coordinate. Returns a matrix of dims M-(depth-1) x Depth

len = length(vector);
% matout = zeros(depth,len-(depth-1));

for q = 1:len-(depth-1)
    matout(1:depth,q) = flipud(vector(q:q+depth-1));
end

end