close all
clear all

%% plot results from contrast cube runs

D_black = run_analysis('dataPath','C:\Users\labuser\Documents\Data\paths\2014\09_12\08_52_35\path10flies.mat',...
    'analysisFile','combineEpochRespandDoubles');
D_white = run_analysis('dataPath','C:\Users\labuser\Documents\Data\paths\2014\09_12\08_53_32\path10flies.mat',...
    'analysisFile','combineEpochRespandDoubles');

%% make a heatmap: cube value on x axis, duration on y

blackDots = D_black.analysis.CI3.turn;
blackDots_map = zeros(3,3);
blackDots_map(:,2) = blackDots(1);
blackDots_map(:,1) = blackDots([2 4 6]');
blackDots_map(:,3) = blackDots([3 5 7]');
figure; imagesc(blackDots_map); title('dark dots');
xlabel('adaptor value'); ylabel('duration');
colormap(gray); set(gca,'CLim',[10.8272 23.9405]);

whiteDots = D_white.analysis.CI3.turn;
whiteDots_map = zeros(3,3);
whiteDots_map(:,2) = whiteDots(1);
whiteDots_map(:,1) = whiteDots([2 4 6]');
whiteDots_map(:,3) = whiteDots([3 5 7]');
figure; imagesc(whiteDots_map); title('light dots');
xlabel('adaptor value'); ylabel('duration');
colormap(gray); set(gca,'CLim',[10.8272 23.9405]);
