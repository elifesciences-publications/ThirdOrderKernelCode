close all
clear all

%% Log for filter extraction housekeeping

%% June 29

% Just wrote specialfilt3d and the test script for it. Here's an
% interesting observation: there seems to be some sort of pattern to the
% values that this method is bad at extracting. Just look at the extracted
% filter - loss of power along special lines through the filter. It would
% be cool to understand why this is the case, though I don't have the
% smallest idea where to start with it...