function p = TestAngleDifference(planeVector,n)
    % runs through all the resultants and determins pairwise whether they
    % came from the same distribution
    % implements a watson williams test
    
    numSamples = length(planeVector);
    p = ones(numSamples);
    
    for aa = 1:numSamples-1
        for bb = aa+1:numSamples
            % choose the smallest n as the n for the test
            nA = n{aa};
            nB = n{bb};

            rA = nA*abs(mean(planeVector{aa}));
            rB = nB*abs(mean(planeVector{bb}));

            N = nA + nB;

            rw = (rA + rB)/N;

            % this function was taken from the circular statistics toolbox 
            % http://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics-
            checkAssumption(rw,N/2)
            
            % find the mean vector length
            meanResultantComb = abs(mean([planeVector{aa}; planeVector{bb}]));

            R = N*meanResultantComb;

            %% calculate the p value
            % the code to calculate the correction factor K is taken
            % from
            % http://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics-/content/circ_wwtest.m
            kk = circ_kappa(rw);
            K = 1+3/(8*kk);    % correction factor

            F = K*((N-2)*(rA + rB - R)/(N - rA - rB));

            p(aa,bb) = 1-fcdf(F,1,N-2);
            p(bb,aa) = p(aa,bb);
        end
    end
end

%% this code is borrowed from the circular statistics toolbox where they
% implement the same watson  an williams parametric test
% http://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox--directional-statistics-/content/circ_wwtest.m
function checkAssumption(rw,n)

  if n >= 11 && rw<.45
    warning('Test not applicable. Average resultant vector length < 0.45.') %#ok<WNTAG>
  elseif n<11 && n>=7 && rw<.5
    warning('Test not applicable. Average number of samples per population 6 < x < 11 and average resultant vector length < 0.5.') %#ok<WNTAG>
  elseif n>=5 && n<7 && rw<.55
    warning('Test not applicable. Average number of samples per population 4 < x < 7 and average resultant vector length < 0.55.') %#ok<WNTAG>
  elseif n < 5
    warning('Test not applicable. Average number of samples per population < 5.') %#ok<WNTAG>
  end

end