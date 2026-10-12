function [xp, values] = partitionSamples(coordinate, matrix, partitions, partitionIndex, method)
%PARTITIONSAMPLES Return exact edge values plus interior grid samples.

x = coordinate(:);
a = partitions.edgeCoordinates(partitionIndex);
b = partitions.edgeCoordinates(partitionIndex+1);
mask = x > a & x < b;
xp = [a; x(mask); b];

scale = max(1, max(abs(x)));
tolerance = 100 * eps(scale);
[distanceA, ia] = min(abs(x-a));
[distanceB, ib] = min(abs(x-b));
if distanceA <= tolerance && distanceB <= tolerance
    values = matrix(ia:ib,:);
else
    values = interp1(x, matrix, xp, char(method));
end
end
