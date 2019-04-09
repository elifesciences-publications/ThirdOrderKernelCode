function [testing_data, training_data] = STC_Utils_LN_Fitting_Utils_ModelSelection_SplitData(data_full,varargin)
testing_data_portion = 0.2;
folds = 100; % 10 folds cross-validation
% 90% of the training data is used for fitting.
evaluating_portion = 0.01;
for ii = 1:2:length(varargin)
      eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

% first, separate the data into testing data and training data

n = size(data_full, 1);
n_testing = round(n * testing_data_portion);

rand_ind = randperm(n);
testing_ind = rand_ind(1:n_testing);
training_ind = rand_ind(n_testing + 1:end);
testing_data{1} = data_full(testing_ind,:);
training_data_full = data_full(training_ind,:);

% second, separate the training data into cross-validation data

training_data = cell(folds,1);

n = size(training_data_full,1);
n_eval = round(evaluating_portion * n);
rand_ind = randperm(n); 

for ii = 1:1:folds
    % data come from the fitting    
    evaluating_ind = rand_ind((ii - 1) *  n_eval + 1 : min([ii * n_eval, n]));
    fitting_ind = ~ismember(1:n,evaluating_ind);
    training_data{ii}.fitting = training_data_full(fitting_ind,:);
    training_data{ii}.evaluating = training_data_full(evaluating_ind,:);
end

end