function [Ratio]=Edge_ratio3(img)
 [m,n] = size(img);
 img =  rgb2gray(img);
 BW = edge(img,'log');
 ind = find(BW~=0);
 Len = length(ind);
 Ratio = Len/(m*n);
end