%% Partitioned energy for a KS-like field
clear;
addpath(fileparts(fileparts(mfilename('fullpath'))));

x = linspace(0, 64, 257).';
u = sin(2*pi*x/64) + 0.2*sin(8*pi*x/64);

data.u = u;
profiles.energy = pqoi.computeProfile(data, @pqoi.qoi.ks.instantaneousEnergy);

% Eight grid intervals per partition. Full partitions contain nine nodes.
partitions = pqoi.makeGridPartitions(x, 8);
partitionedEnergy = pqoi.integrate(x, profiles, partitions);
fieldStatistics = pqoi.partitionStatistics(x, struct('u', u), partitions);

disp(table(partitions.edgeCoordinates(1:end-1), ...
    partitions.edgeCoordinates(2:end), partitionedEnergy.energy, ...
    fieldStatistics.u.mean, fieldStatistics.u.std, ...
    'VariableNames', {'LeftEdge','RightEdge','Energy','MeanU','StdU'}));
