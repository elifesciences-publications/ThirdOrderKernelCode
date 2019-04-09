function dfoverf = filterRoiTrace_calculate_dfoverf(method, resp)
PARAM_PERC = 0.1;
PARAM_LASTFRAME = 4;


if strcmp(method, 'last_frame')
    f0 = mean(resp(end-(PARAM_LASTFRAME - 1):end,:,:,:), 1);
    dfoverf = (resp - f0)./f0;
elseif strcmp(method, 'low_10')
    sorted_resp = sort(resp, 1);
    n = ceil(size(resp, 1) * PARAM_PERC);
    f0 = mean(sorted_resp(1:n,:,:,:),1);
    dfoverf = (resp - f0)./f0;
end

end