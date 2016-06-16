% linoSPAD Laser power due to scanning methods

name = sprintf('background_power');

A = [];
A{1,1} = sprintf('\\textbf{Background power}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$I_\\lambda$');
A{2,2} = number_converter_exp(I_lambda, 'W/M^3');

A{3,1} = sprintf('$B_\\lambda$');
A{3,2} = number_converter(Bw, 'm');

A{4,1} = sprintf('Surface area');
A{4,2} = number_converter_2(surface_area(1), 'm^2');

A{5,1} = sprintf('$r_{sun}$');
A{5,2} = number_converter_exp(r_sun/1000, 'km');

A{6,1} = sprintf('$r_{europa}$');
A{6,2} = number_converter_exp(r_europa/1000, 'km');

A{7,1} = sprintf('$P_B$');
A{7,2} = number_converter(P_B, 'W');

caption = sprintf('Calculation of background power on target area on Europa');
latextable(A, name, tab_path, caption);
