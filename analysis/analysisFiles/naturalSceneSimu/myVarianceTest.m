n = 10;
a = rand(1,n*n);
b = rand(1,n*n);
aa = reshape(a,[n,n]);
bb = reshape(b,[n,n]);
for i = 1:1:n
    filename = ['testingData',num2str(i)];
    c = aa(i,:);
    d = bb(i,:);
    save(filename,'c','d')
end

%%