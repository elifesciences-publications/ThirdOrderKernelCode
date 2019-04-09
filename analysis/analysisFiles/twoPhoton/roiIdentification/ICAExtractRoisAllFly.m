clear
clc

roiMethod = 'ICA_NNMF';
stimulusType = '5B';

barWidth = 5;
[filepathAll,~,flyEyeAll] = getDataPath(stimulusType);
nfile = length(filepathAll);
D = []; % D would be a cell array, whose length is changing all the time...
if strcmp(stimulusType,'5B')
    %     badfile =[4,5,9,10,17,22,23,30,32,33,34,35,36,39,42,45]; % for
    %     the file 43 is bad for ICA
    %     34? what is the error? for water shed. 34 is still bad.....
    badfile = [5,6,11,12,16,17,18,19,20,22,24,25,29]; % fly 5 is a wired T6T5, fly 6 is really bad. ICA would not work. fly11 watershod could not give out a reasonable result.
%     errorfile = [49,50];
    % file 45 and 42 survived?
    T4file = [1,2,3,4,26,30,32,33,34,35,36,38,39];
    % fly 5, why only light response? so strange.... One More Fly than before, what is changed? Do you want to keep 6?
    %     nfile = 20;
    % potential bad file = [6?,] 7 is good. so 8 might be bad....
    % anyway, you have to run everything again at some point. why not take
    % a look at the new threshold ? for the second one, you might have to
    % lower your threshold?
    startFile = 56;
end
if strcmp(stimulusType,'5T')
    badfile = [2,6,8,9,11]; % 8 and 9 gives me error, why is that? % for edgeType Roi, there badfile 9 could not give out good kernels,so I drop it. Same for 10. reason is not clear.
    startFile = 1;
end
if strcmp(stimulusType,'10')
   startFile = 1;
   badfile = [1,4,10];
   T4file = [];
   
end
for ff = startFile:1:nfile
    
    flyEye = flyEyeAll{ff};
    filepath = filepathAll{ff};
    if find(badfile == ff)
        disp([filepath ' is bad data set']);
%     elseif find(errorfile == ff)
%         disp(['fly : ',num2str(ff),' cannot open']);
    elseif find(T4file == ff)
        disp('this is a T4 fly');
    else
        Z = twoPhotonMaster('filename',filepath,...
            'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','nnmf','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        
        Z = CullRoiTracesKernel(Z);
%         Z = RoiSelectionPreliminary(Z,flyEye);
        
        FigPlot1(Z,flyEye,'roiSelectionFlag',false,'roiSelected',[],'fig1_b_Flag',true,'true,fig1_c_Flag',true,'fig1_trace_Flag',true, 'fig1_DSIESI_flag',true,'saveFigFlag',false);
        cd('C:\Users\Clark Lab\Documents\Holly_log\12_08_2015');
        
    end
end