% linoSPAD Laser power due to scanning methods

name = sprintf('sun_irradiation');

A = [];
A{1,1} = sprintf('\\textbf{Sun irradiation}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$h$');
A{2,2} = number_converter_exp(h, 'Js');

A{3,1} = sprintf('$c$');
A{3,2} = number_converter_exp(c, 'm/s');

A{4,1} = sprintf('$k$');
A{4,2} = number_converter_exp(k, 'j/K');

A{5,1} = sprintf('$\\lambda$');
A{5,2} = number_converter(lambda, 'm');

A{6,1} = sprintf('$T$');
A{6,2} = number_converter(T, 'K');

A{7,1} = sprintf('$I_\\lambda$');
A{7,2} = number_converter_exp(I_lambda, 'W/m^3');

caption = sprintf('Calculation of sun irradiation');
latextable(A, name, tab_path, caption);
