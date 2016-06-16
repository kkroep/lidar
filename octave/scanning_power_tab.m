% linoSPAD Laser power due to scanning methods

name = sprintf('scanning_power');

A = [];
A{1,1} = sprintf('\\textbf{Scanning Power}');
A{1,2} = sprintf('square');
A{1,3} = sprintf('square');
A{1,4} = sprintf('line');
A{1,5} = sprintf('line');

A{2,1} = sprintf('No. SPADs');
A{2,2} = number_converter_normal(no_spads(1), '');
A{2,3} = number_converter_normal(no_spads(2), '');
A{2,4} = number_converter_normal(no_spads(3), '');
A{2,5} = number_converter_normal(no_spads(4), '');

A{3,1} = sprintf('pulse/s');
A{3,2} = number_converter_normal(pulse_s(1), '');
A{3,3} = number_converter_normal(pulse_s(2), '');
A{3,4} = number_converter_normal(pulse_s(3), '');
A{3,5} = number_converter_normal(pulse_s(4), '');

A{4,1} = sprintf('Window');
A{4,2} = number_converter(window(1), 's');
A{4,3} = number_converter(window(2), 's');
A{4,4} = number_converter(window(3), 's');
A{4,5} = number_converter(window(4), 's');

A{5,1} = sprintf('exposure time');
A{5,2} = number_converter(exposure_time(1), 's');
A{5,3} = number_converter(exposure_time(2), 's');
A{5,4} = number_converter(exposure_time(3), 's');
A{5,5} = number_converter(exposure_time(4), 's');

A{6,1} = sprintf('Surface Area');
A{6,2} = number_converter_normal(surface_area(1), 'm^2');
A{6,3} = number_converter_normal(surface_area(2), 'm^2');
A{6,4} = number_converter_normal(surface_area(3), 'm^2');
A{6,5} = number_converter_normal(surface_area(4), 'm^2');

A{7,1} = sprintf('$PPS_B$');
A{7,2} = number_converter_exp(PPS_B2(1), '');
A{7,3} = number_converter_exp(PPS_B2(2), '');
A{7,4} = number_converter_exp(PPS_B2(3), '');
A{7,5} = number_converter_exp(PPS_B2(4), '');

A{8,1} = sprintf('$DCR$');
A{8,2} = number_converter_exp(DCR(1), '');
A{8,3} = number_converter_exp(DCR(2), '');
A{8,4} = number_converter_exp(DCR(3), '');
A{8,5} = number_converter_exp(DCR(4), '');

A{9,1} = sprintf('$PPS_{B+N}$');
A{9,2} = number_converter_exp(PPS_BN(1), '');
A{9,3} = number_converter_exp(PPS_BN(2), '');
A{9,4} = number_converter_exp(PPS_BN(3), '');
A{9,5} = number_converter_exp(PPS_BN(4), '');

A{10,1} = sprintf('$PPS_{B+N}/SPAD$');
A{10,2} = number_converter_exp(PPS_BN_SPAD(1), '');
A{10,3} = number_converter_exp(PPS_BN_SPAD(2), '');
A{10,4} = number_converter_exp(PPS_BN_SPAD(3), '');
A{10,5} = number_converter_exp(PPS_BN_SPAD(4), '');


caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
