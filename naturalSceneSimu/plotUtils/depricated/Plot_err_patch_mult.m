function g=plot_err_patch(xt,yt,et,col1,col2);

% like original, but each row of x is a separate line to plot...
% everything else replicated to rows, too...

for ii=1:size(xt,1)
    
    x=xt(ii,:);
    y=yt(ii,:);
    e=et(ii,:);

    ye1=y+e;
    ye2=y-e; ye2=ye2(end:-1:1);
    ye=[ye1,ye2];
    xe=[x,x(end:-1:1)];

    hold on;
    h=patch(xe,ye,col2(ii,:),'linestyle','none');    
end

for ii=1:size(xt,1)
    x=xt(ii,:);
    y=yt(ii,:);
    g(ii)=plot(x,y,'color',col1(ii,:),'linewidth',2);
end
