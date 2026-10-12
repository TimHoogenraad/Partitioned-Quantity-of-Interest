function profile = turbulentKineticEnergy(data)
%TURBULENTKINETICENERGY Local turbulent kinetic energy profile.

meanV = optionalField(data, 'meanV', 0);
meanW = optionalField(data, 'meanW', 0);
profile = 0.5 .* ((data.meanU2-data.meanU.^2) + ...
    (data.meanV2-meanV.^2) + (data.meanW2-meanW.^2));
end

function value = optionalField(data, name, default)
if isfield(data, name)
    value = data.(name);
else
    value = default;
end
end
