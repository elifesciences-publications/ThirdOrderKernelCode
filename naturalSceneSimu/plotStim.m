function plotStim(v,stimc, imageID,ind)
% go through all the indk2 == 1
nExt = length(ind);
counter = 1;

for ii = 1:1:nExt
    if counter == 1
    makeFigure;
    set(plotH,'Visible','off');
    end
    vk2 = v.k2(ind(ii));
    vk3 = v.k3(ind(ii));
    vreal = v.real(ind(ii));
    s1 = stimc.whole(ind(ii)).s1;
    s2 = stimc.whole(ind(ii)).s2;
    theImageID = imageID(ind(ii));
    
    
    subplot(2,3,counter);
    plot(s1,'r');
    hold on
    plot(s2,'g');
    legend('s1','s2');
    xlabel('time [(1/60) ms per unit]');
    ylabel('contrast');
    titleStr = sprintf('v:%d, imageID:%d\nk2:%.4f, k3:%.4f',vreal,theImageID,vk2,vk3);
    title(titleStr);
    
    counter = counter + 1;
    if counter == 7
        counter = 1;
    end
end
end