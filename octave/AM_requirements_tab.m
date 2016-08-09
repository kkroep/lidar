% linoSPAD Laser power due to scanning methods

name = sprintf('AM_requirements');

A=[];
A{1,1} = sprintf('\\textbf{AM requirements}');
A{1,2} = sprintf('short');
A{1,3} = sprintf('long');

A{2,1} = sprintf("altitude");
A{2,2} = number_converter_normal(AM_altitude(1), 'm');
A{2,3} = number_converter_normal(AM_altitude(2)/1000, 'km');

A{3,1} = sprintf("resolution");
A{3,2} = number_converter_normal(AM_resolution(1)*100, 'cm');
A{3,3} = number_converter_normal(AM_resolution(2), 'm');

A{4,1} = sprintf("FWHM");
A{4,2} = number_converter(AM_FWHM(1), 's');
A{4,3} = number_converter(AM_FWHM(2), 's');

A{5,1} = sprintf("$\\sigma$");
A{5,2} = number_converter(AM_sigma(1), 's');
A{5,3} = number_converter(AM_sigma(2), 's');


caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
