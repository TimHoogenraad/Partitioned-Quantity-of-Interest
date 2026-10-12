function value = restorePartitionShape(matrix, trailingSize, wasVector)
%RESTOREPARTITIONSHAPE Restore nonspatial dimensions after integration.

if wasVector
    value = matrix(:,1);
else
    value = reshape(matrix, [size(matrix,1), trailingSize]);
end
end
