function [nodePartner,reducedPairlist] = GraphPartition_Utils_SearchForPartner(pairlist,node)
    nodeInd = find(pairlist == node);
    [whichPair,~] = ind2sub(size(pairlist),nodeInd);
    
    nodePartner = pairlist(whichPair,:);
    nodePartner = unique(nodePartner(:));
    nodePartner(nodePartner == node) = []; nodePartner = nodePartner';
    
    reducedPairlist = pairlist;
    reducedPairlist(whichPair,:) = [];
end