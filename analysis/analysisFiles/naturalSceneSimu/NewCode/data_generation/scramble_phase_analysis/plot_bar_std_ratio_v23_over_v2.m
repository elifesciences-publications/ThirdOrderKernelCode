function plot_bar_std_ratio_v23_over_v2(v_real, std_ratio_v23_over_v2_all, p_sig_std_ratio_v23_over_v2, color_bank, scene_condition_str)
n_vel = length(v_real);
if n_vel > 1
    b = bar(v_real, std_ratio_v23_over_v2_all');
else
    b = bar(std_ratio_v23_over_v2_all)    ;
end
b(1).FaceColor = color_bank{1};
b(2).FaceColor = color_bank{2};
b(3).FaceColor = color_bank{3};
set(gca, 'YLim', [0, 1.5]);
%% you want to plot the
for vv = 1:1:n_vel
    text(v_real(vv), 1.25, num2str(p_sig_std_ratio_v23_over_v2(vv)));
end
title('std ratio v23/v2');
legend('v2_{scramble}/v2_{ns}', scene_condition_str{1}, scene_condition_str{2} );
hold on
plot(get(gca, 'XLim'),[1,1],'k--');
xlabel('image velocity');
end
