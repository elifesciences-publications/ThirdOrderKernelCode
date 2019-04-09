close all
clear all

%% Test Pickpol 3o

[ locs,margin,seqInd ] = pickPol( [ 0 1 1 ],1,20,5,1 );

visualize2 = zeros(margin,margin);
for q = 1:seqInd(2)
    x1 = locs{2}.tau1(q) + 1;
    x2 = locs{2}.tau2(q) + 1; 
    visualize2(x1,x2) = visualize2(x1,x2) + 1;
end
figure; imagesc(visualize2);

visualize3 = zeros(margin,margin,margin);
for q = 1:seqInd(3)
    x1 = locs{3}.tau1(q) + 1;
    x2 = locs{3}.tau2(q) + 1;
    y  = locs{3}.tau3(q) + 1;   
    visualize3(x2,x1,y) = visualize3(x2,x1,y) + 1;
    if x1 ~= x2
        visualize3(x1,x2,y) = visualize3(x1,x2,y) + 1;
    end
end

threeDvisualize_slices(margin-1,margin-1,visualize3)