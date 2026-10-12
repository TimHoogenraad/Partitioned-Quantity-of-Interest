function tests = test_datasets
tests = functiontests(localfunctions);
end

function testLoadsKSDatasets(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
files = {'dirichlet_profiles.mat', 'periodic_profiles.mat'};
for i = 1:numel(files)
    dataset = pqoi.io.loadKSProfiles(fullfile(root, 'datasets', 'ks', files{i}));
    verifyEqual(testCase, numel(dataset.reference.coordinate), 2049);
    verifyEqual(testCase, ...
        arrayfun(@(v) numel(v.coordinate), dataset.approximations), ...
        [129;257;513]);
    verifyEqual(testCase, dataset.reference.profiles.totalEnergy, ...
        dataset.reference.profiles.meanEnergy + ...
        dataset.reference.profiles.fluctuatingEnergy, 'AbsTol', 2e-15);
end
end

function testLoadsChannelDatasets(testCase)
root = fileparts(fileparts(mfilename('fullpath')));
strategies = {'tke_adaptive', 'shear_adaptive'};
for i = 1:numel(strategies)
    folder = fullfile(root, 'datasets', 'minimal_channel', strategies{i});
    dns = pqoi.io.loadChannelProfile(fullfile(folder, 'reference_dns.txt'));
    les = pqoi.io.loadChannelProfile(fullfile(folder, 'les_iteration_07.txt'));
    verifyEqual(testCase, dns.kind, 'DNS');
    verifyEqual(testCase, les.kind, 'LES');
    verifyEqual(testCase, numel(dns.coordinate), 81);
    verifyEqual(testCase, numel(les.coordinate), 33);
    verifyTrue(testCase, isfield(les.profiles, 'turbulentKineticEnergy'));
    verifyTrue(testCase, isfield(les.profiles, 'totalShearStress'));
end
end
