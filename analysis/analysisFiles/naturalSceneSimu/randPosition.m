function x = randPosition(image)
a = image.param.hor.degree(1);
b = image.param.hor.degree(end);

x = a + (b-a)* rand;
end