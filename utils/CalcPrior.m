numPoints = 10;

% save each individual response and mean response for low contrast (LC) and
% high contrast (HC) paradigmes
% save only hz 1:6 because that is in the linear regime
indLC = lam45wlc.analysis.indTraces(1:10,:,2);
meanLC = lam45wlc.analysis.pTraces(1:10,:,2);

indHC = lam45w.analysis.indTraces(1:10,:,2);
meanHC = lam45w.analysis.pTraces(1:10,:,2);

% calculate the number of times the the flies saw a given
% velocity as slower than the group mean. This creates a psychometric curve
% which should have an inflection point at the perceived velocity.

psychLC = zeros(numPoints);
psychHC = zeros(numPoints);

for ii = 1:numPoints
    totalLessLC = sum(indLC>meanHC(ii),2); % total number of flies that saw a given velocity as greater than  the mean HC velocity
    fractLessLC = totalLessLC/size(indLC,2); % fraction of flies that saw a given velocity as greater than the mean HC velocity
    
    totalLessHC = sum(indHC>meanHC(ii),2); % total number of flies that saw a given velocity as greater than  the mean HC velocity
    fractLessHC = totalLessHC/size(indHC,2); % fraction of flies that saw a given velocity as greater than the mean HC velocity
    
    psychLC(ii,:) = fractLessLC';
    psychHC(ii,:) = fractLessHC';
end

subplot(1,2,1);
plot(psychLC);
subplot(1,2,2);
plot(psychHC);