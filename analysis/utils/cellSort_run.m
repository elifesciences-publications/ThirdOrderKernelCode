function [ ica_filters ] = cellSort_run( inPath, inName, varargin )
% Runs cellSort ICA toolbox up through component extraction step. 
%   Inputs:
%       inPath: directory of original movie for twoPhoton analysis ('path')
%       inName: filename of original movie, with appended tags for
%           alignment and channel
%   Outputs:
%       ica_filters: ICs

    nPC = 100;
    see = 0;
    nIC = 10;
    PCuse = [];
    truncLen = 0;
    medFilt = 1;

    for ii = 1:2:length(varargin)-1
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end  

    orgName = sprintf('%s/%s.tif',inPath,inName);
    itmName = sprintf('%s/%s_intermed.tif',inPath,inName);

    %% Step 0. Truncate, median-filter, and resave movie

    if medFilt
        delete(itmName);
        medFiltMov = median_filter_movie( orgName, itmName, 0, 0, truncLen );
        f0 = mean(medFiltMov,3);
    else
        itmName = orgName;
        numFrames = tiff_frames( orgName );
        for q = 1:numFrames
            oldMov(:,:,q) = imread(inPath,q);
        end
        f0 = mean(oldMov,3);
    end

    %% Step 1. PCA

    flims = []; dsamp = [];
    [mixedsig, mixedfilters, CovEvals, covtrace, movm, movtm] = ...
        CellsortPCA(itmName, flims, nPC, dsamp, inPath, []);
    % Breaks if nPC chosen too low

    %% Step 2. (Optional) manually select PCs to use

    if isempty(PCuse)
        [PCuse] = CellsortChoosePCs(itmName, mixedfilters);
    end

    %% Step 3. ICA

    mu = .3; termtol = .0001; maxrounds = 1e3;
    [ica_sig, ica_filters, ica_A, numiter] = CellsortICA(mixedsig, ...
        mixedfilters, CovEvals, PCuse, mu, nIC, [], termtol, maxrounds);

    %% Step 4. View ICA results

    if see
        mode = 'series'; tlims = []; dt = .01; ratebin = []; 
        plottype = 1; ICuse = [1:nIC]'; spt = []; spc = [];
        CellsortICAplot(mode, ica_filters, ica_sig, f0, tlims, dt, ratebin, plottype, ICuse, spt, spc)
    end
    
    %% Clean-up: delete intermediate movie
    
    delete(itmName);

end

