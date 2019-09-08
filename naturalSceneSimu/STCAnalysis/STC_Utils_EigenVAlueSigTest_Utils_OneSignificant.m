function [hypothesis_accepted_flag, direction, cov_mat_without_P1, cov_mat_noise_without_P1,...
    eigen_value_noise, diag_D] = STC_Utils_EigenVAlueSigTest_Utils_OneSignificant(cov_mat, cov_mat_noise, alpha, varargin)
plotFlag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
% testing data
% 'D:\JuyueLog\2016_10_16\data_for_sigtest.mat';
%% first, get the eigenvalues of the cov_mat_noise;
n_noise = length(cov_mat_noise);
eigen_value_noise = zeros(n_noise, 2); % largest and smallest
eigen_vector_noise = cell(n_noise,2);
% MakeFigure;
diag_D_noise = cell(n_noise,1);
for nn = 1:1:n_noise
    [V,D] = eig(cov_mat_noise{nn});
    diag_D = D(eye(size(D)) > 0);
    
    diag_D_noise{nn} = diag_D;
    
    eigen_value_noise(nn,1) = diag_D(end); %largest
    eigen_value_noise(nn,2) = diag_D(1); %smallest
    
    eigen_vector_noise{nn,1} = V(:,end);
    eigen_vector_noise{nn,2} = V(:,1);
    % % instead of ploting the largest and smallest, try to plot the eigen values
    % % for noisy kernel as well...
    %     scatter(1:length(diag_D), diag_D,'filled','k');
    %     title('eigenvalues of shuffled kernel');
    %     hold on
end


%% second, get the eigenvalues of the cov_mat
[V,D] = eig(cov_mat);
diag_D = D(eye(size(D)) > 0);
eigen_value = zeros(2,1);
eigen_value(1) = diag_D(end); % should be the largest
eigen_value(2) = diag_D(1); % should be the smallest

eigen_vector = cell(2,1);
eigen_vector{1} = V(:,end);
eigen_vector{2} = V(:,1);

%% test whether it is significant.
% first, whether the largest is larger than noise.
eigen_value_noise_mean = mean(eigen_value_noise,1);
eigen_value_noise_std = std(eigen_value_noise, 0,1);

% estimate by Guassian?
% upper_conf_norm = norminv(1 - alpha, eigen_value_noise_mean(1),eigen_value_noise_std(1));
% lower_conf_norm = norminv(alpha, eigen_value_noise_mean(2),eigen_value_noise_std(2));

% use quantile?
% change this
% upper_conf_quantile = prctile(eigen_value_noise(:,1), 100 * (1-alpha));
% lower_conf_quantile = prctile(eigen_value_noise(:,2), 100 * alpha);

upper_conf_quantile = max(eigen_value_noise(:,1));
lower_conf_quantile = min(eigen_value_noise(:,2));

upper_conf = upper_conf_quantile;
lower_conf = lower_conf_quantile;
% plot the eigenvalue, and plot the bound there.


if eigen_value(1) >= upper_conf
    direction = 1;
    hypothesis_accepted_flag = false;
    % projected out the largest component.
    P = eigen_vector{1}; P = P/ (P' * P);
    P_noise =  eigen_vector_noise(:,1);
    
elseif eigen_value(2) <=  lower_conf
    direction = -1;
    hypothesis_accepted_flag = false;
    % projected out the smallest component.
    P = eigen_vector{2}; P = P./ (P' * P);
    P_noise =  eigen_vector_noise(:,2);
else
    direction = [];
    hypothesis_accepted_flag = true;
end

if hypothesis_accepted_flag
    cov_mat_without_P1 = [];
    cov_mat_noise_without_P1 = [];
else
    
    I = eye(size(cov_mat,2));
    cov_mat_without_P1 = (I - P * P') * cov_mat * (I - P * P');
    cov_mat_without_P1 = (cov_mat_without_P1 + cov_mat_without_P1')/2;
    %
    cov_mat_noise_without_P1 = cell(n_noise,1);
    for nn = 1:1:n_noise
        A = (I - P_noise{nn} * P_noise{nn}') *  cov_mat_noise{nn} * (I - P_noise{nn} * P_noise{nn}');
        cov_mat_noise_without_P1{nn} = (A + A')/2;
    end
end

if plotFlag
    
    % plot out the eigenvalues, and plot the lower and upper bound.
    MakeFigure;
    subplot(2,2,1)
    scatter(1:length(diag_D),diag_D,'filled','r');
    hold on
%     plot([1,length(diag_D)],[upper_conf_norm,upper_conf_norm],'r');
%     plot([1,length(diag_D)],[lower_conf_norm,lower_conf_norm],'r');
    plot([1,length(diag_D)],[upper_conf_quantile, upper_conf_quantile],'b');
    plot([1,length(diag_D)],[lower_conf_quantile, lower_conf_quantile ],'b');
%     legend('eigenvalue of the Winer Kernel','upper bound norm','lower bound norm','upper bound quantile','lower bound quantile',...
%         'Location','northwest');
     legend('eigenvalue of the Winer Kernel','upper bound quantile','lower bound quantile',...
        'Location','northwest');
    title(['significance leve is ', num2str(alpha), ' hypothesis accepted: ', num2str(hypothesis_accepted_flag)]);
    % also plot the other...
    for nn = 1:1:n_noise
        scatter(1:length(diag_D),diag_D_noise{nn},'filled','MarkerEdgeColor',[0.5,0.5,0.5],'MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',0.5);
    end
    scatter(1:length(diag_D),diag_D,'filled','r','LineWidth',0.1);
    ConfAxis;
    % also, label wether it is significant or not
    
    
    subplot(2,2,2)
    h{1} = histogram(eigen_value_noise(:,1));
    hold on
    h{2} = histogram(eigen_value_noise(:,2));
    Histogram_Untils_SetBinWidthLimitsTheSame(h)
    legend('largest eigenvalue','smallest eigenvalue');
    title('eigenvalue of the shuffled Winer Kernel');
    ConfAxis;
    
    subplot(2,2,3)
    qqplot(eigen_value_noise(:,1));
    title('QQ Plot of largest eigenvalue of shuffled WK');
    ConfAxis;
    
    subplot(2,2,4)
    qqplot(eigen_value_noise(:,2));
    title('QQ Plot of smallest eigenvalue of shuffled WK');
    % Guassian test.
    ConfAxis;
    %% look at the eigen vector...
    % find the largest several
    %     if ~hypothesis_accepted_flag
    %         MakeFigure;
    %         subplot(4,5,1);
    %         maxTau =16;
    %         nMultiBars = 10;
    %         quickViewOneKernel(reshape(P,[maxTau, nMultiBars]),1);
    %         title('Largest Eigenvector, WK');
    %         [~,I] = sort(eigen_value_noise(:,1),'descend');
    %         for nn = 1:1:19
    %             subplot(4,5,nn + 1)
    %             quickViewOneKernel(reshape(P_noise{I(nn)},[maxTau, nMultiBars]),1);
    %             if nn == 1
    %                 title('Largest Eigenvector, shuffled WK');
    %             end
    %         end
    %     end
    
    
    
end
