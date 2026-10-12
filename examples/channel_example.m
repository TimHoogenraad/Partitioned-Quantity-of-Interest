%% Partitioned channel-flow QoIs on a nonuniform wall-normal grid
clear;
addpath(fileparts(fileparts(mfilename('fullpath'))));

y = linspace(0, 1, 129).'.^1.5;
flow.meanU = 18*(1-y.^2);
flow.meanV = zeros(size(y));
flow.meanW = zeros(size(y));
flow.meanU2 = flow.meanU.^2 + 2*y.*(1-y);
flow.meanV2 = 0.5*y.*(1-y);
flow.meanW2 = 0.7*y.*(1-y);
flow.meanUV = -0.2*y.*(1-y);
flow.dUdy = gradient(flow.meanU, y);
flow.nu = 1/180;
flow.tauSgs = 0.01*y.*(1-y);

profiles.tauTotal = pqoi.qoi.channel.totalShearStress(flow);
profiles.tke = pqoi.qoi.channel.turbulentKineticEnergy(flow);
profiles.production = pqoi.qoi.channel.production(flow);

% Sixteen consecutive grid intervals per partition.
partitions = pqoi.makeGridPartitions(y, 16);
partitionedQoI = pqoi.integrate(y, profiles, partitions);
disp(partitionedQoI);

% Physical edges are also supported. Values at off-grid edges are
% interpolated before integration.
physicalPartitions = pqoi.makePhysicalPartitions(y, linspace(0, 1, 5));
partitionedPhysical = pqoi.integrate(y, profiles, physicalPartitions, ...
    'Interpolation', 'pchip');
disp(partitionedPhysical);
