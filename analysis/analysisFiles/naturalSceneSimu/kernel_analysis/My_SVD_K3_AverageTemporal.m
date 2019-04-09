function My_SVD_K3_AverageTemporal(K3)
maxTau = 64;
tMax = 48;
tau_sum = [-10:10];
tau_diff = [0:9]; 



[mesh_sum, mesh_diff] = ndgrid(tau_sum, tau_diff);

tau_23_mesh = zeros(size(mesh_sum));
tau_13_mesh = zeros(size(mesh_diff));
for ss = 1:1:length(tau_sum)
    for dd = 1:1:length(tau_diff)
        tau_23_mesh(ss, dd) = (mesh_sum(ss, dd) - mesh_diff(ss, dd))/2;
        tau_13_mesh(ss, dd) = (mesh_sum(ss, dd) + mesh_diff(ss, dd))/2;
    end
end

%% give it a try. why not?!
n_sum = length(tau_sum);
n_diff = length(tau_diff);
K3_Impulse = zeros(tMax, n_sum, n_diff);
for ii = 1:1:n_sum
    for jj = 1:1:n_diff
        if floor(tau_23_mesh(ii, jj)) ==  tau_23_mesh(ii, jj) && floor(tau_13_mesh(ii, jj)) ==  tau_13_mesh(ii, jj)
            dtxx = tau_23_mesh(ii, jj) - tau_13_mesh(ii, jj);
            dtxy = -tau_13_mesh(ii, jj);
            [wind, ind] = K3ToGlider_Untils_ConstructWindMask(dtxx, dtxy, tMax, maxTau, 'nan_flag', true);        
            K3_Impulse(1:sum(~isnan(ind)),ii, jj) = K3(wind(:) == 1); % most recent bars.  
        end
    end
end
%% delete zero terms... get non zero terms together..
K3_Impulse_Combine = zeros(tMax, n_sum, floor(n_diff/2) - 1);
for ii = 1:1:n_sum
    if mod(tau_sum(ii), 2) == 0
        ind = 3:2:n_diff;
    else
        ind = 2:2:n_diff - 1;
    end
    K3_Impulse_Combine(:, ii, :) = K3_Impulse(:,ii, ind);
end
%%
k3_reformat = squeeze(sum(K3_Impulse, 1));
k3_reformat_combine = squeeze(sum(K3_Impulse_Combine, 1));


MakeFigure;
subplot(2,2,1);
imagesc(tau_diff, tau_sum, k3_reformat');
colormap_gen;
colormap(mymap);
thisMaxVal = max(abs(k3_reformat(:)));
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
xlabel('\Delta\tau_{21} + \Delta\tau_{23}');
ylabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
axis equal; axis tight;
ConfAxis('fontSize',15);
box on

subplot(2,2,2);
imagesc(k3_reformat_combine);
colormap_gen;
colormap(mymap);
thisMaxVal = max(abs(k3_reformat_combine(:)));
set(gca,'Clim',[-thisMaxVal thisMaxVal]);
ylabel('\Delta\tau_{21} + \Delta\tau_{23}');
xlabel('\Delta\tau_{21} - \Delta\tau_{23}');
set(gca, 'clim')
axis equal; axis tight;
ConfAxis('fontSize',15);
box on


%% how concatenate them together? 
% MakeFigure; contain the 
T = K3_Impulse_Combine;
U = cpd(T,1);
MakeFigure;
for ii = 1:1:3
    subplot(3,1,ii)
plot(U{ii})
end
% do the replo
T = K3_Impulse_Combine(:, 22:1:end, :) - K3_Impulse_Combine(:, 20:-1:1, :);
MakeFigure;
for ii = 1:1:3
    subplot(3,1,ii)
    plot(U{ii})
end
