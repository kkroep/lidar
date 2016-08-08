% linoSPAD Laser power due to scanning methods

name = sprintf('photons_hitting_SPADs');

A=[];
A{1,1} = sprintf('\\textbf{photons hitting SPADs}');
A{1,2} = sprintf('');

A{2,1} = sprintf("$P'_B$");
A{2,2} = number_converter_exp(P_B2, 'W');

A{3,1} = sprintf('$E_{photon}$');
A{3,2} = number_converter_exp(e_photon, 'J');

A{4,1} = sprintf('photons at SPADs');
A{4,2} = number_converter_exp(photons_hittings_SPAD, '\text{photon}/s');


caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
