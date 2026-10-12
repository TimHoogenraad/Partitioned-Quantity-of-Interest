function profile = meanEnergy(data)
%MEANENERGY Energy density associated with the mean field.
profile = 0.5 .* data.meanU.^2;
end
