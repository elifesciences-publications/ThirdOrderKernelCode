function [ input ] = randInput( var,distribution,samples )
% Draws two random input vectors from a specified distribution


switch distribution % in contrast
    case 1 % Gaussian
        input = randn(1,samples)*sqrt(var); 
    case 2 % Binary
        input = 2*sqrt(var)*(randi(2,1,samples)-1.5);
    case 3 % Flat
        input = 2*sqrt(3*var)*(rand(1,samples) - .5);
end

end

