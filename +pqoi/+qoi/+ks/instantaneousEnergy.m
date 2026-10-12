function profile = instantaneousEnergy(data)
%INSTANTANEOUSENERGY Local KS energy density, 0.5*u^2.
profile = 0.5 .* data.u.^2;
end
