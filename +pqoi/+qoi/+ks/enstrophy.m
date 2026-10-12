function profile = enstrophy(data)
%ENSTROPHY Local KS enstrophy density, (du/dx)^2.
profile = data.dudx.^2;
end
