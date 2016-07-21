% octave file for postprocessing info
clear all;
close;
clc;


hours =7;
minutes = 60;

% base measurement
a = csvread('h_1/m_1.txt');




for i=1:hours
	folder_loc = 'h_';
	folder_loc = 	[folder_loc int2str(i)];
	% disp(folder_loc);

	for j=1:minutes
		file_loc = [folder_loc '/m_' int2str(j) '.txt'];
		% disp(file_loc);
		a = csvread(file_loc);
		b((i-1)*minutes+j) = sum(a);
	end
end



plot(1:length(b),b, 'k');

y_min = 0;
y_max = max(b);

hold on;
x = [15 116];
for i=x
  plot([i,i],[y_min,y_max],'Linewidth',2,'--', 'color','r');
end

x = 144;
for i=x
  plot([i,i],[y_min,y_max],'Linewidth',2,'--', 'color','b');
end

x = [152 251];
for i=x
  plot([i,i],[y_min,y_max],'Linewidth',2,'--', 'color','g');
end
hold off;

legend('combined DCR','60 MeV start','60 MeV stop','reposition device','10 MeV start','10 MeV stop')

print -deps test.eps;