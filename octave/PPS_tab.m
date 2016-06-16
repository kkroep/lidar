% linoSPAD Laser power due to scanning methods

name = sprintf('PPS');

A=[];
A{1,1} = sprintf('\\textbf{PPS for background photons}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$P_B2$');
A{2,2} = number_converter(P_B2, 'W');

A{3,1} = sprintf('$E_{photon}$');
A{3,2} = number_converter_exp(e_photon, 'J');

A{4,1} = sprintf('$PDP$');
A{4,2} = number_converter(PDP*100, '\%');

A{5,1} = sprintf('$PPS_B$');
A{5,2} = number_converter_exp(PPS_B, '');

caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
