% rewrite a function on second order kernel prediction.
% average over two spatial and two temporal location.
% to do this. loop over x1, x2 and inside x1 x2, use vectorization for
% differnet tau.


function resp = Predict_CovToStim(cov, stim, varargin)
    % there are spatial structure in second order kernel.
    % response over time...
nMultiBars = 20;

for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

maxTau = size(cov,1)/nMultiBars;
nT = size(stim, 1);
resp_x = zeros(nT,nMultiBars, nMultiBars);

for q1 = 1:1:nMultiBars
    for q2 = 1:1:nMultiBars
        
        % part of the kernel.
        k_q1_q2 = cov((q1 - 1) * maxTau + 1 : q1 * maxTau, (q2 - 1) * maxTau + 1: q2 * maxTau);
        stim1 = stim(:, q1);
        stim2 = stim(:, q2);
        
        % first part of the response is zeros.
        resp_x(:, q1, q2) = ARMA2D_Pred_Stim(stim1,stim2,k_q1_q2);
    end
end
resp = sum(sum(resp_x,3),2);

end