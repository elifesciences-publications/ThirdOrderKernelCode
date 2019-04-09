function value = moments2varskew(moment, mode)
% moments
    switch mode
        case 'mean'
            mean_value = moment(1);
            value = mean_value;
        case 'variance'
            value =  moment(2)- moment(1)^2;
            
        case 'skewness'
            variance_value = moment(2)- moment(1)^2;
            value = (moment(3) - 3 * moment(1) * variance_value - moment(1).^3)/(variance_value.^(3/2));
    end
end