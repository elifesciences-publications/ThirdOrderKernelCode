function AnaAll(D,p)
v = AllVComb(D);
[r,weight,sampleV] = AnaCorrAccordVreal(v,p);

%%
strInfo.title = 'at different magnitudes of real v :';
strInfo.xlabel = 'magnitude of V';
PlotXRW(r,weight,sampleV,strInfo);
%%

strInfo.xlabel = 'log magnitude of V';
SemilogXRW(r,weight,sampleV,strInfo);
end
