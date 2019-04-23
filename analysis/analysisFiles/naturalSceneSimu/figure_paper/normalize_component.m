function [K2_norm, K3_norm] = normalize_component(K2_U, K2_V, K3_U, K3_V)
K2_U_norm = -K2_U(:,1)./norm(K2_U(:,1));
K2_V_norm = -K2_V(:,1)./norm(K2_V(:,1));
K2_norm = {K2_U_norm, K2_V_norm};

K3_U_norm = -K3_U(:,1)./norm(K3_U(:,1));
K3_V_norm = K3_V(:,1)./norm(K3_V(:,1));
K3_norm = {K3_U_norm, K3_V_norm};

end
