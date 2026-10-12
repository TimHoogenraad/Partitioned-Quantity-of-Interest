function profile = production(data, varargin)
%PRODUCTION Turbulent production with optional SGS stress contribution.

parser = inputParser;
parser.addParameter('IncludeSGS', true, @(v) islogical(v) && isscalar(v));
parser.parse(varargin{:});

meanV = optionalField(data, 'meanV', 0);
stress = data.meanUV - data.meanU .* meanV;
if parser.Results.IncludeSGS
    stress = stress + optionalField(data, 'tauSgs', 0);
end
profile = -stress .* data.dUdy;
end

function value = optionalField(data, name, default)
if isfield(data, name)
    value = data.(name);
else
    value = default;
end
end
