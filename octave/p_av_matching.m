% linoSPAD Laser power due to scanning methods

name = sprintf('p_av_matching');

A=[];
A{1,1} = sprintf('\\textbf{matching average power}');
A{1,2} = sprintf('');

A{2,1} = sprintf('$P_B$');
A{2,2} = number_converter(P_B, 'W');

A{3,1} = sprintf('HDM altitude');
A{3,2} = number_converter_normal(max_altitude(2), 'm');

A{4,1} = sprintf('current altitude');
A{4,2} = number_converter_normal(max_altitude(1)/1000, 'km');

A{5,1} = sprintf('$P_{av}$');
A{5,2} = number_converter(lim_P_av, 'W');


caption = sprintf('required average power to get SNR=0');
latextable(A, name, tab_path, caption);
