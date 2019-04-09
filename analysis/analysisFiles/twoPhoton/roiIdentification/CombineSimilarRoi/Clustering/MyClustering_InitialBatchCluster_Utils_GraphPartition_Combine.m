function grouplist = MyClustering_InitialBatchCluster_Utils_GraphPartition_Combine(pairlist)

% first round, get potential good pairlist.
grouplist = [];
[groupKeep,reducedPairlist,~] = GraphPartition_Utils_InitialPartition(pairlist);
grouplist = mat2cell(groupKeep,ones(size(groupKeep,1),1),2);

while ~isempty(reducedPairlist)
    group = struct('head',1,'tail',1,'node',[]);
    group.node = reducedPairlist(1,1); % put this node into group.
    
    while group.head <= group.tail && ~isempty(reducedPairlist)
        nodeSearch = group.node(group.head);
        [nodePartner,reducedPairlist] = GraphPartition_Utils_SearchForPartner(reducedPairlist,nodeSearch);
        % you have to check whether nodePartner is unique in existing node.
        % why cannot you to unique? sequence will be wired...
        nodePartner(ismember(nodePartner,group.node)) = [];
        group.node = [group.node, nodePartner];
        group.tail = group.tail + length(nodePartner);
        group.head = group.head + 1;
    end
    grouplist = [grouplist;{group.node}];
end

end

