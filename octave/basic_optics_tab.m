% linoSPAD Laser power due to scanning methods

name = sprintf('basic_optics');

A=[];
A{1,1} = sprintf('\\textbf{Basic Optics}');
A{1,2} = sprintf('');

A{2,1} = sprintf('f-number');
A{2,2} = number_converter(f_number, '');

A{3,1} = sprintf('absorption');
A{3,2} = number_converter_exp(absorption*100, '\%');

A{4,1} = sprintf('opacity');
A{4,2} = number_converter(opacity*100, '\%');

caption = sprintf('Performance of basic optics solution');
latextable(A, name, tab_path, caption);
