function Q = GenerateTexture(Q)

% this function calls a function to generate the texStr within Q
% the texture must therefore be drawable entirely with information in Q

% this uses a lookuptable stored in Q to find the function name to call

% NOTE: all generating functions should pass back Q.texStr AND the stimdata
% file, which contains updated stimulus information to be used in next
% loop, etc.; this syntax is supposed to show that nothing but those two
% structures can change

[Q.texStr,Q.stims.stimData] = Q.stims.stimlookup{Q.stims.numList == Q.stims.currParam.stimtype}(Q);
