% arg1 is csv location
% arg2 is eps destination
clear all;
close;
clc;

colorspec = {[0.4 0 0.8]; [0.4 0.8 0]; [0.4 0.7 0.7]; ...
  [0 0.4 0.8]; [0.8 0.4 0]; [0.7 0.4 0.7]; ...
  [0.8 0 0.4]; [0 0.8 0.4]; [0.7 0.7 0.4]; ...
  [0 0 0.4]; [0 0.4 0]; [0.4 0 0]};

TDC = 1200;
ROIC = 110;
pitch = 1.5;


width_range=0:0.1:100;

%% normal no ROIC or TDC
for i=1:length(width_range)
	c_width = width_range(i);
	c_area(i) = c_width^2+4*pitch^2+4*c_width*pitch;
	c_active(i) = c_width^2/c_area(i);
	c_pitch(i) = sqrt(c_area(i));
end
plot(c_pitch, c_active, 'linewidth', 4, 'Color', colorspec{1});

hold on;

for i=1:length(width_range)
	c_width = width_range(i);
	c_area(i) = c_width^2+4*pitch^2+4*c_width*pitch+ROIC;
	c_active(i) = c_width^2/c_area(i);
	c_pitch(i) = sqrt(c_area(i));
end
plot(c_pitch, c_active, 'linewidth', 4, 'Color', colorspec{2});

for i=1:length(width_range)
	c_width = width_range(i);
	c_area(i) = c_width^2+4*pitch^2+4*c_width*pitch+ROIC+TDC;
	c_active(i) = c_width^2/c_area(i);
	c_pitch(i) = sqrt(c_area(i));
end
plot(c_pitch, c_active, 'linewidth', 4, 'Color', colorspec{3});

plot(1:max(ceil(c_pitch)), (1:max(ceil(c_pitch)))./...
	(1:max(ceil(c_pitch))).*0.55, 'linewidth', 4, 'Color', colorspec{4});
plot(1:max(ceil(c_pitch)), (1:max(ceil(c_pitch)))./...
	(1:max(ceil(c_pitch))).*0.65, 'linewidth', 4, 'Color', colorspec{5});


% threshold = [1 2 4 8 16 32 64 128 256 512 1024]
% x_max = 1000000;
% x = 1:1000;
% % for j=length(threshold):-1:1
% for j=1:length(threshold)
% 	for i=x
% 		y(i) = 1-sum(poisspdf(0:threshold(j), i));
% 	end
% 	semilogx(x,y, 'linewidth', 4, 'Color', colorspec{j})
% 	hold on;
% end

hold off;
xlabel('pitch [um]');
ylabel('active area')
legend('no ROIC, no TDC','ROIC, no TDC','ROIC and TDC','spherical microlens','rectangular microlens', 'location', 'northeastoutside');
title('effective area for different approaches on 0.18 um technology');
print('-deps', '-color', '../report/fig/effective_area.eps');










