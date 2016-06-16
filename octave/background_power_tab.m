% linoSPAD Laser power due to scanning methods

name = sprintf('background_power');

A = [];
A{1,1} = sprintf('\\textbf{Background power}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$I_\\lambda$');
A{2,2} = number_converter_exp(I_lambda, 'W/M^3');

A{3,1} = sprintf('$B_\\lambda$');
A{3,2} = number_converter(Bw, 'm');

A{4,1} = sprintf('$Surface area$');
A{4,2} = number_converter_2(surface_area(1), 'm^2');

A{5,1} = sprintf('$\\lambda$');
A{5,2} = number_converter(lambda, 'm');

A{6,1} = sprintf('$T$');
A{6,2} = number_converter(T, 'K');

A{6,1} = sprintf('$I_\\lambda$');
A{6,2} = number_converter_exp(I_lambda, 'W/m^3');

caption = sprintf('Calculation of background power on target area on Europa');
latextable(A, name, tab_path, caption);
