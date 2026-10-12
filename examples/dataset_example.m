%% Work with the bundled profile datasets
clear;
root = fileparts(fileparts(mfilename('fullpath')));
addpath(root);

%% KS: compare a 129-point LES against DNS
ks = pqoi.io.loadKSProfiles(fullfile(root, 'datasets', 'ks', ...
    'dirichlet_profiles.mat'));
les = ks.approximations(1);
partitions = pqoi.makeGridPartitions(les.coordinate, 16);
comparison = pqoi.compare(ks.reference, les, partitions);
disp(comparison.profiles.totalEnergy.globalError);

%% Minimal channel: compare one uniform LES resolution against DNS
folder = fullfile(root, 'datasets', 'minimal_channel', 'uniform');
dns = pqoi.io.loadChannelProfile(fullfile(folder, 'reference_dns.txt'));
les = pqoi.io.loadChannelProfile(fullfile(folder, 'les_ny033.txt'));
partitions = pqoi.makeGridPartitions(les.coordinate, 4);
comparison = pqoi.compare(dns, les, partitions);
disp(comparison.profiles.turbulentKineticEnergy.globalError);
