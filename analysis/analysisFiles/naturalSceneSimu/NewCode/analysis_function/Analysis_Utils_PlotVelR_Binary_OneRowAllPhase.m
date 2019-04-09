function D = Analysis_Utils_PlotVelR_Binary_OneRowAllPhase(data)

n_vel = size(data.v2, 2);
n_scenes = size(data.v2,3);

%% second, plot the mean/std


v2_mean = zeros(n_vel, n_scenes);
v2_std = zeros(n_vel, n_scenes);
v_real_range = zeros(n_vel, n_scenes);
for vv = 1:1:n_vel
    for ss = 1:1:n_scenes
        v2_mean(vv, ss) = mean(data.v2(:,vv,ss));
        v2_std(vv,ss) = std(data.v2(:,vv,ss));
        v_real_range(vv,ss) = data.v_real(1, vv,ss);
    end
end
D.v2_mean = v2_mean;
D.v2_std = v2_std;
D.v_real_range = v_real_range;
D.v2 = data.v2;
D.v_real = data.v_real;
D.n_scenes = n_scenes;

if isfield(data, 'v3')
    %% third order kernel
    v3_mean = zeros(n_vel, n_scenes);
    v3_std = zeros(n_vel, n_scenes);
    for vv = 1:1:n_vel
        for ss = 1:1:n_scenes
            v3_mean(vv, ss) = mean(data.v3(:,vv,ss));
            v3_std(vv,ss) = std(data.v3(:,vv,ss));
        end
    end
    D.v3_mean = v2_mean;
    D.v3_std = v2_std;
    D.v3 = data.v3;
    
    %% add together
    v23_mean = zeros(n_vel, n_scenes);
    v23_std = zeros(n_vel, n_scenes);
    for vv = 1:1:n_vel
        for ss = 1:1:n_scenes
            v23_mean(vv, ss) = mean(data.v3(:,vv,ss)+data.v2(:,vv,ss));
            v23_std(vv,ss) = std(data.v3(:,vv,ss)+data.v2(:,vv,ss));
        end
    end
    D.v23_mean = v23_mean;
    D.v23_std = v23_std;
    D.v23 = data.v3 + data.v2;
end
end