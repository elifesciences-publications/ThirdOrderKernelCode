function [predictor_rank, lambda_bank] = OptimalGlider_Calculate_Predictor_Ranking(B, fitInfo)
predictor_pool = [];
n_lambda = size(B,2);
rank_now = 1;
predictor_rank = zeros(size(B, 1), 1);
lambda_bank = zeros(size(B, 1), 1);
for ii = 1:1:n_lambda
    predictor_in_this = find(B(:,n_lambda  - ii + 1) ~= 0);
    if ~(sum(ismember(predictor_in_this, predictor_pool)) == length( predictor_in_this)) % all the predictors used in this lambda has already been incorporated.
        predictor_not_in_pool = predictor_in_this(ismember(predictor_in_this, predictor_pool) == 0);
        lambda_bank(rank_now) = fitInfo.Lambda(n_lambda  - ii + 1);
        
        for jj = 1:1:length(predictor_not_in_pool)
            predictor_rank(predictor_not_in_pool(jj)) = rank_now ;
            predictor_pool = [predictor_pool, predictor_not_in_pool(jj)];
        end
        rank_now = rank_now + length(predictor_not_in_pool);
    end
end
predictor_rank(predictor_rank == 0) = 17;
test_flag = false;
if test_flag
    
    predictor_into_regression = cell(100,1);
    for ii = 1:1:100
        predictor_into_regression{ii} = find(B(:,ii) ~= 0);
    end
    
    %%
    MakeFigure;
    for ii  = 100:-1:1
        for jj = 1:1:length(predictor_into_regression{ii})
            scatter(100 - ii + 1, predictor_into_regression{ii}(jj),'k.');
            hold on
        end
    end
    xlabel('largest lambda to smallest lambda');
    ylabel('predictor label');
    ConfAxis
end
end

