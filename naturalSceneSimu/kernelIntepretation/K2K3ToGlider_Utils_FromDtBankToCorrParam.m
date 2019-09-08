function corrParam = K2K3ToGlider_Utils_FromDtBankToCorrParam(dtBank,order)
% corrParam should be a structure array.
% how do you create empty structure array? 
switch order
    case 2
        % construct corrParam
        dtBank = dtBank{1};
        nDt_Second = length(dtBank);
        corrParam = cell(nDt_Second,1);
        count = 1;
        for rr = 1:1:nDt_Second
            corrParam{count}.dt(1) = dtBank(rr);
            corrParam{count}.dt(2) = 0;
            corrParam{count}.order = 2;
            corrParam{count}.nameStr = num2str(corrParam{count}.dt(1));
            count = count + 1;
        end
    case 3
        dt1Bank = dtBank{1};
        dt2Bank = dtBank{2};
        % construct  corrParamThirdOrder
        nDt_1 = length(dt1Bank);
        nDt_2 = length(dt2Bank);
        nDt_Third = nDt_1 * nDt_2;
        nRespParam = nDt_Third;
        corrParam = cell(nRespParam,1);
        count = 1;
        for ii = 1:1:nDt_1
            for jj = 1:1:nDt_2
                corrParam{count}.dt(1) = dt1Bank(ii);
                corrParam{count}.dt(2) = dt1Bank(jj);
                corrParam{count}.order = 3;
                count = count + 1;
            end
        end
        for rr = 1:1:nRespParam
            corrParam{rr}.nameStr = [num2str( corrParam{rr}.dt(1)),',',num2str( corrParam{rr}.dt(2))];
        end
end
end