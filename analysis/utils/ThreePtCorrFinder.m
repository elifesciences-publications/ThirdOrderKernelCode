function [Dx1, Dx2, Dt1, Dt2] = ThreePtCorrFinder(xTPlot, epoch)
    dxLimit = 5;
    dtLimit = 5;
    crossCorr = zeros(dtLimit+1,dtLimit+1,2*dxLimit+1,2*dxLimit+1);
    shift0 = xTPlot;
    i = 1 ;
    corThreshold = 0.09;
    correlationFound = 0;
    pol = 0;
    for dt1 = 0:dtLimit
        for dx1 = -dxLimit:dxLimit
            shift1 = circshift(xTPlot,[-dt1 dx1]);

            for dt2 = 0:dtLimit      
                for dx2 = -dxLimit:dxLimit%(dx1+1):dxLimit
                    shift2 = circshift(xTPlot,[-dt2 dx2]);           

                    % find the maximum shift
                    leftTrim = abs(min([dx1 dx2])*(min([dx1 dx2])<0));
                    rightTrim = max([dx1 dx2])*(max([dx1 dx2])>0);
                    bottomTrim = max([dt1 dt2]);

                    trimmedShift0 = shift0(1:end-bottomTrim, leftTrim+1:end-rightTrim);
                    trimmedShift1 = shift1(1:end-bottomTrim, leftTrim+1:end-rightTrim);
                    trimmedShift2 = shift2(1:end-bottomTrim, leftTrim+1:end-rightTrim);

                    crossCorr(dt1+1,dt2+1,dx1+dxLimit+1,dx2+dxLimit+1) = mean(mean(trimmedShift0.*trimmedShift1.*trimmedShift2));
                    if crossCorr(dt1+1,dt2+1,dx1+dxLimit+1,dx2+dxLimit+1) > corThreshold || crossCorr(dt1+1,dt2+1,dx1+dxLimit+1,dx2+dxLimit+1) < -corThreshold
                        % Translate from the output reference point to our
                        % input reference point. 
                        correlationFound = 1;
                        if dt1 == dt2
                            changeX = dx1*(dx1 < dx2) + dx2*(dx1 > dx2);
                            changeT = dt1*(dx1 < dx2) + dt2*(dx1 > dx2);
                            dsUntranslated(i,:) = [dt1 dt2 dx1 dx2];
                            ds(i,:) = [changeT-dt1*(dx1 > dx2) changeT-dt2*(dx1 < dx2) changeX-dx1*(dx1 > dx2) changeX-dx2*(dx1 < dx2)];                        
                            i = i +1;
                        else
                            changeX = dx1*(dt1 > dt2) + dx2*(dt1 < dt2);
                            changeT = dt1*(dt1 > dt2) + dt2*(dt1 < dt2);
                            dsUntranslated(i,:) = [dt1 dt2 dx1 dx2];
                            ds(i,:) = [changeT-dt1*(dt1 < dt2) changeT-dt2*(dt1 > dt2) changeX-dx1*(dt1 < dt2) changeX-dx2*(dt1 > dt2)];                       
                            i = i+1;
                        end
                        if crossCorr(dt1+1,dt2+1,dx1+dxLimit+1,dx2+dxLimit+1) > corThreshold
                            pol = 1;
                        else
                            pol = -1;
                        end
                           
                       
                    end
                end
            end
        end
    end
    if correlationFound
        dsFinal = unique(ds,'rows');
        listOfDxsFound = dsFinal(:,3:4);
        listOfDtsFound = dsFinal(:,1:2);
        firstDts = listOfDtsFound(1,:);
        firstDxs = listOfDxsFound(1,:);
        disp(['Output dxs were '  num2str(firstDxs) ' for Epoch ' num2str(epoch) ' with polarity = ' num2str(pol)])
        disp(['Output dts were '  num2str(firstDts) ' for Epoch ' num2str(epoch) ' with polarity = ' num2str(pol)])
        Dx1 = firstDxs(1);
        Dx2 = firstDxs(2);
        Dt1 = firstDts(1);
        Dt2 = firstDts(2);
    else
        disp(['No Correlations above '  num2str(corThreshold) ' found. Likely random noise in Epoch ' num2str(epoch)])
        Dx1 = NaN;
        Dx2 = NaN;
        Dt1 = NaN;
        Dt2 = NaN;
    end
end

