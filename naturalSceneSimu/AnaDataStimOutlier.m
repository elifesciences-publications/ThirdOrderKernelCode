function res = AnaDataStimOutlier(param)

D = MyLoadIndVStim(param);
% sort D !
D = MySortD(D);
nv = length(D);

res = cell(nv,1);
% the data is stored in the 
modeExtreme = 'number';
number = 3;
% vExtAll: different real velocity, vk2/vk3, extreme according to vk2/vk3, number of extreme values in that case 
vExtAllV = zeros(2,nv,2,number * 2);

for vv = 1:1:nv
    v = D{vv}.v;
    stimc = D{vv}.stimc;
    imageID = D{vv}.imageID;
    
    %% first, use vk2 to find extreme values;
    modeExtreme = 'number';
    number = 3;
    p = 0.1;
    indk2 = FindExtVel(v.k2,modeExtreme,p,number);
    plotStim(v,stimc,imageID,indk2);
    % store the image
    imageName = ['FWHM_', num2str(round(param.image.lcf.FWHM)),'v_',num2str(abs(v.real(1)))...
                  'k2.jpg'];
              saveas(gcf,imageName)
    vExtAll(1,vv,1,:) = v.k2(indk2);
    vExtAll(1,vv,2,:) = v.k3(indk2);
    
    %% second, use vk3 to find extreme values.
    modeExtreme = 'number';
    indk3 = FindExtVel(v.k3,modeExtreme,p,number);
    plotStim(v,stimc,imageID,indk3);
    imageName = ['FWHM_', num2str(round(param.image.lcf.FWHM)),'v_',num2str(abs(v.real(1)))...
                  'k3.jpg'];
    saveas(gcf,imageName);
    vExtAll(2,vv,1,:) = v.k2(indk3);
    vExtAll(2,vv,2,:) = v.k3(indk3);
    % store the image;
    %%
    % first,list what is the associated image.
    % second , plot the stimulus associated with them
    
    % given the v, vk2 and vk3, find the stimulus which gives out those
    % extrem values. 
    % on the velocity basis first.
    % for each contrast map, and each velocity, find th extreme value for
    % that velocity. 
    % the extreme value finding is a little bit different here.
    % it could be find using numbers. for exameple, top percentage of the
    % data, or 
%     
%     res{vv}.v = v.real;
%     res{vv}.stimc = stimc;
%     res{vv}.imageID = imageID;
end
%% plot the vExtall, see their relation ship at different velocity.
makeFigure;
subplot(1,2,1)
vk2_ = vExtAll(1,:,1,:);
vk3_ = vExtAll(1,:,2,:);
vk2 = vk2_(:);
vk3 = vk3_(:);
scatter(vk2,vk3,'r','filled');
title('relationship between extreme predicted velocity, sort by k2');
xlabel('k2');
ylabel('k3');

subplot(1,2,2)
vk2_ = vExtAll(2,:,1,:);
vk3_ = vExtAll(2,:,2,:);
vk2 = vk2_(:);
vk3 = vk3_(:);
scatter(vk2,vk3,'r','filled');
title('relationship between extreme predicted velocity, sort by k3');
xlabel('k2');
ylabel('k3');
imageName = ['FWHM_', num2str(round(param.image.lcf.FWHM)),'k2k3scatter.jpg'];
saveas(gcf,imageName);
end