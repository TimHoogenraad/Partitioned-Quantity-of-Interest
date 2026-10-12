function profile = fluctuatingEnergy(data)
%FLUCTUATINGENERGY Energy density of fluctuations about the mean.
profile = 0.5 .* (data.meanU2 - data.meanU.^2);
end
