% linoSPAD Laser power due to scanning methods

name = sprintf('effective_noise_power');

A=[];
A{1,1} = sprintf('\\textbf{effective noise power}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$P_B$');
A{2,2} = number_converter(P_B, 'W');

A{3,1} = sprintf('$r$');
A{3,2} = number_converter(max_altitude(2), 'm');

A{4,1} = sprintf('$R_{europa}$');
A{4,2} = number_converter(reflectivity*100, '\%');

A{5,1} = sprintf('Diameter lens $(D_l)$');
A{5,2} = number_converter(diameter_lens, 'm');

A{6,1} = sprintf('opacity filter $(L_f)$');
A{6,2} = number_converter(opacity_filter*100, '\%');

A{7,1} = sprintf('opacity optics $(L_l)$');
A{7,2} = number_converter(opacity_optics*100, '\%');

A{8,1} = sprintf('$P_B2$');
A{8,2} = number_converter(P_B2, 'W');


caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
