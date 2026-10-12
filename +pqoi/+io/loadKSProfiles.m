function dataset = loadKSProfiles(filePath)
%LOADKSPROFILES Load a bundled KS time-averaged profile dataset.
%   DATASET.reference contains the DNS profile and DATASET.approximations
%   contains the available LES resolutions.

raw = load(filePath);
required = {'DNS_x','u_ave','E_ave_inst','E_ave_mean','E_ave_fluct', ...
    'LES_x','LES_u_ave','LES_E_ave_inst','LES_E_ave_mean', ...
    'LES_E_ave_fluct'};
for i = 1:numel(required)
    if ~isfield(raw, required{i})
        error('pqoi:InvalidKSDataset', ...
            'Dataset is missing required variable "%s".', required{i});
    end
end

dataset.reference = makeCase(raw.DNS_x, raw.u_ave, raw.E_ave_inst, ...
    raw.E_ave_mean, raw.E_ave_fluct, 'DNS');

nCases = numel(raw.LES_x);
dataset.approximations = repmat(dataset.reference, nCases, 1);
for i = 1:nCases
    pointCount = numel(raw.LES_x{i});
    label = sprintf('LES %d points', pointCount);
    dataset.approximations(i) = makeCase(raw.LES_x{i}, ...
        raw.LES_u_ave{i}, raw.LES_E_ave_inst{i}, ...
        raw.LES_E_ave_mean{i}, raw.LES_E_ave_fluct{i}, label);
end

dataset.source = char(filePath);
end

function item = makeCase(x, meanU, meanU2, meanEnergyTwice, ...
        fluctuatingEnergyTwice, label)
item = struct();
item.label = label;
item.coordinate = x(:);
item.data.meanU = meanU(:);
item.data.meanU2 = meanU2(:);
item.profiles.meanEnergy = 0.5 .* meanEnergyTwice(:);
item.profiles.fluctuatingEnergy = 0.5 .* fluctuatingEnergyTwice(:);
item.profiles.totalEnergy = 0.5 .* meanU2(:);
end
