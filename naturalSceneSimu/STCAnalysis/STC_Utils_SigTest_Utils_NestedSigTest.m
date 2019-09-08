function hypothesis_accepted_flag = STC_Utils_SigTest_Utils_NestedSigTest(cov_mat, cov_mat_noise,varargin)
MainName = 'nested_sig_test';
hypothesis_accepted_flag = false;
alpha = 0.01;
n_nested_max = 5;
saveFigFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

cov_mat_nested_test = cov_mat;
cov_mat_noise_nested_test = cov_mat_noise;

count = 0;
cov_mat_nested_test_store = cell(n_nested_max,1);
cov_mat_noise_nested_test_store = cell(n_nested_max,1);
eigen_value_noise_store = cell(n_nested_max,1);
eigen_value_store = cell(n_nested_max,1);

while ~hypothesis_accepted_flag
    
    count = count + 1;
    cov_mat_nested_test_store{count} = cov_mat_nested_test;
    cov_mat_noise_nested_test_store{count} = cov_mat_noise_nested_test;
    
    [hypothesis_accepted_flag, direction, cov_mat_nested_test, cov_mat_noise_nested_test, eigen_value_noise_store{count}, eigen_value_store{count}] ...
        = STC_Utils_EigenVAlueSigTest_Utils_OneSignificant(cov_mat_nested_test, cov_mat_noise_nested_test, alpha,'plotFlag', true);
    
    % this has not been settle down..
    if saveFigFlag
        MySaveFig_Juyue(gcf,MainName,['r#', num2str(count)],'nFigSave',2,'fileType',{'png','fig'});
    end
    if count > n_nested_max
        break
    end
end
