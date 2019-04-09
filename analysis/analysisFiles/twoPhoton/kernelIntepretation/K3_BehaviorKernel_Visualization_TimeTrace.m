function K3_BehaviorKernel_Visualization_TimeTrace(k3)
dt1Bank_ThirdOrder = [1:2]';
dt2Bank_ThirdOrder = [0:2]';
% construct  corrParamThirdOrder
nDt_1 = length(dt1Bank_ThirdOrder);
nDt_2 = length(dt2Bank_ThirdOrder);
nDt_Third = nDt_1 * nDt_2;
nRespParam = nDt_Third;
corrParamThirdOrder = cell(nRespParam,1);
count = 1;
for ii = 1:1:nDt_1
    for jj = 1:1:nDt_2
         corrParamThirdOrder{count}.dt(1) = dt1Bank_ThirdOrder(ii);
         corrParamThirdOrder{count}.dt(2) = dt2Bank_ThirdOrder(jj);
         corrParamThirdOrder{count}.order = 3;
        count = count + 1;
    end
end
for rr = 1:1:nRespParam
    %      corrParamThirdOrder{rr}.nameStr = ['dt1:',num2str( corrParamThirdOrder{rr}.dt(1)),',dt2:',num2str( corrParamThirdOrder{rr}.dt(2))];
     corrParamThirdOrder{rr}.nameStr = [num2str( corrParamThirdOrder{rr}.dt(1)),',',num2str( corrParamThirdOrder{rr}.dt(2))];
end

[averageCorrValue_3o, individualCorrTrace_3o] = K3ToGlider_One_CorrType(k3(:), corrParamThirdOrder);
MakeFigure;
subplot(2,2,1)
plot((1 : 32) /60,individualCorrTrace_3o,'lineWidth',2);
legendStr_3o =  cellfun(@(x) x.nameStr, corrParamThirdOrder,'UniformOutput',false);
legend(legendStr_3o);
xlabel('tims[ms]');
title('third order kernel');

subplot(2,2,2)
averageCorrValue = averageCorrValue_3o;
xTickLabelStr = legendStr_3o;
bar(averageCorrValue);
set(gca,'XTick',1:length(averageCorrValue));
set(gca,'XTickLabel',xTickLabelStr);
title('averaged kernel value at different dt interval');

end