% octave matrx to textable converter 
% By: Kees Kroep 
%
% Data is a cell array of strings.
% e.g. data = {"title" "v1" "v2" ; "h1" "1" "2" ;"h2" "3" "4"};
%
% name affects label, and file name
%
% path is the desired location of the tex file
%
% caption is the caption
%
% Example command:
% latextable({"title" "v1" "v2" ; "h1" "1" "2" ;"h2" "3" "4"} ,"testtable", "",  "testcaption")
%
% Enjoy!


function latextable (data, name, path, caption)

% 

align = sprintf ("|l|%s|", repmat (cstrcat ("l"), [1, columns(data)-1]));
  str = sprintf ("\\begin{table}[H]\n");
  str = strcat(str, sprintf("\\centering\n"));
  str = strcat(str, sprintf("\\caption{%s}\n", caption));
  str = strcat(str, sprintf("\\label{tab:%s}\n", name));
  str = strcat(str, sprintf("\\begin{tabular}{%s}\\hline\n", align));
  
  for ii = 1:rows(data)
    str = strcat (str, sprintf ("    %s", data {ii, 1}));
	for jj = 2:columns(data)
    	str = strcat (str, sprintf (" & %s", data {ii, jj}));
	endfor
    str = strcat (str, " \\\\\n");
    if (ii==1)
      str = strcat (str, "    \\hline \n");
    endif
  endfor
str = strcat (str, "    \\hline \n");
str = strcat (str, "\\end{tabular}\n");
str = strcat (str, "\\end{table}\n");


% disp(str);

filename = strcat(name, "_tab.tex");
filename = strcat(path, filename);
fid = fopen (filename, "w");
fputs (fid, str);
fclose(fid);

endfunction

