function [dx_bank, dt_bank, K2_DXDT_XT, K2_DXDT] = Simu_Utils_K2_Ori2DxDt(K2)

[n_x, ~, n_t, ~] = size(K2);

n_dx = n_x * 2 - 1;
n_dt = n_t * 2 - 1;

dx_bank = (-(n_x - 1):1:(n_x - 1))';
dt_bank = (-(n_t - 1):1:(n_t - 1))';

K2_DXDT_XT = zeros(n_dx, n_dt, n_x, n_t);
K2_DXDT = zeros(n_dx, n_dt);

for dx = 1:1:n_dx
    for dt = 1:1:n_dt
        for x1 = 1:1:n_x
            for t1 = 1:1:n_t
                %% xx + dx_bank would be negative....
                x2 = x1 + dx_bank(dx);
                t2 = t1 + dt_bank(dt);
                if (x2>0 && x2 <= n_x && t2 >0 && t2 <= n_t)
                    K2_DXDT_XT(dx, dt, x1, t1) = K2(x1, x2, t1, t2);
                end
            end
        end
        K2_DXDT(dx, dt) = sum(sum(squeeze(K2_DXDT_XT(dx, dt, :, :)), 1), 2);
        
    end
end
end