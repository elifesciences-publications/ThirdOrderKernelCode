%% could you calculate conditional probability easily using your 
% use the joint probability calculate conditional probability, write a
% general function,

% sample from there. 
% need p_joint
function p_condition_x_on_var_y = MaxEntDis_Utils_Calculate_ConditionalProbability(p_factor, var_x, var_y)
% this would be a general factor.
% calculate var_x conditioned on var_y. % how could you do this? not that
% easy?
% first, marginalize out all irrelevant variable.
var_all = p_factor.var;
%% make sure that var_x is ascend, and var_y is ascend?
var_x = sort(var_x, 'ascend');
var_y = sort(var_y, 'ascend');
var_z = setdiff(var_all,[var_x;var_y]);

p_factor_xy = FactorMarginalization(p_factor, var_z);

%% first, find the index 
var_x_ind = find(ismember(p_factor_xy.var, var_x));
var_y_ind = find(ismember(p_factor_xy.var, var_y));

card = p_factor.card;
card_x = card(var_x);
card_y = card(var_y);
%%
p_val = reshape(p_factor_xy.val, p_factor_xy.card');

p_val_x_on_var_y = permute(p_val, [var_x_ind; var_y_ind]);
p_val_x_on_var_y = reshape(p_val_x_on_var_y, [prod(card_x), prod(card_y)]);

p_condition_x_on_var_y = bsxfun(@rdivide, p_val_x_on_var_y, sum(p_val_x_on_var_y, 1));

if ~isempty(find(isnan(p_condition_x_on_var_y)))
    keyboard;
end
% this might be very very easy?

%% just have to find the index.

% p_factor_var_x_on_var_y = zeros(prod(card_x), prod(card_y));
% 
% assignment_xy = IndexToAssignment(1: prod(p_factor_xy.card), p_factor_xy.card);
% assignment_y = IndexToAssignment(1: prod(card_y), card_y)
% assignment_x = IndexToAssignment(1: prod(card_x), card_x)
% % prod var_x * prod var_y terms. 
% for nn_y = 1:1:prod(card_y) % fixed a condition 
%     assignment_y_this = assignment_y(nn_y);
%     for nn_x = 1:1:prod(card_x)
%         assignment_x_this = assignment_x(nn_x);
%         % you should reaarange them and normalize.
%         % do not have to such hard..
%     end
% end


end
