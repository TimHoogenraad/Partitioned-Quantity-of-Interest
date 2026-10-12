function comparison = compare(reference, approximation, partitions, varargin)
%COMPARE Compare partitioned reference and approximation profiles.
%   Inputs are structs with fields coordinate and profiles. Profile fields
%   must have matching names, but the two coordinate grids may differ.

parser = inputParser;
parser.addParameter('Interpolation', 'linear', @(v) ischar(v) || isstring(v));
parser.addParameter('Scale', 100, @(v) isnumeric(v) && isscalar(v) && isfinite(v));
parser.addParameter('Normalization', 'reference-total', ...
    @(v) ischar(v) || isstring(v));
parser.parse(varargin{:});
options = parser.Results;

validateInput(reference, 'reference');
validateInput(approximation, 'approximation');

names = fieldnames(reference.profiles);
comparison = struct();
comparison.partitions = partitions;

for i = 1:numel(names)
    name = names{i};
    if ~isfield(approximation.profiles, name)
        error('pqoi:MissingProfile', ...
            'Approximation is missing profile "%s".', name);
    end

    referenceIntegral = pqoi.integrate(reference.coordinate, ...
        reference.profiles.(name), partitions, ...
        'Interpolation', options.Interpolation);
    approximationIntegral = pqoi.integrate(approximation.coordinate, ...
        approximation.profiles.(name), partitions, ...
        'Interpolation', options.Interpolation);

    referenceTotal = sum(referenceIntegral, 1);
    approximationTotal = sum(approximationIntegral, 1);
    switch lower(string(options.Normalization))
        case "reference-total"
            denominator = abs(referenceTotal);
        case "reference-partition"
            denominator = abs(referenceIntegral);
        case "none"
            denominator = 1;
        otherwise
            error('pqoi:UnknownNormalization', ...
                'Normalization must be reference-total, reference-partition, or none.');
    end
    denominator = max(denominator, eps(class(referenceIntegral)));

    item = struct();
    item.reference = referenceIntegral;
    item.approximation = approximationIntegral;
    item.error = options.Scale * abs(approximationIntegral-referenceIntegral) ./ denominator;
    item.referenceTotal = referenceTotal;
    item.approximationTotal = approximationTotal;
    item.globalError = options.Scale * abs(approximationTotal-referenceTotal) ./ ...
        max(abs(referenceTotal), eps(class(referenceIntegral)));
    comparison.profiles.(name) = item;
end
end

function validateInput(value, label)
if ~isstruct(value) || ~isfield(value, 'coordinate') || ...
        ~isfield(value, 'profiles') || ~isstruct(value.profiles)
    error('pqoi:InvalidComparisonInput', ...
        '%s must contain coordinate and profiles fields.', label);
end
end
