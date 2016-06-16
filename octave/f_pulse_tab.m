% linoSPAD Laser power due to scanning methods

name = sprintf('f_pulse');

A{1,1} = sprintf('\\textbf{Pulse Frequncy}');
A{1,2} = sprintf('AM');
A{1,3} = sprintf('HDM');

A{2,1} = sprintf('Maximum altitude');
A{2,2} = sprintf('$%d\\,km$', max_altitude(1)/1e3);
A{2,3} = sprintf('$%d\\,km$', max_altitude(2)/1e3);

A{3,1} = sprintf('Roundtrip time');
A{3,2} = sprintf('$%.3d\\,\\mu s$', roundtrip_time(1)*1e6);
A{3,3} = sprintf('$%.3d\\,\\mu s$', roundtrip_time(2)*1e6);

A{4,1} = sprintf('Pulse frequency');
A{4,2} = sprintf('$%.3d\\,kHz$', f_pulse(1)/1e3);
A{4,3} = sprintf('$%.3d\\,kHz$', f_pulse(2)/1e3);


caption = sprintf('Pulse frequency for both modes of operation');
latextable(A, name, tab_path, caption);
