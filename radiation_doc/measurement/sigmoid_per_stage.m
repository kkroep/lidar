% octave file for postprocessing info
clear all;
close;
clc;


hours =5;
minutes = 60;
no_SPADs = 512; 
selected_lines = [1 2 4 8 9 10 17 18 19 20]

for k=1:no_SPADs

	for i=1:hours
		folder_loc = 'h_';
		folder_loc = 	[folder_loc int2str(i)];
		% disp(folder_loc);

		for j=1:minutes
			file_loc = [folder_loc '/m_' int2str(j) '.txt'];
			% disp(file_loc);5
			a = csvread(file_loc);
			b(k,(i-1)*minutes+j) = a(k);
		end
	end
end

for k=1:no_SPADs
	staven(k) = sum(b(k,200:210));
end

%bar(staven);
%print -deps bars.eps;

b = 1:length(staven);
semilogx(sort(staven),b);

%close;
disp 'done'




