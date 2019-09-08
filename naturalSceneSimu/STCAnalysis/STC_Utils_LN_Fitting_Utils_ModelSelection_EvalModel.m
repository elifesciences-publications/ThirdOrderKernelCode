function [fit_mse, eval_mse, testing_mse, fit_coe, best_order] = STC_Utils_LN_Fitting_Utils_ModelSelection_EvalModel(training_data, testing_data, order_max,fittingMethod, varargin)
xstart = {};
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

folds = length(training_data);

tic
fit_mse = zeros(folds,order_max);
eval_mse = zeros(folds,order_max);
for order = 1:1:order_max
    for ii = 1:1:folds
        %
        data_fit = training_data{ii}.fitting;
        data_eval = training_data{ii}.evaluating;
        % how do you deal with different function form? switch.
        switch fittingMethod
            % fitting
            case 'Poly_Free'
                fit_coe = LN_Fitting_Poly_Free(data_fit(:,1:2),data_fit(:,3),order); % you want to makesure they are called the same name.
                % evaluation
                meshflag = false;
                y_fit  = MyLN_Poly_Free(data_fit(:,1:2), order, fit_coe, meshflag );
                y_eval = MyLN_Poly_Free(data_eval (:,1:2), order, fit_coe, meshflag);
            case 'L_Poly_lsq' % you have to try a global solution. current difference is tiny. % try the gobal function. tonight!
                fun = @(L_polyfit_coe,xdata)MyLN_L_Polyfit(xdata, order, L_polyfit_coe, false);
                fit_coe = lsqcurvefit(fun, xstart{order}, data_fit(:,1:2), data_fit(:,3));
                meshflag = false;
                y_fit  = MyLN_L_Polyfit(data_fit(:,1:2), order, fit_coe, meshflag);
                y_eval = MyLN_L_Polyfit(data_eval(:,1:2), order, fit_coe, meshflag);
            case 'L_Poly_fminunc'
                % you only have third order. should be enough
        end
        
        fit_mse(ii,order) = 1/2 * mean((data_fit(:,3) - y_fit).^2);
        eval_mse(ii,order) = 1/2 * mean((data_eval (:,3) -  y_eval).^2);
        
    end
end
toc
% how do you plot it? you have the code where is it?
%%
% first, plot the fit_mse
fit_mse_mean = mean(fit_mse,1);
fit_mse_std = std(fit_mse,0,1);
fit_mse_sem = fit_mse_std./sqrt(folds);

eval_mse_mean = mean(eval_mse,1);
eval_mse_std = std(eval_mse,0,1);
eval_mse_sem = eval_mse_std./sqrt(folds);

if plotFlag
    % try scatter first.
    MakeFigure;
    subplot(2,2,1)
    % PlotXY_Juyue(1:order_max, fit_mse_mean,'errorBarFlag',true,'sem',fit_mse_sem);
    plot(1:order_max, fit_mse_mean,'b');
    hold on;
    plot(1:order_max, eval_mse_mean,'r');
    % try to plot the standard deviation.
    
    subplot(2,2,2);
    % fitting data
    for order = 1:1:order_max
        scatter(ones(1,folds) * order, fit_mse(:,order),5,'b','filled');
        hold on
    end
    hold on
    plot(1:order_max, fit_mse_mean,'b');
    
    % evaluating data
    
    hold on
    for order = 1:1:order_max
        scatter(ones(1,folds) * order, eval_mse(:,order),5,'r','filled');
        hold on
    end
    plot(1:order_max, eval_mse_mean,'r');
end


% determin what is the best order from the cross-validation data.
[~,best_order] = min(eval_mse_mean);
% collect all the training data, and fit the number. use it to calculate
% error for the testing data
training_data_all = cat(1,training_data{1}.fitting, training_data{1}.evaluating);
testing_data_all = testing_data{1};
switch fittingMethod
    % fitting
    case 'Poly_Free'
        fit_coe = LN_Fitting_Poly_Free(training_data_all(:,1:2), training_data_all(:,3),best_order); % you want to makesure they are called the same name.
        % evaluation
        meshflag = false;
        y_test  = MyLN_Poly_Free(testing_data_all(:,1:2), best_order, fit_coe, meshflag );
    case 'L_Poly_lsq' % you have to try a global solution. current difference is tiny. % try the gobal function. tonight!
        fun = @(L_polyfit_coe,xdata)MyLN_L_Polyfit(xdata, best_order, L_polyfit_coe, false);
        fit_coe = lsqcurvefit(fun, xstart{best_order}, training_data_all(:,1:2), training_data_all(:,3));
        meshflag = false;
        y_test  = MyLN_L_Polyfit(testing_data_all(:,1:2), best_order, fit_coe, meshflag);
    case 'L_Poly_fminunc'
        % you only have third order. should be enough
end

testing_mse = 1/2 * mean((testing_data_all(:,3) - y_test).^2);
end
