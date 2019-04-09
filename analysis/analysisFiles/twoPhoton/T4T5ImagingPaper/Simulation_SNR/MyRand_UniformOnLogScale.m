function x = MyRand_UniformOnLogScale(nSample,a,b,varargin)
method = 'continuous';
for ii = 1:2:length(varargin)
    eval([varargin{ii} '= varargin{' num2str(ii+1) '};']);
end
switch method
    case 'continuous'
    y = rand(nSample,1); % % there are nSamples.
    x = exp(y * (log(b) - log(a)) + log(a));
    case 'discrete'
        % range from a to b. you would have 20 sampled points.
        % and you would 
    nDiscretePoints = 10; % do not need much.
    nSampleEachPoints = round(nSample/nDiscretePoints); % always choose 100,200,300...
    
    sampleStepLog = (log(b) - log(a))/(nDiscretePoints - 1);
    sampleStepLogVec = sampleStepLog: sampleStepLog:sampleStepLog * [nDiscretePoints - 1]; 
    sampleStep = exp(sampleStepLogVec);
    samplePoints = [a,sampleStep];
    
    x = bsxfun(@times,ones(nSampleEachPoints, nDiscretePoints),samplePoints);
    x = x(:);
end
end