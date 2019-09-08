function covMat = STC_Utils_SecondKernelToCovMat(kernels_full,varargin)
correctSelfTermFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '=', num2str(varargin{ii + 1}),';'])
end
[maxTauSquared,nMultiBars] = size(kernels_full{1});
maxTau = round(sqrt(maxTauSquared));
kernels_selfterm_corrected = kernels_full;
if correctSelfTermFlag
    for qq = 1:1:nMultiBars
        kernels_selfterm_corrected{1}(:,qq) = STC_Utils_SelfSecondKernelDiagnolInterp(kernels_full{1}(:,qq));
    end
else
%     disp('the diagonal matrix of self-self covmatrix is not interpolated by its nearby points');
end
% look at the filter, and make sure that they are good filters.

% start put the other. one by one
%%
covCell = cell(nMultiBars,nMultiBars); % the third dimension is rois
for ii = 1:1:nMultiBars
    for jj = 1:1:nMultiBars
        dx = mod(jj - ii,20);
        dx_ind = dx + 1; % ind referes to ind in kernels_all
        % do the interpolation before putting them at place.
        kernel_vec = kernels_selfterm_corrected{dx_ind}(:,ii);
        kernel_mat =  reshape(kernel_vec,[maxTau,maxTau]);
        covCell{ii,jj} = kernel_mat;
    end
end
covMat = cell2mat(covCell);

% MakeFigure; 
% subplot(2,2,1);
% quickViewOneKernel(covCell{8,1} ,1);
% colorbar
% title('8&1');
% subplot(2,2,2);
% quickViewOneKernel(covCell{1,8}' ,1);
% colorbar
% title('1&8');
% subplot(2,2,3);
% quickViewOneKernel(covCell{8,1} - covCell{1,8}',1);
% colorbar
% title('8&1 - 1&8');
% subplot(2,2,4);
% C = (covCell{8,1} - covCell{1,8}')/covCell{8,1};
% C(eye(64) > 0) = 0;
% quickViewOneKernel(C,1);
% colorbar% the error is uniform...why is that?
% title('(8&1 - 1&8)/(1&8)');
% is it proportionaly?

