function  rawv = AllVComb(D)
%% given the D, summarize the result into a different condition.
% create a v, contains all the result...
ngroup = length(D);
ndata = 0;
for i = 1:1:ngroup
    ndata = D{i}.ndata + ndata;
end

%% create huge matrix to store the data.
raw.v.HRC= zeros(ndata,1);
raw.v.k2 = zeros(ndata,1);
raw.v.k3 = zeros(ndata,1);
raw.v.real = zeros(ndata,1);

startP = 1;
for i = 1:1:ngroup
    endP = D{i}.ndata;
    raw.v.HRC(startP:startP + endP - 1) = D{i}.v.HRC;
    raw.v.k2(startP:startP + endP - 1) = D{i}.v.k2;
    raw.v.k3(startP:startP + endP - 1) = D{i}.v.k3;
    raw.v.real(startP:startP + endP - 1) = D{i}.v.real;
    startP = startP + endP - 1;
end
rawv = raw.v;
end