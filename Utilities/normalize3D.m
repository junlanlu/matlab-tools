function N = normalize3D(A,varargin)
% NORMALIZE3D normalized volumetric data A by dividing all voxel values by
% the mean voxel value, excluding 0.
A(isnan(A))=0;
A(isiinfnf(A))=0;
if(nargin > 1)
    mask = varargin{1};
    N = A ./ (mean(A(mask>0), 'all'));
else
    N = A ./ (mean(A, 'all'));
end



end