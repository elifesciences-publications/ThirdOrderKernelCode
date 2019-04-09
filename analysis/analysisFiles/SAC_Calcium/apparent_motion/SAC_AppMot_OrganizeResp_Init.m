function [resp_reorganize, trial_ID_new, data_info] = SAC_AppMot_OrganizeResp_Init(resp, data_info, trial_ID)

epoch_index = data_info.epoch_index;
param_card = size(epoch_index);
n_param = length(param_card);
n_cell = length(resp);
resp_reorganize = cell(n_cell, 1);

for ii = 1:1:n_cell
    r_s = size(resp{ii});
    resp_reshape = zeros([r_s(1), r_s(2), param_card, r_s(4)]);
    trial_ID_reshape = zeros(param_card);
    if n_param == 4
        for xx = 1:1:param_card(1)
            for yy = 1:1:param_card(2)
                for kk = 1:1:param_card(3)
                    for zz = 1:1:param_card(4)
                        resp_reshape(:,:,xx,yy,kk,zz,:) = resp{ii}(:,:,epoch_index(xx, yy, kk, zz), :);
                        trial_ID_reshape(xx, yy, kk, zz) = trial_ID(epoch_index(xx, yy, kk, zz));
                    end
                end
            end
        end
    end
    resp_reorganize{ii} = reshape(resp_reshape, [r_s(1), r_s(2), prod(param_card), r_s(4)]);
    
end
data_info.epoch_index = reshape(1:prod(param_card), param_card);
trial_ID_new =  trial_ID_reshape(:);
end