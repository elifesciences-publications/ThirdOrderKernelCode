function cm = histe(x, n)



xsi = sort(x(:));
cdfy = [1:length(xsi)]/length(xsi);
% now, assign values based on the 128 evenly space intervals here...
clevel = [0:n-1]/(n-1); % space evenly in xsi
xpos = clevel*(max(xsi)-min(xsi))+min(xsi);

cm = ones(n,3); % new colormap
for ii=1:n
    cm(ii,:) = cm(ii,:)*interp1(xsi,cdfy,xpos(ii));
end