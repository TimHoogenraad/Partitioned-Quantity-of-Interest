function statistics = partitionStatistics(coordinate, fields, partitions, varargin)
%PARTITIONSTATISTICS Compute spatial statistics within each partition.
%   Statistics are weighted by physical coordinate rather than by point
%   count, which is important for nonuniform grids.

parser = inputParser;
parser.addParameter('Interpolation', 'linear', @(v) ischar(v) || isstring(v));
parser.addParameter('SpatialDimension', 1, @(v) isnumeric(v) && isscalar(v) ...
    && isfinite(v) && v >= 1 && v == floor(v));
parser.addParameter('Weighting', 'spatial', @(v) ischar(v) || isstring(v));
parser.parse(varargin{:});
options = parser.Results;

if isstruct(fields)
    names = fieldnames(fields);
    statistics = struct();
    for i = 1:numel(names)
        name = names{i};
        statistics.(name) = statisticsNumeric( ...
            coordinate, fields.(name), partitions, options);
    end
else
    statistics = statisticsNumeric(coordinate, fields, partitions, options);
end
end

function output = statisticsNumeric(coordinate, field, partitions, options)
[matrix, trailingSize, wasVector] = profileMatrix( ...
    coordinate, field, options.SpatialDimension);

nPartitions = partitions.count;
nColumns = size(matrix, 2);
average = zeros(nPartitions, nColumns, 'like', matrix);
standardDeviation = average;
rmsValue = average;
minimum = average;
maximum = average;
integral = average;
lengths = diff(partitions.edgeCoordinates);

for p = 1:nPartitions
    [xp, values] = partitionSamples( ...
        coordinate, matrix, partitions, p, options.Interpolation);
    width = xp(end) - xp(1);
    integral(p,:) = trapz(xp, values, 1);
    switch lower(string(options.Weighting))
        case "spatial"
            average(p,:) = integral(p,:) / width;
            centered = values - average(p,:);
            standardDeviation(p,:) = sqrt(trapz(xp, centered.^2, 1) / width);
            rmsValue(p,:) = sqrt(trapz(xp, values.^2, 1) / width);
        case "sample"
            average(p,:) = mean(values, 1);
            standardDeviation(p,:) = std(values, 0, 1);
            rmsValue(p,:) = sqrt(mean(values.^2, 1));
        otherwise
            error('pqoi:UnknownWeighting', ...
                'Weighting must be spatial or sample.');
    end
    minimum(p,:) = min(values, [], 1);
    maximum(p,:) = max(values, [], 1);
end

output = struct();
output.mean = restorePartitionShape(average, trailingSize, wasVector);
output.std = restorePartitionShape(standardDeviation, trailingSize, wasVector);
output.rms = restorePartitionShape(rmsValue, trailingSize, wasVector);
output.min = restorePartitionShape(minimum, trailingSize, wasVector);
output.max = restorePartitionShape(maximum, trailingSize, wasVector);
output.integral = restorePartitionShape(integral, trailingSize, wasVector);
output.length = lengths(:);
end
