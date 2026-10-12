function values = integrate(coordinate, profiles, partitions, varargin)
%INTEGRATE Integrate one or more profiles over each partition.
%   Profiles may be a numeric array or a struct of numeric arrays. The
%   spatial dimension may be selected for arrays with extra dimensions.

parser = inputParser;
parser.addParameter('Interpolation', 'linear', @(v) ischar(v) || isstring(v));
parser.addParameter('SpatialDimension', 1, @(v) isnumeric(v) && isscalar(v) ...
    && isfinite(v) && v >= 1 && v == floor(v));
parser.parse(varargin{:});
options = parser.Results;

if isstruct(profiles)
    names = fieldnames(profiles);
    values = struct();
    for i = 1:numel(names)
        name = names{i};
        values.(name) = integrateNumeric(coordinate, profiles.(name), ...
            partitions, options);
    end
else
    values = integrateNumeric(coordinate, profiles, partitions, options);
end
end

function values = integrateNumeric(coordinate, profile, partitions, options)
[matrix, trailingSize, wasVector] = profileMatrix( ...
    coordinate, profile, options.SpatialDimension);

nPartitions = partitions.count;
integrals = zeros(nPartitions, size(matrix, 2), 'like', matrix);
for p = 1:nPartitions
    [xp, values] = partitionSamples( ...
        coordinate, matrix, partitions, p, options.Interpolation);
    integrals(p,:) = trapz(xp, values, 1);
end

values = restorePartitionShape( ...
    integrals, trailingSize, wasVector);
end
