function [ resp ] = specialtwodfilt( filter,in1,in2 )
% Efficient 2D filtering when all you want is the main diagonal of the
% output and the input is separable.

maxLen = length(filter);
dur = length(in1);

resp = zeros(dur-maxLen+1,1);
for q = 1:dur-maxLen+1
    resp(q) = flipud(in1(q:q+maxLen-1))'*filter*flipud(in2(q:q+maxLen-1));
end

end

