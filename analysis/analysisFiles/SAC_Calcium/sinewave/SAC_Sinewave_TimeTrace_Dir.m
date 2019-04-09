function SAC_Sinewave_TimeTrace_Dir(resp, data_info, epoch_ID)
epoch_index = data_info.epoch_index;
fVals = data_info.stim_param.fVals;
ff_str = {'1/2','\surd{2}/2', '1', '\surd{2}', '2', '2\surd{2}','4','4\surd{2}','8', '8\surd{2}'};
%% prefered red color. null blue color.
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp);

color_bank_two = zeros(2,4,3);
color_bank_two(1,:,:) = brewermap(4, 'Reds');
color_bank_two(2,:,:) = brewermap(4, 'Blues');

for ff = 1:1:10
    if ff == 1 || ff == 6
        MakeFigure;
    end
    subplot(5,1,mod(ff - 1, 5) + 1);
    
    for kk = 1:1:4
        % preferred direction
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_index(ff, kk, 1)),...
            resp_sem(:, epoch_index(ff, kk, 1)),...
            color_bank_two(1, kk,:),...
            'set_integrate_len', true,...
            'f_vals', fVals(ff)); hold on;
    end
    for kk = 1:1:4
        % null direction.
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_index(ff, kk, 2)),...
            resp_sem(:, epoch_index(ff, kk, 2)),...
            color_bank_two(2, kk,:),...
            'set_integrate_len', true,...
            'f_vals', fVals(ff)); hold on;
    end
    if ff == 1 || ff == 6
        legend('pref 1/15\circ', 'pref 1/30\circ', 'pref 1/60\circ', 'pref 1/90\circ',...
            'null 1/15\circ', 'null 1/30\circ', 'null 1/60\circ', 'null 1/90\circ');
    end
    set(gca, 'YLim', [-0.1, 0.2]);
    if ff == 5 || ff == 10
        xlabel('time (s)');
    end
    title(['TF: ', ff_str{ff}, ' Hz']);
    
end

%% plot 10 different time. black the differences. gray.
[resp_over_dir, ~, ~] = SAC_AverageResponse_By(resp, data_info, 'dirVal', 'sub', epoch_ID);
[~, resp_ave, resp_sem] = SAC_GetAverageResponse(resp_over_dir);
colors_bank = brewermap(4,'Dark2');

for ff = 1:1:10
    if ff == 1 || ff == 6
        MakeFigure;
    end
    subplot(5,1,mod(ff - 1, 5) + 1);
    for kk = 1:1:4
        SAC_SineWave_Plot_Utils_PlotTimeTraces(resp_ave(:, epoch_index(ff, kk, 1)),...
            resp_sem(:, epoch_index(ff, kk, 1)), ...
            colors_bank(kk,:),...
            'set_integrate_len', true,...
            'f_vals', fVals(ff));
        set(gca, 'YLim', [-0.1, 0.15]);
        title(['TF: ', ff_str{ff}, ' Hz']);
    end
    if ff == 1 || ff == 6
        
        legend('1/15\circ', '1/30\circ', '1/60\circ', '1/90\circ');
    end
    if ff == 5 || ff == 10
        xlabel('time (s)');
    end
end

end
%% How do you take a look at the response...
