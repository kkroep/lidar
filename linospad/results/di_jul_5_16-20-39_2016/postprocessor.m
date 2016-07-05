% octave file for postprocessing info
clear all;
close;
clc;


hours =2;
minutes = 60;

% base measurement
a = csvread('h_1/m_1.txt');
base_line = sum(a);
base_line = 0;
<<<<<<< HEAD

=======
>>>>>>> 06362d2c8d45551843c623de6ab4e59e417f5f2e

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
print -deps test.eps;