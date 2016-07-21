% octave file for postprocessing info
clear all;
close;
clc;


hours =5;
minutes = 60;
range = [1:32];

for k=range

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
%
%for k=1:no_SPADs
%	staven(k) = sum(b(k,:));
%end
%
%bar(staven);
%print -deps bars.eps;

%close;

max_lines = 3;


no_lines = max_lines;
hold on;
y_max = -realmax;
y_min = 0;

for k=range
	plot(1:length(b(k,:)),b(k,:), 'k');
  if(max(b(k,:))>y_max)
    y_max = max(b(k,:));
  end
	fprintf('%d, ', k);
end

fprintf('\n\n');

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
print -deps -color 'spad_1-32.eps';



