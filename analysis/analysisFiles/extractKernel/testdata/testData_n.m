close all
clear all

%% Create filters
whichOrder = [ 0 0 1 ];
maxLen = 10;
walk = 1;
N = 3; 
dur = 100000;
% for q = 1:5
%     filters{q} = exampleFilters(whichOrder,maxLen);
%     filters{q}{2} = filters{q}{2} * q;
%     filters{q}{3} = filters{q}{3} * (-1)^q * q; 
%     if q == 3
%         filters{q}{3} = permute(filters{q}{3},[3 1 2]);
%     end
% end
 filters = exampleFilters(whichOrder,maxLen);

%% Filter random inputs. Could add noise here if you wanted

resp = zeros(dur,5);

for n = 1:N
    stim(:,n) = randInput(1,1,dur)';
end

for q = 1:5
    noiseVar = 0;
    for n = 1:N
        if n < N
            x = stim(:,n);
            y = stim(:,n+1);
        elseif n == N
            x = stim(:,n);
            y = stim(:,1);
        end    
    %     resp = resp + flyResp(whichOrder,filters,maxLen,x,y,noiseVar,[1 0]) - ...
    %         flyResp(whichOrder,filters,maxLen,y,x,noiseVar,[1 0]) ;
        resp(:,q) = resp(:,q) + flyResp(whichOrder,filters,maxLen,x,y,noiseVar,[1 0]);
    end
end
% resp(:,3) = 0;
% resp = resp*1e4;

%% Save

rIndex = 14;

for n = 1:N    
    saveTestData.data.stim(:,rIndex+(n-1)) = stim(:,n);
end


saveTestData.data.stim(:,3) = 1;
saveTestData.data.resp(:,3:7) = resp / (60/(1000*1/4*pi/360));
saveTestData.data.resp(:,8:12) = 0*1e4*randn(dur,5);
if walk
%     keyboard
    saveTestData.data.resp(:,3:7) = 0*1e4*randn(dur,5);
    saveTestData.data.resp(:,8:12) = resp / (60/(1000*.03937));
end
saveTestData.data.resp(:,18) = 6;
saveTestData.data.params.var = 1;

clearvars -except saveTestData
save saveTestData

