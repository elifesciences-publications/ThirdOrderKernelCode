function AdvModelDtSweeps()
    modelTypes = {'HRC Serbe','HRC rect Behnia T4','HRC rect Behnia T5'};
    
    T = 4e3;
    X = 35;
    repeats = 80;
    updateRate = 60;
    pixelWidth = 5;
    spatialFilterType = 1;

    dts = 0:12;
    % Stimuli tensor has dimensions (time,cell,dt,parity)
    stimuli = zeros(T*repeats,2,length(dts)+1,2);
    for ii = 1:length(dts)
        dt = dts(ii);
        parity = 1;
        stimuli(:,:,ii,1) = make_ternary_stim(T*repeats,X,updateRate,pixelWidth,dt,parity,spatialFilterType);
        parity = -1;
        stimuli(:,:,ii,2) = make_ternary_stim(T*repeats,X,updateRate,pixelWidth,dt,parity,spatialFilterType);
    end
    % Last dt is infinite (uncorrelated stimuli)
    uncDt = -1;
    parity = 1;
    stimuli(:,:,end,1) = make_ternary_stim(T*repeats,X,updateRate,pixelWidth,uncDt,parity,spatialFilterType);
    stimuli(:,:,end,2) = stimuli(:,:,end,1);
    
    for ii = 1:length(modelTypes)
        modelType = modelTypes{ii};
        modelType(modelType == ' ') = '_';
        modelHandle = str2func(modelType);
        output = getFilterOutput(0,stimuli,repeats,@(x)deal(1,2),modelHandle);
        % output has dimensions [dt,parity,direction]
        figure();
        X = (1000/60)*dts';
        for parity = [1,2]
            subplot(1,2,parity);
            
            plot(X,squeeze(output(1:end-1,parity,:)));
            xlabel('interval (ms)');
            ylabel('response (a.u.)');
            if parity == 1
                title([modelTypes{ii} ' Positive Correlations']);
            else
                title([modelTypes{ii} ' Negative Correlations']);
            end
            hold on;
            h = plot([0 (1000/60)*dts(end)],repelem(output(end,1,1),2));
            set(h,'Color','black');
            legend({'PD','ND','unc'})
        end
    end
end

function out = HRC_Serbe(~,~,s1,s2)

    % change to luminance, not contrast
    s1 = (s1+1)/2;
    s2 = (s2+1)/2;
    
    % normalized frequency = augular frequency / (pi * sampling rate)
    % augular frequency = 2 * pi * cutoff frequency.
    % cutoff frequency = 1/ (2 * pi * time constant);
    % normalized frequency = 1/(pi * time constant * sampling rate);
    % 1 is Tm1, 2 is Tm2, etc
    [BL1,AL1] = butter(1,1/pi/230,'low');
    [BL2,AL2] = butter(1,1/pi/100,'low');
    [BL4,AL4] = butter(1,1/pi/200,'low');
    [BL9,AL9] = butter(1,1/pi/630,'low');

    [BH1,AH1] = butter(1,1/pi/1230,'high');
    [BH2,AH2] = butter(1,1/pi/360 ,'high');
    [BH4,AH4] = butter(1,1/pi/250 ,'high');
   %[BH9,AH9] = butter(1,1/pi/inf ,'high');

    tm1 = @(x) filter(BL1,AL1,subplus(filter(BH1,AH1,x)));
    tm2 = @(x) filter(BL2,AL2,subplus(filter(BH2,AH2,x)));
    tm4 = @(x) filter(BL4,AL4,subplus(filter(BH4,AH4,x)));
    tm9 = @(x) filter(BL9,AL9,subplus(               x ));


    out = ((tm1(s1).*tm2(s2))...
          +(tm1(s1).*tm4(s2))...
          +(tm9(s1).*tm1(s2))...
          +(tm4(s1).*tm2(s2))...
          +(tm9(s1).*tm2(s2))...
          +(tm9(s1).*tm4(s2)))/6;
end


function out = HRC_rect_Behnia_T4(~,~,s1,s2)

    q = load('data/BehniaData.mat');

    f1 = q.Mi1;
    f2 = q.Tm3;

    f1 = f1./sum(f1.^2); % normalized by power here...
    f2 = f2./sum(f2.^2);

    out = subplus(filter(f1,1,s1)).*subplus(filter(f2,1,s2));
end

function out = HRC_rect_Behnia_T5(~,~,s1,s2)

    q = load('data/BehniaData.mat');

    f1 = q.Tm1;
    f2 = q.Tm2;

    f1 = f1./sum(f1.^2);
    f2 = f2./sum(f2.^2);

    out = subplus(filter(f1,1,s1)).*subplus(filter(f2,1,s2));
end