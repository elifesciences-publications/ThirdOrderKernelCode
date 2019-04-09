function sqdisplacements = squareDisp(positions)


%% code to compute the square displacement of fly based on alignment data
%% alignment data is in Z.grab.alignmentData

sqdisplacements = zeros(length(positions)-1,1);

for i = 2:length(positions)
    xDisp = positions(i,1)-positions(1,1);
    yDisp = positions(i,2)-positions(1,2);
    sqdisplacements(i-1) = (xDisp)^2+(yDisp)^2;

end
    plot(sqdisplacements)
end

