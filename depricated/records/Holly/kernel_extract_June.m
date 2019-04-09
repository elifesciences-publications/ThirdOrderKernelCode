close all
clear all

%% Logbook week of June 2

%% Jun 6

% 36 degrees, no ND filters, full current, bitDepth = 4
% borrowed flies from Liana

% ISSUE WITH ACTUAL WIDTH - bitMap is 14 "columns" but screen only shows 11

% 1. twoBarFlicker_binary_var1_60Hz
% 2. twoBarFlicker_binary_var1_60Hz

%% June 10

% 36 degrees, no ND filters, full current, bitDepth = 4
% borrowed flies from Aleks
% now with contrast scaled inputs so a new stimfunction and paramfile
% haven't yet resolved width issue

% 1. twoBarFlicker_binary_var1_60Hz
% 2. twoBarFlicker_binary_var1_60Hz

%% June 11

% 36 degrees, no ND filters, full current, bD = 4
% borrowed flies from Matt

% 1. twoBarFlicker_binary_var1_60Hz
% 2. twoBarFlicker_gauss_varrtpt5_60Hz
% % % ABOVE HAD WRONG VIEWLOCS DON'T USE DATA

% 2. twoBarFlicker_gauss_varrtpt25_60Hz
% 1. twoBarFlicker_gauss_varrtpt25_60Hz
% ONLY USE LAST TWO OF THESE - FIRST ONE IS FROM BAD VIEWLOCS

% asked Matt about contrast and width issues - had accidentally had 270 as
% width of pixels (for this stim only!) - fixed but will not change until
% tomorrow's runs. So all these kernel extract runs up THROUGH today will
% have the wrong pixel size.

% CHECK AGAIN THAT BITMAP FROM 0 to 1 though I'm pretty sure it's working
% correctly now.

%% June 12

% Width issue fixed - now has correct number of bars:
% ( 4.5 degrees * 2 + 10 degrees ) * 14.5 = approx 270
% fixed edge wrapping issue and checked on xtplot, bitMap, by inspection

% confirmed that bitMap goes from 0 to 1. 

% confirmed that updates are at 16 ms on xtplot and all 6 frames in 6 fpu
% are the same, so corresponds to 60 Hz (could take hs video to be extra
% sure)

% 1. twoBarFlicker_binary_var1_60Hz
% 2. twoBarFlicker_binary_var1_60Hz

% 0.6% of frames dropped - an issue? can think about optimizing

% 3. twoBarFlicker_binary_var1_60Hz
% 4. twoBarFlicker_binary_var1_60Hz

% 5. twoBarFlicker_binary_var1_60Hz
% 6. twoBarFlicker_binary_var1_60Hz

%% June 16, 2014

% Doing some more Gaussian runs so I can make a real comparison. Confirmed
% that variance  (.25) is as expected and that this results in 95% of
% entries within the visible contrast range; confirmed number of bars and
% duration is correct; confirmed bitMap generally goes from 0 to 1. 

% Confirm that value truncation happens the way you would expect***
% Is drop rate too high?

% 36 degrees, full current, no filters, bit depth = 4

% 1. twoBarFlicker_Gauss_varpt25_60Hz
% 2. twoBarFlicker_binary_var1_60Hz

% .3% dropped frames

% 3. twoBarFlicker_binary_var1_60Hz
% 4. twoBarFlicker_Gauss_varpt25_60Hz

%% June 20, 2014

% 180 Hz runs. 
% Tested that image updates 3x per 60 hz update by looking at bitmaps on
% screen and by looking at xt plot.

% CONFUSED BY CORRELATION MAP ON XT PLOT: JUST THAT TOO SMALL?
% TRUNCATION FOR GAUSSIAN
% DROP RATE

% 36 degrees, full current, no filters, bit depth = 4

% 1. twoBarFlicker_binary_var1_180Hz
% 2. twoBarFlicker_binary_var1_180Hz








