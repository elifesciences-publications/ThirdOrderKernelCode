%% Redo it.
function [resp_realign, trial_ID_realign, stim_info, data_info] = SAC_AppMot_OrganizeResp_AlignSpace(resp, stim_info, data_info, trial_ID)

%% You will reorganize the response...

%% This peace of code is just obscure... not sure what is happening. Abandon it. 
epoch_index = data_info.epoch_index;
param_card = size(epoch_index);
param_card_cut = param_card;

param_card_cut(4) = 2; %% lagposition.
epoch_index_cut = zeros(param_card_cut);

n_cell = length(resp);
resp_realign = cell(n_cell, 1); 
trial_ID_realign = zeros(prod(param_card_cut), 1); % only 16 trials.

for ii = 1:1:n_cell
    r_s = size(resp{ii});
    %% This must be wrong somehow...
    resp_realign{ii} = zeros([r_s(1), r_s(2), prod(param_card_cut), r_s(4)]);
    for xx = 1:1:param_card(1)
        for yy = 1:1:param_card(2)
            for kk = 1:1:param_card(3)
                %% what would be the index of the trial in resp_realign. happens to be in sub2ind style.
                index_new = [sub2ind(param_card_cut, xx,yy,kk,1), sub2ind(param_card_cut, xx,yy,kk,2)];
                %% what was the trial_ID of the trial in old resp. resp(index_old) has the parameters. you want.
                index_old = epoch_index(xx, yy, kk, 3-kk:4-kk); 
                trial_ID_realign(index_new) = trial_ID(index_old);
                epoch_index_cut(xx, yy, kk, :) = index_new; %% epoch_index is a organized
                resp_realign{ii}(:,:,index_new,:) = resp{ii}(:,:,index_old, :);
            end
        end
    end
end

data_info.epoch_index = epoch_index_cut;
data_info.stim_param.lagPos = [2,3];
