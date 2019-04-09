function stim_mean_subtracted =  NS_KernelWithFilteredStim_Utils_PreProcess_Stim(FWHM,stim)
barWidth = 5;
degree_per_pixel = 1;
nMultiBars = size(stim, 2);
plotflag = false;
stim(stim == -1) = 0.05;
stim(stim == 1) = 0.95;
%% local filter
surroundf.spatial.FWHM = FWHM;% degree
surroundf.spatial.sig = surroundf.spatial.FWHM/ 2.3548; % degree
surroundf.spatial.GaussianRange = 2;
surroundf.spatial.nSig =  round(surroundf.spatial.sig/degree_per_pixel); % number of pixel.
surroundf.spatial.range = -surroundf.spatial.GaussianRange  * surroundf.spatial.nSig : surroundf.spatial.GaussianRange  * surroundf.spatial.nSig;
surroundf.spatial.filter = normpdf(surroundf.spatial.range,0,surroundf.spatial.nSig)';

%% center filter
photoreceptor.spatial.distance = 5.1; % two photoreceptor is 5.1 degree separate.
photoreceptor.spatial.FWHM = 5.7; % 5.7 degree
photoreceptor.spatial.sig = photoreceptor.spatial.FWHM/2.3548;
photoreceptor.spatial.GaussianRange = 3;
photoreceptor.spatial.nSig = round(photoreceptor.spatial.sig /degree_per_pixel);
photoreceptor.spatial.range = - photoreceptor.spatial.GaussianRange * photoreceptor.spatial.nSig : photoreceptor.spatial.GaussianRange * photoreceptor.spatial.nSig;
photoreceptor.spatial.filter = normpdf(photoreceptor.spatial.range,0,photoreceptor.spatial.nSig)';

% what aboout laberl on?
stim_constrast = zeros(size(stim,1),round(nMultiBars * barWidth / degree_per_pixel));
stim_photoreceptor = zeros(size(stim_constrast));
sim_mean_photoreceptor = zeros(size(stim_constrast));
for ii = 1:1:size(stim,1)
    stim_photoreceptor(ii,: ) = PreProcess_Stim_Utils_Compute_Contrast(stim(ii,: ) , photoreceptor.spatial, barWidth);
    sim_mean_photoreceptor(ii,: ) = PreProcess_Stim_Utils_Compute_Contrast(stim_photoreceptor(ii,:), surroundf.spatial, degree_per_pixel);
end
stim_constrast = (stim_photoreceptor - sim_mean_photoreceptor)./sim_mean_photoreceptor;

%% do mean subtraction here.

stim_mean_subtracted = bsxfun(@minus, stim_constrast, mean( stim_constrast));

if plotflag
    t_plot = 10;
    MakeFigure;
    subplot(2,2,1)
    imagesc(stim(1:t_plot,:));colormap(gray);
    title('luminance stimulus');
    xlabel('X')
    ylabel('T')
    set(gca, 'XTick',[]);set(gca, 'YTick',[]);
    ConfAxis
    
    subplot(2,2,2)
    imagesc(stim_photoreceptor(1:t_plot,:));colormap(gray);
    title('photoreceptor');
    xlabel('X')
    ylabel('T')
    set(gca, 'XTick',[]);set(gca, 'YTick',[]);
    ConfAxis
    
    
    subplot(2,2,3)
    imagesc(sim_mean_photoreceptor(1:t_plot,:));colormap(gray);
    title('mean photoreceptor');
    xlabel('X')
    ylabel('T')
    set(gca, 'XTick',[]);set(gca, 'YTick',[]);
    ConfAxis
    
    subplot(2,2,4)
    imagesc(stim_constrast(1:t_plot,:));colormap(gray);
    title('constrast signal');
    xlabel('X')
    ylabel('T')
    set(gca, 'XTick',[]);set(gca, 'YTick',[]);
    ConfAxis
    MySaveFig_Juyue(gcf,'stim',sprintf('FWHM%d_process', FWHM), 'nFigSave',2,'fileType',{'png','fig'});
    
    MakeFigure;
    subplot(1,2,1)
    imagesc(stim(1:t_plot * 2,:));colormap(gray);
    title('luminance stimulus');
    xlabel('X')
    ylabel('T')
    set(gca, 'XTick',[]);set(gca, 'YTick',[]);
    ConfAxis
    
    subplot(1,2,2)
    imagesc(stim_mean_subtracted(1:t_plot * 2,:));colormap(gray);
    title('luminance stimulus');
    xlabel('X')
    ylabel('T')
    set(gca, 'XTick',[]);set(gca, 'YTick',[]);
    ConfAxis
    MySaveFig_Juyue(gcf,'stim',sprintf('FWHM%d_before_after', FWHM), 'nFigSave',2,'fileType',{'png','fig'});
end
end
% use this to extract kernel, look at one differences...

function stim_filtered = PreProcess_Stim_Utils_Compute_Contrast(stim, spatial, barWidth)
% calculate how much you need to extend your data.
% upsample the stim to 1 degree

degree_per_pixel = 1;
nMultiBars = size(stim, 2);
n_pixel_per_period = round(nMultiBars * barWidth / degree_per_pixel);

if barWidth == 5
    stim_temp = mat2cell(stim, size(stim, 1), ones(1, size(stim, 2)));
    stim_temp = cellfun(@(x) repmat(x, [1, barWidth]), stim_temp, 'UniformOutput', false);
    stim = cell2mat(stim_temp);
end
n_pixel_per_filter = length(spatial.filter) ;

n_period_half = ceil(floor(n_pixel_per_filter/2)/n_pixel_per_period);
n_period = n_period_half * 2 + 1; % that should be enough.

stim_this_fram_lum = repmat(stim, [1,n_period]);

% calculate the mean luminance. It is the same idea.. feed one filter in.
ind_start = (n_period_half * n_pixel_per_period + 1) + spatial.range;
ind = bsxfun(@plus, repmat(ind_start', [1, n_pixel_per_period]) , [0: n_pixel_per_period - 1]);
stim_this_frame_mat = stim_this_fram_lum(ind);
stim_filtered = spatial.filter' *  stim_this_frame_mat; % you got the mean luminance. After the luminance, computer contrast.

end