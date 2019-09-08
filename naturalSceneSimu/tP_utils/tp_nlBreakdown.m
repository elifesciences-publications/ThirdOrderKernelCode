function [ GScos, functMag, fracts ] = tp_nlBreakdown( nlData )
% What fraction of the variance accounted for by each term in the 3o
% nonlinearity

    maxOrder = 3;
    nRoi = size(nlData.polyCos,2);
    
    % Gram-Schmidt on coefficients
    M = max(abs(nlData.polyRange));
    for r = 1:nRoi
        D{r} = eye(4);
        D{r}(1,3) = -(1/3)*M.^3;
        D{r}(2,4) = -(1/5)*M.^5;
        GScos(:,r) = D^-1*nlData.polyCos(:,r);
    end   
    
    % Magnitude of the functions themselves
    functMag = [];
    for r = 0:maxOrder
        functMag = cat(1,functMag,sqrt(M.^(2*r+1)/(2*r+1)));
    end
    
    % fractions
    fracts = GScos.^2.*functMag.^2;
    wholes = sum(fracts,1);

    % Pie Charts
    for r = 1:nRoi
        figure;
        subplot(1,2,1);
        pie(fracts(:,r));
        subplot(1,2,2);
        thisAxis = [ -M(r):.01:M(r) ];
        
    end

end

