function [resp_ave, data_info, epoch_ID_ave] = SAC_AverageResponse_By(resp, data_info, ave_param, mode, epoch_ID)
%% assume the epoches index has been arranged properly... to ensure that. needs another function...
%% resp = time * trial * epoch * rios;
which_dim = find(cellfun(@(x)strcmp(ave_param, x), data_info.param_name));
epoch_index = data_info.epoch_index;

param_card = size(epoch_index);
n_param = length(param_card);
param_card_ave = param_card;
param_card_ave(which_dim) = [];

n_cell = length(resp);
resp_ave = cell(n_cell, 1);
n_epoch_each_trial = size(epoch_ID, 2);
epoch_ID_ave = zeros(prod(param_card_ave), n_epoch_each_trial);

%% Update response
for ii = 1:1:n_cell
    %% response.
    r_s = size(resp{ii});
    resp_reshape = reshape(resp{ii}, [r_s(1), r_s(2), param_card, r_s(4)]);
    if strcmp(mode, 'sum')
        resp_reshape_ave = sum(resp_reshape, which_dim + 2); %%
    elseif strcmp(mode, 'mean')
        resp_reshape_ave = mean(resp_reshape, which_dim + 2); %%
    elseif strcmp(mode, 'sub')
        resp_reshape_ave = -diff(resp_reshape,1,which_dim + 2); %% first - second.
    end
    resp_ave{ii} = reshape(resp_reshape_ave, [r_s(1), r_s(2), prod(param_card_ave), r_s(4)]);
end

%% update trial ID.
epoch_ID_reshape  = reshape(epoch_ID, [param_card, n_epoch_each_trial]);
epoch_ID_reshpae_perm = permute(epoch_ID_reshape, [1:which_dim-1, which_dim+1:n_param, n_param+1, which_dim]);
epoch_ID_reshpae_again = reshape(epoch_ID_reshpae_perm, [prod(param_card_ave), n_epoch_each_trial, param_card(which_dim)]);
if strcmp(mode, 'ave')
    epoch_ID_ave = cat(2, epoch_ID_reshpae_again(:,:,1), epoch_ID_reshpae_again(:,:,2));
elseif strcmp(mode, 'mean')
    epoch_ID_ave = cat(2, epoch_ID_reshpae_again(:,:,1), epoch_ID_reshpae_again(:,:,2));
elseif strcmp(mode, 'sub')
    epoch_ID_ave = cat(2, epoch_ID_reshpae_again(:,:,1), -epoch_ID_reshpae_again(:,:,2));
end

%% update the epoch_index
if length(param_card_ave)  == 1
    data_info.epoch_index = (1: prod(param_card_ave))';
else
    data_info.epoch_index = reshape(1: prod(param_card_ave),  param_card_ave);
end
data_info.param_name(which_dim) = [];
