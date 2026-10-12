function profile = totalShearStress(data)
%TOTALSHEARSTRESS Viscous, Reynolds, and optional SGS shear stress.

tauSgs = optionalField(data, 'tauSgs', 0);
meanV = optionalField(data, 'meanV', 0);
reynoldsStress = data.meanUV - data.meanU .* meanV;
profile = data.nu .* data.dUdy - reynoldsStress + tauSgs;
end

function value = optionalField(data, name, default)
if isfield(data, name)
    value = data.(name);
else
    value = default;
end
end
