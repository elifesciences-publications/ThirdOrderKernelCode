function FigurePlot_Poster_WithinScene_SceneExample(stim_scene, title_str, h_axes, varargin)
stim_scene_mat = cell2mat(stim_scene);
n_scene = length(stim_scene); 
color_bank = [0,0,0];
n_hor_pixels = 927;
spatial_resolution = 360/n_hor_pixels;
x_plot = spatial_resolution:spatial_resolution:360;
legend_flag = flag;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

contrast_max = max(abs(stim_scene_mat(:)));
for ii = 1:1:n_scene
    if size(color_bank, 1) == 1
        color_scene = color_bank(1,:);
    else
        color_scene = color_bank(ii, :);
    end
    axes('Units', h_axes(ii).Units, 'Position', h_axes(ii).Position);
    one_row_this = stim_scene{ii};
    % by degree
    plot(x_plot, one_row_this,'color', color_scene);
%     if ii ~= n_scene
        set(gca, 'XTick',[],'XAxisLocation','origin');
%     else
%         set(gca, 'XTick', [90, 180, 270, 360])
%     end
    if ii == n_scene
        ylabel('contrast');
    end
    if ii == n_scene
        xlabel('spatial position [degree]')
    end
    %     ylabel(scene_str{ii})
    set(gca, 'YLim', [-contrast_max,contrast_max]);
    hold on
    plot(get(gca, 'XLim'),[0,0],'k-');
    set(gca, 'XLim', [0,361]);
  	title(title_str{ii});
    if legend_flag
        legend(num2str(ii))
    end
    ConfAxis
end
end