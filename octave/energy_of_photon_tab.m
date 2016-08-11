% linoSPAD Laser power due to scanning methods

name = sprintf('energy_of_photon');

A=[];
A{1,1} = sprintf('\\textbf{energy of photon}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$h$');
A{2,2} = number_converter_exp(h, 'Js');

A{3,1} = sprintf('$c$');
A{3,2} = number_converter_exp(c, 'm/s');

A{4,1} = sprintf('$\\lambda$');
A{4,2} = number_converter(lambda, 'm');

A{5,1} = sprintf('$E_{photon}$');
A{5,2} = number_converter_exp(e_photon, 'J');


caption = sprintf('calculation of photon energy at the specified wavelength');
latextable(A, name, tab_path, caption);
