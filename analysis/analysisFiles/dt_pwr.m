function [ dtFT, pwrIFft ] = dt_pwr( dt, dtAxis, pwr, pwrAxis, varargin )
% Converts between dt sweep and its Fourier transform, and vice versa.
%   - Make sure dtAxis is in seconds and pwrAxis is in Hertz
%   - first point will be treated as zero for symmetrization
%   - Change interpolate type with varargin
%   - Script determines whether your dt input includes reverse phi by
%     checking the size of its smallest dimension. If it does, script is
%     careful to always treat them in parallel.

    symmetrizeDt = 1; 
    symmetrizePwr = 1;
    interpDt = 'linear';
    interpPwr = 'linear';
    fitDt = 'exp2';
    fitPwr = '2olp';
    seeFit = 1; 
    scaleFactor = 2/sin(2*pi*5/30);
    
    for ii = 1:2:length(varargin)
        eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% scaling factor - see writeup
    
    
    %% Make sure inputs are row vectors
    % This will break if you put in more vectors than each vector has
    % samples for either dt or pwr
    numEntriesDt = min(size(dt));
    dtLen = length(dt);
    dt = reshape(dt, [ numEntriesDt dtLen ]);
    dtAxis = reshape(dtAxis, [ 1 dtLen ]);
    numEntriesPwr = min(size(pwr));
    pwrLen = length(pwr);
    pwr = reshape(pwr, [ numEntriesPwr pwrLen ]);
    pwrAxis = reshape(pwrAxis, [ 1 pwrLen ]);
 
    %% Interpolate
    
    % Interpolate DT plot
    dtSamp = min(abs(diff(dtAxis))); % Pick as the interpolation sampling 
                                    % frequency the smallest
                                    % displacement in the original
                                    % coordinates dtAxis
    dtMin = min(dtAxis);
    dtMax = max(dtAxis);
    dtInterpAxis = [dtMin:dtSamp:dtMax];
    dtInterp = [];
    for q = 1:numEntriesDt
        dtInterp = cat(1,dtInterp,interp1(dtAxis,dt(q,:)',dtInterpAxis,interpDt));
    end

    % Interpolate power plot
    pwrSamp = min(abs(diff(pwrAxis)));
    pwrMin = min(pwrAxis);
    pwrMax = max(pwrAxis);
    pwrInterpAxis = [pwrMin:pwrSamp:pwrMax];
    pwrInterp = [];
    for q = 1:numEntriesPwr
        pwrInterp = cat(1,pwrInterp,interp1(pwrAxis,pwr(q,:)',pwrInterpAxis,interpPwr));
    end
    
    
    %% Fit interpolated
    % Will overwrite "interp" variables   
    if ~isempty(fitDt)
%         figure;
        for q = 1:numEntriesDt
            fitDtOutput{q} = fit(dtInterpAxis',dtInterp(q,:)',fitDt);
            dtInterpFit(q,:) = feval(fitDtOutput{q},dtInterpAxis);
%             subplot(numEntriesDt,1,q);
%             plot(dtInterpAxis,dtInterp(q,:)); hold all; 
%             plot(dtInterpAxis,dtInterpFit(q,:)); hold off;
%             legend('Original','Fit');
%             title('DT Fit');
        end   
        dtInterp = dtInterpFit;
    end
    if ~isempty(fitPwr)
%         figure;
        if strcmp(fitPwr,'2olp')
            figure;
%             origAxis = pwrInterpAxis';
            origAxis = pwrAxis';
            newMax = 2/dtSamp;
            pwrInterpAxis = [0:pwrSamp:newMax];
            for q = 1:numEntriesPwr
                lpEqn = 'a*x*exp(-x*b)';
%                 data = pwrInterp(q,:)';
                data = pwr(q,:)';
                [ maxVal maxX ] = max(data);
                maxX = origAxis(maxX);
                aInit = maxVal/exp(1);
                bInit = 1/maxX;
                fitPwrOutput{q} = fit(origAxis,data,lpEqn,'StartPoint',[aInit bInit]);
                %% Extrapolate pwr sweep to maximum predicted 
                %  by ft of dt sweep (1/2/dtSamp) 
                hold all;
%                 plot(fitPwrOutput{q},origAxis,data);
                pwrInterpFit(q,:) = feval(fitPwrOutput{q},pwrInterpAxis);
                scatter(pwrAxis,pwr(q,:));
                plot(pwrInterpAxis,pwrInterpFit(q,:));
                hold off;
            end
        else
            for q = 1:numEntriesPwr
                fitPwrOutput{q} = fit(pwrInterpAxis',pwrInterp(q,:)',fitPwr);
                pwrInterpFit(q,:) = feval(fitPwrOutput{q},pwrInterpAxis);
    %             subplot(numEntriesPwr,1,q);
    %             plot(pwrInterpAxis,pwrInterp(q,:)); hold all; 
    %             plot(pwrInterpAxis,pwrInterpFit(q,:)); hold off; 
    %             legend('Original','Fit');
    %             title('Frequency Sweep Fit');
            end
        end
        pwrInterp = pwrInterpFit;
    end
%     keyboard
    
    %% Symmetrize
    dtContainsZero = (dtMin  == 0);
    if dtContainsZero
        dtSym = [ -fliplr(dtInterp(:,2:end)) dtInterp ];
        dtSymAxis = [ -fliplr(dtInterpAxis(:,2:end)) dtInterpAxis ];
    else
        dtSym = [ -fliplr(dtInterp) zeros(numEntriesDt,1) dtInterp ];
        dtSymAxis = [ -fliplr(dtInterpAxis) 0 dtInterpAxis ];
    end
%     figure; plot(dtSymAxis,dtSym);
%     title('Symmetrized DT');
       
    pwrContainsZero = (pwrMin  == 0);
    if pwrContainsZero
        pwrSym = [ -fliplr(pwrInterp(:,2:end)) pwrInterp ];
        pwrSymAxis = [ -fliplr(pwrInterpAxis(:,2:end)) pwrInterpAxis ];
    else
        pwrSym = [ -fliplr(pwrInterp) zeros(numEntriesPwr,1) pwrInterp ];
        pwrSymAxis = [ -fliplr(pwrInterpAxis) 0 pwrInterpAxis ];
    end
%     figure; plot(pwrSymAxis,pwrSym);
%     title('Symmetrized Pwr');
        
    %% Forward: take Fourier transform of DT sweep
    dtFt = fftshift(fft( dtSym,[],2 ));
    dtFtAxis = (1/dtSamp/length(dtSymAxis))...
        * ([ 1:length(dtSymAxis) ]-ceil(length(dtSymAxis)/2));
    figure; 
    plot(repmat(pwrSymAxis,[numEntriesPwr 1])',abs(pwrSym)','k:'); hold all;
    plot(repmat(pwrSymAxis,[numEntriesPwr 1])',abs(pwrSym)'*scaleFactor,'k');
    plot(repmat(dtFtAxis,[numEntriesDt 1 ])',abs(dtFt)','b'); 
    xlabel('Frequency (Hz)');
    ylabel('Response magnitude (deg/s)');
%     legend('data pwr','data pwr scaled','fft dt');
    title('Power Sweep versus FT of Dt sweep');
    
    %% Backward: take IFT of sine waves
    pwrIfft = fftshift(ifft( pwrSym,[],2 ));
    pwrIfftAxis = (1/pwrSamp/length(pwrSymAxis)) ...
        * ([ 1:length(pwrSymAxis) ]-ceil(length(pwrSymAxis)/2));
    figure; 
    plot(repmat(dtSymAxis,[numEntriesDt 1])',abs(dtSym)','b'); hold all;
    plot(repmat(pwrIfftAxis,[numEntriesPwr 1])',abs(pwrIfft)','k:'); 
    plot(repmat(pwrIfftAxis,[numEntriesPwr 1])',abs(pwrIfft)'*scaleFactor,'k');
    xlabel('Dt (s)');
    ylabel('Response magnitude (deg/s)');
%     legend('data dt','pwr ifft','pwr ifft scaled');
    title('DT sweep versus IFT of Power Sweep');
    
end

