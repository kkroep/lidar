% arg1 is csv location
% arg2 is eps destination
clear all;
close;
clc;

colorspec = {[0.4 0 0.8]; [0.4 0.8 0]; [0.4 0.7 0.7]; ...
  [0 0.4 0.8]; [0.8 0.4 0]; [0.7 0.4 0.7]; ...
  [0.8 0 0.4]; [0 0.8 0.4]; [0.7 0.7 0.4]; ...
  [0 0 0.4]; [0 0.4 0]; [0.4 0 0]};


%% Poisson Jetser

sigma = 142e-12
a = 42.5e-12
b = 3.33e-6/sqrt(12)

%n = 1:200000000;
%s = (a^2+sqrt(a^4-4*a^2*sigma^2*n+4*b^2*sigma^2*n)-2*sigma^2*n)/(2*sigma^2);





PPS_B = 1.38e6;
PPS_S = 1.88e5; % photons per watt
pulse_length = 100e-12;

pulses = 1;

for i=1:300
	pulses = ceil(1.1^i);
	n = ceil(pulses*PPS_B*pulse_length);
	req_s = -(a^2-sqrt(a^4-4*a^2*sigma^2*n+4*b^2*sigma^2*n)-2*sigma^2*n)/(2*sigma^2);
	P_av(i) = req_s/PPS_S;
	P_peak(i) = P_av(i)/(pulses*pulse_length);
end

loglog(P_av, P_peak, 'linewidth', 4);

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

% hold off;
xlabel('average optical power [W]');
ylabel('peak optical power [W]')
% legend('thr=1','thr=2','thr=4','thr=8','thr=16','thr=32','thr=64', 'thr=128','thr=256', 'thr=512','thr=1024', 'location', 'northeastoutside');
title('Peak vs average power, altitude=500 m');
print('-deps', '-color', '../report/fig/hdm_peak_vs_av.eps');










