% octave file for postprocessing info
clear all;
close;
clc;


hours =5;
minutes = 60;
no_SPADs = 10; 
selected_lines = [1 2 4 8 9 10 17 18 19 20]

for k=1:no_SPADs

	for i=1:hours
		folder_loc = 'h_';
		folder_loc = 	[folder_loc int2str(i)];
		% disp(folder_loc);

		for j=1:minutes
			file_loc = [folder_loc '/m_' int2str(j) '.txt'];
			% disp(file_loc);
			a = csvread(file_loc);
			b(k,(i-1)*minutes+j) = a(k);
		end
	end
end

for k=1:no_SPADs
	staven(k) = sum(b(k,:));
end

bar(staven);
print -deps bars.eps;

close;

max_lines = 3;


no_lines = max_lines;
hold on;
for k=1:no_SPADs
	if(staven(k)<5e8 && no_lines>0)
		plot(1:length(b(k,:)),b(k,:));
		fprintf('%d, ', k);
		no_lines = no_lines-1;
	end
end
fprintf('\n\n');
hold off;
print -deps spad_low.eps;

close;

no_lines = max_lines;
hold on;
for k=1:no_SPADs
	if(staven(k)<15e8 && staven(k)>5e8 && no_lines>0)
		plot(1:length(b(k,:)),b(k,:));
		fprintf('%d, ', k);
		no_lines = no_lines-1;
	end
end
fprintf('\n\n');
hold off;
print -deps spad_mid.eps;

close;

no_lines = max_lines;
hold on;
for k=1:no_SPADs
	if(staven(k)>15e8 && no_lines>0)
		plot(1:length(b(k,:)),b(k,:));
		fprintf('%d, ', k);
		no_lines = no_lines-1;
	end
end
fprintf('\n\n');
hold off;
print -deps spad_high.eps;


