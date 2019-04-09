function Y = tp_masterKernels( varargin )
% Loads kernels that have been extracted, concatenates them, manipulations
% like plotting, clustering, etc.

    for ii = 1:2:length(varargin)-1
        eval(['Y.params.' varargin{ii} '= varargin{' num2str(ii+1) '};']);
    end
    
    %% Select the files to be used
    HPathIn = fopen('dataPath.csv');
    C = textscan(HPathIn,'%s');
    kernel_folder = C{1}{3};        
    pathsFiles = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose the files containing the kernels you would like to use.');
 
    %% Check that you have selected the same type of kernel    
    numFiles = length(pathsFiles);
    for q = 1:numFiles
        splitStr = strsplit(pathsFiles{q},'/');
        kernelType(q,:) = splitStr{end}(1:4);
    end
    assert(all(all(kernelType == repmat(kernelType(1,:),[numFiles 1]))));
      
    %% Concatenate kernels  
    allKernels = [];
    for q = 1:numFiles
        load(pathsFiles{q});
        allKernels = cat(3,allKernels,saveKernels.kernels);
    end
    
    %% Analyze, plot, etc.   
    Y.allKernels = allKernels;
    for q = 1:length(Y.params.whichAnalyses);
            eval(['Y = ' Y.params.whichAnalyses{q} '(Y);' ]);
    end
   
end

