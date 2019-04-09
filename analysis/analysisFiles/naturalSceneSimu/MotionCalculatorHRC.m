function v = MotionCalculatorHRC(HRC,data,time)
f = HRC.f;
g = HRC.g;
tf = HRC.param.t;
tS = time.t;

s1 = data.s1;
V1 = interp1(tS,s1,tf,'linear');
V1 = reshape(V1,[length(V1),1]);
V1flip = flipud(V1);

s2 = data.s2;
V2 = interp1(tS,s2,tf,'linear');
V2 = reshape(V2,[length(V2),1]);
V2flip = flipud(V2);

left = dot(f,V1flip) * dot(g,V2flip);
right = dot(g,V1flip) * dot(f,V2flip);

v = left - right;
end