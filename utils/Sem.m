function y = Sem(x,dim)
    y = std(x,[],dim)/sqrt(size(x,dim));
end