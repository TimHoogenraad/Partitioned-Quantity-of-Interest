function profile = totalEnergy(data)
%TOTALENERGY Time-averaged total energy density.
profile = 0.5 .* data.meanU2;
end
