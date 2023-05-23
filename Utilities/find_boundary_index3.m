function [u v] = find_boundary_index3(A)
% FIND_BOUNDARY_INDEX3 takes in volumetric data A and finds the index u and
% v in the 3rd dimension A(:,:,u:v) for which the value of A at each slice
% is nonzero 

ind = zeros(size(A,3),1);
for i = 1:size(A,3);
    ind(i) = sum(A(:,:,i) > 0, 'all');
end
u = find(ind,1);
v = find(ind,1, 'last');
end