function x_edge = Bin_Edge_Histeq(x, nbins)
% x_positive = x(x > 0);
% % always even number.
% bins_half = nbins/2;
% 
% % do the positive side.
% a = sort(x_positive,'ascend');
% n_onebin = floor(length(x)/2 /bins_half);
% edge_positive = a((0:1:bins_half - 1) * n_onebin + 1);
% edge_negative = -edge_positive(end:-1:2);
% x_edge = [min(min(x), min(edge_negative));edge_negative; edge_positive;max(max(x), max(edge_positive))];
% 
% h = histogram(x,'BinMethod','fd','Visible', 'off');

h = histogram(x,'BinMethod','fd','Visible', 'off');
x_edge = h.BinEdges;

% % deal with positive sign and negative sign.
% positive_x = x(x >= 0);
% positive_x_edge = Bin_Edge_Histeq_Positive( positive_x, nbins);
% negative_x = x(x < 0);
% negative_x_edge = -Bin_Edge_Histeq_Positive(-negative_x, nbins);
% negative_x_edge = sort(negative_x_edge,'ascend');
% %  do you want to cutoff the larget/smallest value there? not here.
% x_edge = [negative_x_edge(1:end - 1);positive_x_edge];
% % also include the smallest and the largets into?
% end
% function positive_x_edge = Bin_Edge_Histeq_Positive(positive_x, nbins)
% [positive_x_histeq] = histeq(positive_x,floor(nbins/2));
% % what is the edge
% a = sort(unique(positive_x_histeq),'ascend');
% % find the edge...
% positive_x_edge = zeros(length(a),2);
% for ii = 1:1:length(a)
%     positive_x_edge(ii,1) = min(positive_x(positive_x_histeq == a(ii)));
%     positive_x_edge(ii,2) = max(positive_x(positive_x_histeq == a(ii)));
% end
% positive_x_edge = [positive_x_edge(:,1)];
% end