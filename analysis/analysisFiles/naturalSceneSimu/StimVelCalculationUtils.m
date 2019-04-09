
s1 = StimulusGenerationTrace(oneRow,pos1,vel,time,image);
s2 = StimulusGenerationTrace(oneRow,pos2,vel,time,image);
% initiate and get new stimulus is 0.02 ms.
% if you use GPU. how many time would you same?
%% store the data s1, s2, pos1, pos2, vel, imageID,posRow,
data.ImageID = imageID;
data.posRow = posRow;
data.pos1 = pos1;
data.pos2 = pos2;
data.s1 = s1;
data.s2 = s2;
data.vel = vel;
data.flipFlag = flipFlag;

%%
%% calculate the velocity and also store them...
% do not forgot the restore this term.
% vest.HRC = MotionCalculatorHRC(HRC,data,time);
[vest.K2.xy, vest.K2.sym] = MotionCalculatorK2(K2,data,time);
[vest.K3.xxy, vest.K3.yyx, vest.K3.sym] = MotionCalculatorK3(K3,data,time);
%% HRC + K2 + K3
% the estimated time is 0.045 seconds.
% vest.MC = MotionCalculatorMC(MC,data,time);
% % the HRC, converging K3, past skew K3, and autocorrelation are
% % all stored in the MC.
% %
% vest.ConvK3 = vest.MC(ConvK3.ind);
% vest.PSK3 = vest.MC(PSK3.ind);
% vest.AutoK2 = vest.MC(AutoK2.ind);
data.vest = vest;
%disp(foldername{vv});
