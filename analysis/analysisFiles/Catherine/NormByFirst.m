function [averagedTime] = NormByFirst(averagedTime)


rightFirst = averagedTime{1};
leftFirst = averagedTime{size(averagedTime,1)/2+1};
for j = 1:size(averagedTime, 1)/2
    averagedTime{j} = averagedTime{j}/rightFirst;
end

for k = (size(averagedTime,1)/2+1):size(averagedTime, 1)
    averagedTime{k} = averagedTime{k}/leftFirst;
end
end

