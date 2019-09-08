function v = MotionCalculatorMC(MC,data,time)
% result is not a value, but a array, contains the value of different term
% in the explicit multipoint correlator.

f = MC.f;
g = MC.g;
tf = MC.param.t;
tS = time.t;

s1 = data.s1;
V1 = interp1(tS,s1,tf,'linear');
V1 = reshape(V1,[length(V1),1]);
V1flip = flipud(V1);

s2 = data.s2;
V2 = interp1(tS,s2,tf,'linear');
V2 = reshape(V2,[length(V2),1]);
V2flip = flipud(V2);

%% four values.
fV1 = dot(f,V1flip);
gV1 = dot(g,V1flip);
fV2 = dot(f,V2flip);
gV2 = dot(g,V2flip);

%%
v = zeros(70,1);
% fV1,gV1,fV2,gV2
count  = 0;
for i = 0:1:4
    for j = 0:1:4-i
        for k = 0:1:4-i-j
            for l = 0:1:4 - i - j - k
                count = count +1;
                v(count) = fV1^i * gV1^j * fV2^k * gV2^l;                
            end
        end
    end
end
% the weight should be determined later using lasso.
end