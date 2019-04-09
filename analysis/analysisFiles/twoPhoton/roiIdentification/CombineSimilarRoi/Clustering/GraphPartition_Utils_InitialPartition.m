function [ groupKeep,groupChange,stopFlag] = GraphPartition_Utils_InitialPartition(group)
[numGroups,numElement]  = size(group);
% you want to know whether one vertics share one node.
groupVec = group(:);
[nodeSort,nodeInd] = sort(groupVec,'ascend');

nonUniqueNodeIndIndA = find(diff(nodeSort) == 0);
if isempty(nonUniqueNodeIndIndA)
    stopFlag = true;
    groupKeep = group;
    groupChange = [];
else
    stopFlag = false;
    nonUniqueNodeIndIndB = nonUniqueNodeIndIndA + 1;
    
    [groupAInd,~] = ind2sub([numGroups,numElement], nodeInd(nonUniqueNodeIndIndA));
    [groupBInd,~] = ind2sub([numGroups,numElement], nodeInd(nonUniqueNodeIndIndB));
    
    % get rid of repeated pairs.
    groupPairInd = [groupAInd,groupBInd];
    % sort it 
    groupPairInd =  sort(groupPairInd,2);
    groupPairInd = unique(array2table(groupPairInd ),'rows');
    groupPairInd = table2array(groupPairInd);
    
    
    groupKeep =  group;
    groupKeep(unique([groupAInd;groupBInd]),:) = [];
%     groupChange = [groupArrayA;groupArrayA];
   
    
    groupArrayA = group(groupPairInd(:,1),:);
    groupArrayB = group(groupPairInd(:,2),:);
  
    groupNewTemp = cat(2,groupArrayA, groupArrayB);
    numGroupsNew = size(groupNewTemp,1);
    groupChange = zeros(numGroupsNew, numElement * 2 - 1); % it is hard to decide how many elements it has.
    for nn = 1:1:numGroupsNew
        % first, get rid of all the nan value.
        groupChange(nn,:) = unique( groupNewTemp(nn,:));
    end
end
%
end