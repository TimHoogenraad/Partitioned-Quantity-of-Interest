function [matrix, trailingSize, wasVector] = profileMatrix(coordinate, profile, spatialDimension)
%PROFILEMATRIX Move the spatial dimension first and flatten other axes.

x = coordinate(:);
validateattributes(profile, {'numeric'}, {'real','finite','nonempty'});
if spatialDimension > ndims(profile) || size(profile, spatialDimension) ~= numel(x)
    error('pqoi:ProfileSizeMismatch', ...
        'The selected spatial dimension must match the coordinate length.');
end

wasVector = isvector(profile);
order = [spatialDimension, 1:spatialDimension-1, spatialDimension+1:ndims(profile)];
permuted = permute(profile, order);
sizePermuted = size(permuted);
trailingSize = sizePermuted(2:end);
matrix = reshape(permuted, numel(x), []);
end
