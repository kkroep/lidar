% linoSPAD Laser power due to scanning methods

name = sprintf('PPS');

A=[];
A{1,1} = sprintf('\\textbf{PPS for background photons}');
A{1,2} = sprintf('');

A{2,1} = sprintf('Photons at SPADs');
A{2,2} = number_converter_exp(photons_hittings_SPAD, '\text{photon}/s');

A{3,1} = sprintf('$PDP$');
A{3,2} = number_converter(PDP*100, '\%');

A{4,1} = sprintf('effective area');
A{4,2} = number_converter(effective_area*100, '\%');

A{5,1} = sprintf('$PPS_B$');
A{5,2} = number_converter_exp(PPS_B, '\text{photon}/s');

caption = sprintf('Amount of detected sunlight photons detected per second');
latextable(A, name, tab_path, caption);
