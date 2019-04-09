function [ Z ] = organizeOLS( kernelPaths,which,visUnits,visNorm)

if nargin < 1
    kernelPaths = 0;
end

if nargin < 2
    which = [1 1 1];
end

if nargin < 3
    visUnits = 1;
end

if nargin < 4
    visNorm = 0;
end

%% 1. read in paths
if isnumeric(kernelPaths)
        HPathIn = fopen('dataPath.csv');
        C = textscan(HPathIn,'%s');
        kernel_folder = C{1}{3};        
        paths.folders = uipickfiles('FilterSpec',kernel_folder,'Prompt','Choose folders containing kernel vectors');
        kernelPaths = paths.folders;
end

kernelFiles = cell(0,1);
prefix = sprintf('%s_*','turn');
for ii = 1:size(kernelPaths,2)
        thisFold = dirrec(kernelPaths{ii},prefix)';
        kernelFiles = cat(1,kernelFiles,thisFold);
end
rr = size(kernelFiles,1);

%% Concatenate
for qq = 1:rr    
    evalc(['load ' kernelFiles{qq}]);
    if which(1)
        cated.k1_x(:,qq) = kernels.k1_x;
        cated.k1_y(:,qq) = kernels.k1_y;
    end
    if which(2)
        cated.k2_xy(:,qq) = kernels.k2_xy;
    end
    if which(3)
        cated.k3_xxy(:,qq) = kernels.k3_xxy;
        cated.k3_yyx(:,qq) = kernels.k3_yyx;
    end
end
maxTau = round(sqrt(size(cated.k2_xy,1)));

%% Reshape
shape.k2_xy = zeros(maxTau,maxTau,rr);
shape.k3_xxy = zeros(maxTau,maxTau,maxTau,rr);
shape.k3_yyx = zeros(maxTau,maxTau,maxTau,rr);
for qq = 1:rr
    if which(2)
        shape.k2_xy(:,:,qq)=reshape(cated.k2_xy(:,qq),[maxTau maxTau]);
    end
    if which(3)
        shape.k3_xxy(:,:,:,qq)=reshape(cated.k3_xxy(:,qq),[maxTau maxTau maxTau]);
        shape.k3_yyx(:,:,:,qq)=reshape(cated.k3_yyx(:,qq),[maxTau maxTau maxTau]);
    end
end

%% Symmetrize
for qq = 1:rr
    if which(2)
        sym.k2_xy(:,:,qq) = (shape.k2_xy(:,:,qq) - permute(shape.k2_xy(:,:,qq),[2 1 3]))/2;
    end
    if which(3)
        sym.k3_xxy(:,:,:,qq) = (shape.k3_xxy(:,:,:,qq)-shape.k3_yyx(:,:,:,qq))/2;
    end
end

%% Stats
if which(1)
    avg.k1_x = mean(cated.k1_x,2);
    sd.k1_x = std(cated.k1_x,[],2);
    avg.k1_y = mean(cated.k1_y,2);
    sd.k1_y = std(cated.k1_y,[],2);
end
if which(2)
    avg.k2_xy = mean(sym.k2_xy,3);
    sd.k2_xy = std(sym.k2_xy,[],3);
end
if which(3)
    avg.k3_xxy = mean(sym.k3_xxy,4);
    sd.k3_xxy = std(sym.k3_xxy,[],4);
end

%% Normalized   
if which(1)
    for mm = 1:maxTau
        if sd.k1_x(mm) ~= 0
            norm.k1_x(mm) = avg.k1_x(mm) / sd.k1_x(mm)  * sqrt(rr/2);
        else
            norm.k1_x(mm) = 0;
        end
        if sd.k1_y(mm) ~= 0
            norm.k1_y(mm) = avg.k1_y(mm) / sd.k1_y(mm) * sqrt(rr/2);
        else
            norm.k1_y(mm) = 0;
        end
    end
end
if which(2)
    for mm = 1:maxTau
        for nn = 1:maxTau
            if sd.k2_xy(mm,nn) ~= 0
                norm.k2_xy(mm,nn) = avg.k2_xy(mm,nn) / sd.k2_xy(mm,nn) * sqrt(rr/2);
            else
                norm.k2_xy(mm,nn) = 0;
            end
        end
    end
end
if which(3)
    for mm = 1:maxTau
        for nn = 1:maxTau
            for oo = 1:maxTau
                if sd.k3_xxy(mm,nn,oo) ~= 0
                    norm.k3_xxy(mm,nn,oo) = avg.k3_xxy(mm,nn,oo) / sd.k3_xxy(mm,nn,oo) * sqrt(rr/2);
                else
                    norm.k3_xxy(mm,nn,oo) = 0;
                end
            end
        end       
    end
end

%% Visualize means
if visUnits
    if which(1)
        figure; 
        subplot(2,1,1); plot(avg.k1_x*60,'b'); %hold all; plot(avg.k1_x+sd.k1_x/sqrt(rr),'r'); plot(avg.k1_x-sd.k1_x/sqrt(rr),'r'); title('X Linear');
        subplot(2,1,2); plot(avg.k1_y*60,'b'); %hold all; plot(avg.k1_y+sd.k1_y/sqrt(rr),'r'); plot(avg.k1_y-sd.k1_y/sqrt(rr),'r'); title('Y Linear');
    end
    if which(2)
        figure; 
        imagesc(avg.k2_xy*60^2);
    end
    if which(3)
        threeDvisualize_slices(maxTau,9,avg.k3_xxy*60^3);
    % threeDvisualize_corner(avg.k3_xxy);
    % threeDvisualize_gobs(avg.k3_xxy*60^3,.05*60^3);
    end
end

%% Visualize normalized
if visNorm
    figure; 
    subplot(2,1,1); plot(norm.k1_x,'b'); %hold all; plot(avg.k1_x+sd.k1_x/sqrt(rr),'r'); plot(avg.k1_x-sd.k1_x/sqrt(rr),'r'); title('X Linear');
    subplot(2,1,2); plot(norm.k1_y,'b'); %hold all; plot(avg.k1_y+sd.k1_y/sqrt(rr),'r'); plot(avg.k1_y-sd.k1_y/sqrt(rr),'r'); title('Y Linear');

    figure; 
    imagesc(norm.k2_xy);

    threeDvisualize_slices(maxTau,9,norm.k3_xxy);
end

%% Output

Z.cated = cated;
Z.sym = sym;
Z.avg = avg;
Z.sd = sd;
Z.norm = norm;

end

