% linoSPAD Laser power due to scanning methods

name = sprintf('scanning_power');

A = [];
A{1,1} = sprintf('\\textbf{Scanning Power}');
A{1,2} = sprintf('square');
A{1,3} = sprintf('square');
A{1,4} = sprintf('line');
A{1,5} = sprintf('line');

A{2,1} = sprintf('No. SPADs');
A{2,2} = number_converter_exp(no_spads(1), '');
A{2,3} = number_converter_exp(no_spads(2), '');
A{2,4} = number_converter_exp(no_spads(3), '');
A{2,5} = number_converter_exp(no_spads(4), '');

A{3,1} = sprintf('pulse/s');
A{3,2} = number_converter_exp(pulse_s(1), '');
A{3,3} = number_converter_exp(pulse_s(2), '');
A{3,4} = number_converter_exp(pulse_s(3), '');
A{3,5} = number_converter_exp(pulse_s(4), '');

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
A{6,2} = number_converter_2(surface_area(1), 'm^2');
A{6,3} = number_converter_2(surface_area(2), 'm^2');
A{6,4} = number_converter_2(surface_area(3), 'm^2');
A{6,5} = number_converter_2(surface_area(4), 'm^2');


caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
