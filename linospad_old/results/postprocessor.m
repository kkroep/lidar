% octave file for postprocessing info
clear all;
close;
clc;


hours =21;
minutes = 60;

% base measurement
a = csvread('h_1/m_1.txt');
base_line = sum(a);


for i=1:hours
	folder_loc = 'h_';
	folder_loc = 	[folder_loc int2str(i)];
	% disp(folder_loc);

	for j=1:minutes
		file_loc = [folder_loc '/m_' int2str(j) '.txt'];
		% disp(file_loc);
		a = csvread(file_loc);
		b((i-1)*minutes+j) = sum(a)-base_line;
	end
end


plot(1:length(b),b);