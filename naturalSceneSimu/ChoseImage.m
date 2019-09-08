function  nSpIBank = ChoseImage(nImage,nStim)
nSpI = floor(nStim/nImage);
nSpIBank = ones(1,nImage) * nSpI;

nStimLeft = mod(nStim,nImage);
if nStimLeft > 0
    x = randperm(nImage);
    x = x(1:nStimLeft);
    nSpIBank(x) = nSpIBank(x) + 1;
end

end