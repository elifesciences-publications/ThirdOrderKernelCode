function quickViewCovMat(cov_mat,varargin)
nMultiBars = 20;
genotype = 'T4T5';
labelFlag = true;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
if ~exist('barUse', 'var')
    barUse = 1:nMultiBars;
end
maxTau = size(cov_mat,1)/nMultiBars;
quickViewOneKernel(cov_mat,1,'labelFlag',false)

for ii = 1:1:nMultiBars
    hold on
    plot([0,nMultiBars * maxTau],[ii * maxTau, ii * maxTau],'k--');
end
for ii = 1:1:nMultiBars
    hold on
    plot([ii * maxTau, ii * maxTau],[0,nMultiBars * maxTau],'k--');
end

if labelFlag
    switch genotype
        case 'T4T5'
            set(gca, 'XTick' ,(1:nMultiBars) *  maxTau - maxTau/2, 'XTickLabel',strsplit(num2str([1:nMultiBars])));
            set(gca, 'YTick' ,(1:nMultiBars) *  maxTau - maxTau/2, 'YTickLabel',strsplit(num2str([1:nMultiBars])));
            xlabel('bar #','FontSize',18);
            ylabel('bar #','FontSize',18);
            % get a better label.
        case 'SAC'
            if ~ bin_stim_flag
                %             spatial_location = 150:-15:0;
                spatial_location = 0:15:150;
                posTickLabelStr  = cell(10,1); % absolute 10 positions.
                for qq = 1:1:length(spatial_location) - 1;
                    %                 posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq + 1:-1: qq));
                    posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq:qq+1));
                    
                end
            else
                %             spatial_location = 150:-30:0;
                spatial_location = 0:30:150;
                posTickLabelStr  = cell(5,1); % absolute 10 positions.
                for qq = 1:1:length(spatial_location) - 1;
                    %                 posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq + 1:-1: qq));
                    posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq: qq + 1));
                end
            end
            
            set(gca, 'XTick' ,(1:nMultiBars) *  maxTau - maxTau/2, 'XTickLabel',posTickLabelStr(barUse));
            set(gca, 'YTick' ,(1:nMultiBars) *  maxTau - maxTau/2, 'YTickLabel',posTickLabelStr(barUse));
            xlabel('Eccentricity','FontSize',18);
            ylabel('Eccentricity','FontSize',18);
        case 'SAC_calcium'

                %             spatial_location = 150:-30:0;
            spatial_location = 0:30:150;
            posTickLabelStr  = cell(5,1); % absolute 10 positions.
            for qq = 1:1:length(spatial_location) - 1;
                %                 posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq + 1:-1: qq));
                posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq: qq + 1));
            end

            set(gca, 'XTick' ,(1:nMultiBars) *  maxTau - maxTau/2, 'XTickLabel',posTickLabelStr(barUse));
            set(gca, 'YTick' ,(1:nMultiBars) *  maxTau - maxTau/2, 'YTickLabel',posTickLabelStr(barUse));
            xlabel('Eccentricity','FontSize',18);
            ylabel('Eccentricity','FontSize',18);
            
    end
    ax = gca;
    ax.YLabel.FontSize = 20;
    ax.XLabel.FontSize = 20;
    ax.LineWidth = 2;
end
set(gca,'FontSize',20,'box','off','FontName','Arial');
axis equal
end