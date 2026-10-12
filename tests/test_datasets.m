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
folder = fullfile(root, 'datasets', 'minimal_channel', 'uniform');
dns = pqoi.io.loadChannelProfile(fullfile(folder, 'reference_dns.txt'));
verifyEqual(testCase, dns.kind, 'DNS');
verifyEqual(testCase, dns.format, 'full');
verifyEqual(testCase, numel(dns.coordinate), 81);
verifyTrue(testCase, isfield(dns.profiles, 'turbulentKineticEnergy'));

resolutions = [9 17 33 65 129];
for n = resolutions
    filename = sprintf('les_ny%03d.txt', n);
    les = pqoi.io.loadChannelProfile(fullfile(folder, filename));
    verifyEqual(testCase, les.kind, 'LES');
    verifyEqual(testCase, les.format, 'full');
    verifyEqual(testCase, numel(les.coordinate), n);
    verifyTrue(testCase, isfield(les.profiles, 'totalShearStress'));
    verifyTrue(testCase, isfield(les.profiles, 'production'));
    verifyTrue(testCase, isfield(les.profiles, 'turbulentKineticEnergy'));
end
end
