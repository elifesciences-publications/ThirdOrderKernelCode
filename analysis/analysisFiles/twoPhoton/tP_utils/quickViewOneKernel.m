function quickViewOneKernel(kernel,order, varargin)
% quickViewOneKernel(kernel,order,'labelFlag',true,'posUnit',5,'timeUnit',1/60);
% show center...
% you need to transfer it to its prefered direction...
genotype = 'SAC_calcium';
labelFlag = true;
colorbarFlag = true;
% f = 30;
% f = 10.0526;
f = 15.625;
bin_stim_flag = false;
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end

switch order
    case 1
        [maxTau,nMultiBars] = size(kernel);
        if ~exist('barUse','var')
            barUse = 5:5:nMultiBars;
        end
    case 2
end


switch genotype
    case 'T4T5'
        posLabelStr = 'Bar position [degree]';
        timeLabelStr = 'Time[ms]';
        
        posUnit = 5;
        timeUnit = 1/60; % 60Hz,16.6 ms.
        maxtau_time = (maxTau - 1) * timeUnit;
        % 100 ms. maxTau * 1/60
        % what is the label for 100ms....
%         sample_time =  (0.1 : 0.1: maxtau_time); % 100 ms each.
        sample_time = 0.5;
        timeTick = sample_time/timeUnit; % index
        posTickLabelStr = strsplit(num2str((1:nMultiBars) * posUnit));
        timeTickLabelStr = strsplit(sprintf('%0.f_', sample_time * 1000),'_');
        
    case 'SAC'
        posLabelStr = 'Eccentricity';
        timeLabelStr = 'Time[ms]';
        timeUnit = 1/f; % 60Hz,16.6 ms.
        maxtau_time = (maxTau - 1) * timeUnit;
        sample_time =  (0.1 : 0.1: maxtau_time); % 100 ms each.
        timeTick = sample_time/timeUnit; % index
        timeTickLabelStr = strsplit(sprintf('%0.f_', sample_time * 1000),'_');
        
        % It is possible that the stimulus is binned
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
        
         case 'SAC_calcium'
            posLabelStr = 'Eccentricity [\mum]';
            timeLabelStr = 'Time[ms]';
            timeUnit = 1/f;
            maxtau_time = (maxTau - 1) * timeUnit;
            sample_time =  (0.5 : 0.5: maxtau_time); % 100 ms each.
            timeTick = sample_time/timeUnit; % index
            timeTickLabelStr = strsplit(sprintf('%0.f_', sample_time * 1000),'_');

%             spatial_location = 0:32:32*15;
            spatial_location = 0:16:16*15;
            posTickLabelStr  = cell(15,1); % absolute 10 positions.
            for qq = 1:1:length(spatial_location) - 1
                %                 posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq + 1:-1: qq));
                posTickLabelStr{qq} = sprintf('%d~%d', spatial_location(qq:qq+1));

            end

end

colormap_gen;
colormap(mymap);

switch order
    case 1
        imagesc(kernel);
        thisMaxVal = max(abs(kernel(:)));
        if thisMaxVal == 0;
            thisMaxVal = 1;
        end
        set(gca,'Clim',[-thisMaxVal thisMaxVal]);
        
        % you have to change the XTickLabel
        if colorbarFlag
            colorbar;
        end
        if labelFlag
            xlabel(posLabelStr);
            ylabel(timeLabelStr);
            
            ax = gca;
            ax.XTick = barUse; % determined by your self.
            ax.YTick =  timeTick; % not sure what to put here.
            ax.XTickLabel =  posTickLabelStr(barUse);
            ax.YTickLabel = timeTickLabelStr;
            clear ax
        end
        
    case 2
        maxTau = sqrt(length(kernel));
        K2 = reshape(kernel,[maxTau,maxTau]);
        imagesc(K2);
        thisMaxVal = max(abs(K2(:)));
        if thisMaxVal == 0;
            thisMaxVal = 1;
        end
        set(gca,'Clim',[-thisMaxVal thisMaxVal]);
        hold on;
        plot([1:maxTau],[1:maxTau],'k');
        hold off
        if colorbarFlag
            colorbar;
        end
        if labelFlag
            xlabel(timeLabelStr);
            ylabel(timeLabelStr);
            
            ax = gca;
            ax.XTick = 15:15:maxTau;
            ax.YTick = 15:15:maxTau;
            
            timeTickLabel = strsplit(num2str(ax.YTick * timeUnit,'%.2f '));
            ax.XTickLabel = timeTickLabel;
            ax.YTickLabel = timeTickLabel;
            clear ax
        end
end
end