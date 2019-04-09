function MyCDFAll(allPixel)
ngroup = 4;
x = cell(4,1);
f = cell(4,1);
for i = 1:1:4
    [f{i},x{i}] = ecdf(allPixel{i}(:));
end
D.x = x;
D.f = f;
save('D');
end