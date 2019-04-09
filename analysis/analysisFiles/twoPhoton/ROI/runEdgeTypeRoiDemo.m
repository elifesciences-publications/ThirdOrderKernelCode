close all
clear all
clc

%% DEMO: USING edgeTypeRoi
% There is a variable in edgeTypeRoi called "demoMode" which defaults to
% false. We will set it to true, which will cause us to encounter several
% breakpoints in the script and plot figures showing the intermediates.
% Every time you encounter a breakpoint, look at the figures that come up
% and the printed text, then dbcont. 

filepath =  'I:\2pData\2p_microscope_data\2015_06_09\+;UASGC6f_+;T4T5_+ - 2\twoBarFlicker_binary_var1_60hz_-63.1down010\twoBarFlicker_binary_var1_60hz_-63.1down010.tif'; % an example data set with good t4/t5 separation
Z = twoPhotonMaster('filename',filepath,...
    'demoMode',true,... % turns on visualization of each step.
    'force_new_ROIs',true,... % we want to run ROI selection again, even though previously run
    'ROImethod','edgeTypeRoi',... % setting ROI selection method
    'saveROIdata',false,'stashROIdata',false,... % not saving the results of this demo, either in the Z structure or in the ROI stash
    'edgeTypes',{'Left Dark Edge','Left Light Edge',...
    'Right Dark Edge','Right Light Edge'}); 
        % the edgeTypes variable determines which control responses will be 
        % compared. It should be a 1 x 2n cell array, where n is the number
        % of pairs of edge Types. Elements n and n+1 are compared, eg.
        % above the comparisons are (Left Dark vs. Left Light) and (Right
        % Dark vs. Right Light).

%% Using tp_roiEval to determine edge- and direction-selectivity
% There is no demo mode for roiEval, but there are very detailed comments
% that should help you go through it. 

Z = tp_roiEval(Z,[]);
% Copied from the comments:
    % INPUTS
        % Z: the structure containing filtered traces for the ROIs you wish
        %   evauluate.
        % roiEval: a vector of the ROIs for which you would like to run
        %   this analysis. All output variables will only be evaluated for
        %   these ROIs, so indices within them will not correspond to
        %   indices of the original ROIs in ROImasks, filtered traces, etc.
    % Outputs
        % Z.eval structure: contains:
            %  - QUANTITIES EVALUATED FOR EACH ROI IN roiEval: 
            % direction_selectivity, bright_min_dark_left_over_sum, 
            % bright_min_dark_right_over_sum, bright_left_plus_right, 
            % dark_left_plus_right.
            % - Category_name and category_force: sorting ROIs based on which
            % of the four edge type stimuli they respond most strongly to.
            % - Parameters documenting how the analysis was run.

%% Scatter plot generation script
% There is no demo mode for edgeScatter, but there are very detailed comments
% that should help you go through it. This script assumes that roiEval has
% already been run. 
tp_edgeScatter(Z)
