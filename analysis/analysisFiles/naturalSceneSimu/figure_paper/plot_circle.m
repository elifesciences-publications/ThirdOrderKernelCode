function [x, y] = plot_circle(xc, yc, r)

theta = 0 : 0.01 : 2*pi;
x = r* cos(theta) + xc;
y = r * sin(theta) + yc;
end