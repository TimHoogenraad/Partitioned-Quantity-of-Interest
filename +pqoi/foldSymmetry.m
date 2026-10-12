function folded = foldSymmetry(profile)
%FOLDSYMMETRY Symmetrize profiles and retain the first half of the domain.
%   Each numeric profile is automatically classified as symmetric or
%   antisymmetric from its mirrored mismatch. The retained coordinate is
%   normalized from zero at the first boundary to one at the midpoint.

if ~isstruct(profile) || ~isfield(profile, 'coordinate')
    error('pqoi:InvalidProfile', ...
        'profile must be a struct containing a coordinate field.');
end

x = profile.coordinate(:);
if mod(numel(x), 2) == 0
    error('pqoi:EvenSymmetryGrid', ...
        'Symmetry folding requires an odd number of coordinate points.');
end
if any(diff(x) <= 0)
    error('pqoi:InvalidCoordinate', ...
        'The coordinate must be strictly increasing.');
end

pointCount = numel(x);
midpoint = (pointCount+1)/2;
folded = profile;
folded.coordinate = (x(1:midpoint)-x(1)) ./ (x(midpoint)-x(1));

if isfield(profile, 'data') && isstruct(profile.data)
    folded.data = foldFields(profile.data, pointCount, midpoint);
end
if isfield(profile, 'profiles') && isstruct(profile.profiles)
    folded.profiles = foldFields(profile.profiles, pointCount, midpoint);
end
end

function output = foldFields(input, pointCount, midpoint)
output = input;
names = fieldnames(input);
for i = 1:numel(names)
    name = names{i};
    value = input.(name);
    if ~isnumeric(value) || ~isvector(value) || numel(value) ~= pointCount
        continue;
    end

    wasRow = isrow(value);
    value = value(:);
    left = value(1:midpoint-1);
    right = flip(value(midpoint+1:end));
    symmetricError = mean(abs(left-right));
    antisymmetricError = mean(abs(left+right));

    foldedValue = value;
    if symmetricError <= antisymmetricError
        foldedValue(1:midpoint-1) = 0.5 .* (left+right);
    else
        foldedValue(1:midpoint-1) = 0.5 .* (left-right);
    end
    foldedValue = foldedValue(1:midpoint);
    if wasRow
        foldedValue = foldedValue.';
    end
    output.(name) = foldedValue;
end
end
