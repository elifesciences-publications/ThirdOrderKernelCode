stim1{1}=single(rand(1000,2)-0.5);
stim2{1}=single(rand(1000,2)-0.5);
resp{1} =[rand(2:2);stim1{1}(1:end-2,:)].*[rand(1:2);stim2{1}(1:end-1,:)];
a=twod_gpu(stim1,stim2,resp);
maximum = max(max(a{1}(:,:,1)));
[tau1,tau2] = find(a{1} == maximum);
