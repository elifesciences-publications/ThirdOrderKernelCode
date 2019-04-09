function [mixedsig, mixedfilters, CovEvals] = OmerPCA(dFoF, nPCs)
% [mixedsig, mixedfilters, CovEvals] = OmerPCA(dFoF, nPCs)
%
% Get principal frames and timetraces 
%
% Inputs:
%   dFoF - movie in delta F over F (maybe this should be over sqrt(F)
%   nPCs - number of principal components to be returned
%
% Outputs:
%   mixedsig - N x T matrix of N temporal signal mixtures sampled at T
%   points.
%   mixedfilters - N x X x Y array of N spatial signal mixtures sampled at
%   X x Y spatial points.
%   CovEvals - largest eigenvalues of the covariance matrix
%
% Eran Mukamel, Axel Nimmerjahn and Mark Schnitzer, 2009
% Email: eran@post.harvard.edu, mschnitz@stanford.edu

    %-----------------------
    % Check inputs

    if nargin<2 || isempty(nPCs)
        nPCs = 150;
    end

    [pixw,pixh,nt] = size(dFoF);
    npix = pixw*pixh;
    
    % Create covariance matrix
    covmat = create_tcov(dFoF);

    % Perform SVD on temporal covariance to get principal component traces
    [mixedsig, CovEvals] = cellsort_svd(covmat, nPCs, nt, npix);

    % Get principal component frames
    mixedfilters = reload_moviedata(dFoF, mixedsig, CovEvals);
    mixedfilters = reshape(mixedfilters, pixw,pixh,length(CovEvals));
end

function covmat = create_tcov(movIn)

    [pixw,pixh,nt] = size(movIn);
    npix = pixw*pixh;
    mov = reshape(movIn, npix, nt);

    c1 = (mov'*mov)/npix;
    movtm = mean(mov,1); % Average over space
    covmat = c1 - movtm'*movtm;
end

function [mixedsig, CovEvals] = cellsort_svd(covmat, nPCs, nt, npix)
    %-----------------------
    % Perform SVD

    covtrace = trace(covmat) / npix;

    opts.disp = 0;
    opts.issym = 'true';
    [mixedsig, CovEvals] = eigs(covmat, nPCs, 'LM', opts);  % pca_mixedsig are the temporal signals, mixedsig
    CovEvals = diag(CovEvals);
    if nnz(CovEvals<=0)
        nPCs = nPCs - nnz(CovEvals<=0);
        fprintf(['Throwing out ',num2str(nnz(CovEvals<0)),' negative eigenvalues; new # of PCs = ',num2str(nPCs),'. \n']);
        mixedsig = mixedsig(:,CovEvals>0);
        CovEvals = CovEvals(CovEvals>0);
    end

    mixedsig = mixedsig' * nt;
    CovEvals = CovEvals / npix;

    percentvar = 100*sum(CovEvals)/covtrace;
%     fprintf([' First ',num2str(nPCs),' PCs contain ',num2str(percentvar,3),'%% of the variance.\n'])
end

function [mixedfilters] = reload_moviedata(movIn, mixedsig, CovEvals)
    %-----------------------
    % Re-load movie data
    nPCs = size(mixedsig,1);

    Sinv = inv(diag(CovEvals.^(1/2)));

    [pixw,pixh,nt] = size(movIn);
    npix = pixw*pixh;
    mov = reshape(movIn, npix, nt);
    movtm = mean(mov,1); % Average over space
    movuse = mov - ones(npix,1) * movtm;
    mixedfilters = reshape(movuse * mixedsig' * Sinv, npix, nPCs);
end