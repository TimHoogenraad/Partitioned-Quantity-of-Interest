function partitions = makeGridPartitions(coordinate, intervalsPerPartition)
%MAKEGRIDPARTITIONS Partition a 1-D grid using a fixed number of intervals.
%   PARTITIONS = pqoi.makeGridPartitions(X, A) groups A consecutive grid
%   intervals per full partition. Adjacent partitions share one edge node.

x = validateCoordinate(coordinate);

validateattributes(intervalsPerPartition, {'numeric'}, ...
    {'scalar','real','finite','integer','positive'}, mfilename, ...
    'intervalsPerPartition');

nIntervals = numel(x) - 1;
edgeIndices = 1:intervalsPerPartition:numel(x);
if edgeIndices(end) ~= numel(x)
    edgeIndices(end+1) = numel(x);
end

nPartitions = numel(edgeIndices) - 1;
indexRanges = cell(nPartitions, 1);
for p = 1:nPartitions
    indexRanges{p} = edgeIndices(p):edgeIndices(p+1);
end

partitions = struct( ...
    'type', 'grid', ...
    'coordinate', x, ...
    'edgeCoordinates', x(edgeIndices), ...
    'edgeIndices', edgeIndices(:), ...
    'indexRanges', {indexRanges}, ...
    'intervalsPerPartition', intervalsPerPartition, ...
    'count', nPartitions, ...
    'isGridAligned', true(numel(edgeIndices), 1), ...
    'hasShortFinalPartition', mod(nIntervals, intervalsPerPartition) ~= 0);
end

function x = validateCoordinate(x)
validateattributes(x, {'numeric'}, {'vector','real','finite','nonempty'}, ...
    mfilename, 'coordinate');
x = x(:);
if numel(x) < 2 || any(diff(x) <= 0)
    error('pqoi:InvalidCoordinate', ...
        'The coordinate must contain at least two strictly increasing points.');
end
end
