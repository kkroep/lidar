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
%% 
hold on;
for k=1:no_SPADs
	staven(k) = sum(b(k,1));
end
oops = 1:length(staven);
oops = oops/max(oops)*100;
semilogy(oops,sort(staven), 'b');

for k=1:no_SPADs
	staven(k) = sum(b(k,75));
end
oops = 1:length(staven);
oops = oops/max(oops)*100;
semilogy(oops,sort(staven), 'g');

for k=1:no_SPADs
	staven(k) = sum(b(k,150));
end
oops = 1:length(staven);
oops = oops/max(oops)*100;
semilogy(oops,sort(staven), 'r');

for k=1:no_SPADs
	staven(k) = sum(b(k,225));
end
oops = 1:length(staven);
oops = oops/max(oops)*100;
semilogy(oops,sort(staven), 'k');

xlabel('SPADs (%)');
ylabel('sum of counts');
legend('0 min','75 min','150 min','225 min', 'Location', 'NorthWest');
hold off;

%close;





