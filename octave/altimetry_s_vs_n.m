% arg1 is csv location
% arg2 is eps destination
clear all;
close;
clc;

% arg_list = argv ();
% for i = 1:nargin
%   printf (" %s\n", arg_list{i});
% endfor


graphics_toolkit gnuplot;

sigma = 26.65e-9
a = 42.5e-12
b = 53.3e-6/sqrt(12)

n = 1:200000;
s = (a^2+sqrt(a^4-4*a^2*sigma^2*n+4*b^2*sigma^2*n)-2*sigma^2*n)/(2*sigma^2);


hold on;
plot(n, s, 'linewidth', 4);

hold off;

xlabel('noise photons');
ylabel('signal photons')
%legend('reset', 'location', 'northeastoutside');
title('\sigma_{tot}=26.65 ns, \sigma_s = 42.5 ps, \sigma_n = 15.4 us');
print('-deps', '-color', '../report/fig/altimetry_s_vs_n.eps');

close;

plot(n(1:2000), s(1:2000), 'linewidth', 4);


xlabel('noise photons');
ylabel('signal photons')
%legend('reset', 'location', 'northeastoutside');
title('\sigma_{tot}=26.65 ns, \sigma_s = 42.5 ps, \sigma_n = 15.4 us');
print('-deps', '-color', '../report/fig/altimetry_s_vs_n_small.eps');

close;

%% Poisson Jetser

colorspec = {[0.4 0 0.8]; [0.4 0.8 0]; [0.4 0.7 0.7]; ...
  [0 0.4 0.8]; [0.8 0.4 0]; [0.7 0.4 0.7]; ...
  [0.8 0 0.4]; [0 0.8 0.4]; [0.7 0.7 0.4]; ...
  [0 0 0.4]; [0 0.4 0]; [0.4 0 0]};


threshold = [1 2 4 8 16 32 64 128 256 512 1024]
x_max = 1000000;
x = 1:1000;
% for j=length(threshold):-1:1
for j=1:length(threshold)
	for i=x
		y(i) = 1-sum(poisspdf(0:threshold(j), i));
	end
	semilogx(x,y, 'linewidth', 4, 'Color', colorspec{j})
	hold on;
end

hold off;
xlabel('expected photons per bin');
ylabel('opacity')
legend('thr=1','thr=2','thr=4','thr=8','thr=16','thr=32','thr=64', 'thr=128','thr=256', 'thr=512','thr=1024', 'location', 'northeastoutside');
title('expected no photons per bin vs energy threshold performance');
print('-deps', '-color', '../report/fig/threshold_efficiency.eps');










