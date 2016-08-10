% linoSPAD Laser power due to scanning methods

name = sprintf('photons_per_SPAD');

A = [];
A{1,1} = sprintf('\\textbf{photons per SPAD}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$PPS_B$');
A{2,2} = number_converter_exp(PPSS_B, ' \text{photon}/s');

A{3,1} = sprintf('$PPS_N$');
A{3,2} = number_converter_exp(PPSS_N, ' \text{photon}/s');

A{4,1} = sprintf('$PPS_S$');
A{4,2} = number_converter_exp(PPSS_S, ' \text{photon}/s/W');

caption = sprintf('Amount of backgroun (B), dark count (N), and signal (S) photons that hit a single SPAD per second');
latextable(A, name, tab_path, caption);
