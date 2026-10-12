function partitions = makePhysicalPartitions(coordinate, edges, varargin)
%MAKEPHYSICALPARTITIONS Define partitions by physical edge coordinates.
%   Off-grid edges are retained and handled by interpolation during
%   integration or statistics calculations.

parser = inputParser;
parser.addParameter('Tolerance', [], @(v) isempty(v) || ...
    (isnumeric(v) && isscalar(v) && isfinite(v) && v >= 0));
parser.parse(varargin{:});

x = validateCoordinate(coordinate);
validateattributes(edges, {'numeric'}, {'vector','real','finite'}, ...
    mfilename, 'edges');
edges = edges(:);

if numel(edges) < 2 || any(diff(edges) <= 0)
    error('pqoi:InvalidEdges', ...
        'Partition edges must be a strictly increasing vector.');
end

scale = max(1, max(abs(x)));
tolerance = parser.Results.Tolerance;
if isempty(tolerance)
    tolerance = 100 * eps(scale);
end
if edges(1) < x(1)-tolerance || edges(end) > x(end)+tolerance
    error('pqoi:EdgesOutsideDomain', ...
        'All partition edges must lie inside the coordinate domain.');
end

edges(abs(edges - x(1)) <= tolerance) = x(1);
edges(abs(edges - x(end)) <= tolerance) = x(end);

edgeIndices = nan(size(edges));
isAligned = false(size(edges));
for i = 1:numel(edges)
    [distance, index] = min(abs(x - edges(i)));
    if distance <= tolerance
        edgeIndices(i) = index;
        isAligned(i) = true;
        edges(i) = x(index);
    end
end

partitions = struct( ...
    'type', 'physical', ...
    'coordinate', x, ...
    'edgeCoordinates', edges, ...
    'edgeIndices', edgeIndices, ...
    'indexRanges', {{}}, ...
    'intervalsPerPartition', [], ...
    'count', numel(edges)-1, ...
    'isGridAligned', isAligned, ...
    'hasShortFinalPartition', false);
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
