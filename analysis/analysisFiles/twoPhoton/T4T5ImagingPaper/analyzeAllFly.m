function analyzeAllFly(roiMethod, stimulusType,barWidth)
[filepathAll,~,flyEyeAll] = getDataPath(stimulusType);
nfile = length(filepathAll);
if strcmp(stimulusType,'5B')
    %     badfile =[4,5,9,10,17,22,23,30,32,33,]; % for the file
    %     badfile = [6,11,19,20,25,26,30,32,33,34,35,36,39,42]; % for ICA? the
    %     file name is changed, your old number is not valid anymore. maybe you
    %     have to remember them by files...
    badfile = [5,6,11,12,16,17,18,19,20,22,24,25,26,29]; % fly 5 is a wired T6T5, fly 6 is really bad. ICA would not work. fly11 watershod could not give out a reasonable result.
    errorfile = [49,50,54,55,56,57]; % I could not remember the error file... % 57 is a good file, do not exclude that in the future;
    T4file = [1,2,3,4,26,30,32,33,34,35,36,38,39];
    %     nfile = 20; 50
    startFile = 1; % 53 is a good fly. and you have not do anything to that.
    endFile = 58; % tonight, run the ICA on fly 10 again. why do I get crap from it?
end
if strcmp(stimulusType,'5T')
    %     badfile = [2,6,8,9,11]; % 8 and 9 gives me error, why is that? % for edgeType Roi, there badfile 9 could not give out good kernels,so I drop it. Same for 10. reason is not clear.
    badfile = [7,12]; % acutally, 6 is the used one.
    %     usedfile = [1,3,4,5]
    errorfile = [2,10]; % the second one has not been selected. the 5 got an error... It is beter
    T4file = [];
    startFile = 1;
    endFile = nfile;
end
if strcmp(stimulusType,'10')
    startFile = 1;
    badfile = [1,4,10];
    T4file = [];
    errorfile = [];
    endFile = nfile;
end
for ff = startFile:1:endFile
    
    flyEye = flyEyeAll{ff};
    filepath = filepathAll{ff};
    if find(badfile == ff)
        disp([filepath ' is bad data set']);
    elseif find(errorfile == ff)
        disp(['fly : ',num2str(ff),' cannot open']);
    elseif find(T4file == ff)
        disp('this is a T4 fly');
    else
        
        Z = twoPhotonMaster('filename',filepath,...
            'ROImethod',roiMethod,'edgeTypes',{'Left Dark Edge','Left Light Edge','Right Dark Edge','Right Light Edge'},'roiStashName','ICA','squareCounts',0,'roiMinPixNum',5,'force_new_ROIs',false);
        S = GetSystemConfiguration;
        kernelFolder = S.kernelSavePath;
        dataStorePath = [kernelFolder,'\T4T5_Imaging_Paper\raw\',roiMethod,'\',stimulusType,'\'];
        cd(dataStorePath);
            
        Z = CullRoiTracesKernel(Z);
        Z = RoiSelectionPreliminary(Z,flyEye);
        
        %         path = FindFlickKernelPath_Main(Z.params.name,roiMethod);
        %         flickpath = path.flickpath;
        %         firstkernelpath = path.firstkernelpath;
        %         firstnoisepath = path.firstnoisepath;
        %         secondkernelpathNearest = path.secondkernelpathNearest;
        %         secondnoisepath = path.secondnoisepath;
        %         secondkernelpathNextNearest = path.secondkernelpathNextNearest;
        
        % you need a flag to remember which part of the data is usable....
        tic
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',1,'maxTau',60,'doKernel',1,'doNoiseKernel',1,'saveKernels',1,'saveFlick',1);
        flickpath = Z.flick.fullFlickPathName;
        firstkernelpath = Z.kernels.fullKernelPathName;
        firstnoisepath = Z.noiseKernels. fullKernelPathName;
        toc
        
        tic
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',1,'doNoiseKernel',1,'saveKernels',1,'saveFlick',0,'dx',1);
        secondkernelpathNearest = Z.kernels.fullKernelPathName;
        secondnoisepath = Z.noiseKernels. fullKernelPathName;
        toc
        
        tic
        Z = tp_kernelExtraction_Juyue_ReverseCorr(Z,'order',2,'maxTau',64,'doKernel',1,'doNoiseKernel',0,'saveKernels',1,'saveFlick',0,'dx',2);
        secondkernelpathNextNearest = Z.kernels.fullKernelPathName;
        toc
        %
        [cfRoi,roiTrace] = RoiClassification(Z,flyEye);
        roiData = RoiOrganizeOneFly(Z,flyEye,cfRoi,roiTrace,...
            filepath,flickpath,firstkernelpath,secondkernelpathNearest,secondkernelpathNextNearest,firstnoisepath,secondnoisepath,barWidth);
        
        S = GetSystemConfiguration;
        kernelPath = S.kernelSavePath;
        flickpath = KernelPathManage_DeleteAbsolutePath(flickpath,kernelPath);
        firstkernelpath = KernelPathManage_DeleteAbsolutePath(firstkernelpath,kernelPath);
        firstnoisepath = KernelPathManage_DeleteAbsolutePath(firstnoisepath,kernelPath);
        secondkernelpathNearest = KernelPathManage_DeleteAbsolutePath(secondkernelpathNearest,kernelPath);
        secondnoisepath = KernelPathManage_DeleteAbsolutePath(secondnoisepath,kernelPath);
        secondkernelpathNextNearest = KernelPathManage_DeleteAbsolutePath(secondkernelpathNextNearest,kernelPath);
        
        
        path.flickpath = flickpath;
        path.firstkernelpath= firstkernelpath;
        path.firstnoisepath = firstnoisepath;
        path.secondkernelpathNearest = secondkernelpathNearest;
        path.secondnoisepath = secondnoisepath;
        path.secondkernelpathNextNearest = secondkernelpathNextNearest;
        
        AutoLogKernelPath(Z.params.name,roiMethod,path);
        
        disp('organize all the data for this fly');
        disp(ff);
        size(roiData)
        save(['Data',stimulusType,roiMethod,'_',num2str(ff)],'roiData','-v7.3');
        
    end
    clear Z
end
end
