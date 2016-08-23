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
	staven(k) = sum(b(k,:));
end

bar(staven);
print -deps bars.eps;

close;

max_lines = 3;


no_lines = max_lines;
hold on;
y_max = -realmax;
y_min = 0;

for k=1:no_SPADs
	if(staven(k)<5e8 && no_lines>0)
		plot(1:length(b(k,:)),b(k,:), 'k');
    if(max(b(k,:))>y_max)
      y_max = max(b(k,:));
    end
		fprintf('%d, ', k);
		no_lines = no_lines-1;
	end
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
%print -deps spad_low.eps;
print('-deps', '-color', 'spad_low.eps');
close;

no_lines = max_lines;
hold on;
for k=1:no_SPADs
	if(staven(k)<15e8 && staven(k)>5e8 && no_lines>0)
		plot(1:length(b(k,:)),b(k,:), 'k');
		fprintf('%d, ', k);
    if(max(b(k,:))>y_max)
      y_max = max(b(k,:));
    end
		no_lines = no_lines-1;
	end
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
%print -deps spad_mid.eps;
print('-deps', '-color', 'spad_mid.eps');




close;

no_lines = max_lines;
hold on;
for k=1:no_SPADs
	if(staven(k)>15e8 && no_lines>0)
		plot(1:length(b(k,:)),b(k,:), 'k');
    if(max(b(k,:))>y_max)
      y_max = max(b(k,:));
    end
		fprintf('%d, ', k);
		no_lines = no_lines-1;
	end
end
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

fprintf('\n\n');
hold off;
%print -deps spad_high.eps;
print('-deps', '-color', 'spad_high.eps');

