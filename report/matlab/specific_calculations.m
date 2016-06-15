clear all;
close;
clc;

%init
laser_FWHM = 235e-12; % [s]
n = 20000;

%immediate derivations
sigma_s = laser_FWHM;

% hold on;

for j=1:8
    
s = 2000*10^(j);
for i=1
 
    tpulse = 1008750;
    fpulse(i,j) = 1/tpulse; % [s]
    
    sigma_n = tpulse/sqrt(12);
    
    accuracy(i,j) = 3e8/2*(2.35*sqrt(s*sigma_s^2+n*sigma_n^2)/(s+n));
    disp(accuracy(i,j));
%     fprintf('\n');
%     fprintf('FWHM = %f ns\n', FWHM(i,j)*1e9);
%     fprintf('fpulse = %f kHz\n', fpulse(i,j)*1e-3);
%     fprintf('tpulse = %d \n', tpulse);

end


loglog(fpulse(:,j), accuracy(:,j));
hold on;


end

ToF = 53.3e-6;
fToF = round(1/ToF);
hline = 0.05;

line([2000 2000],[min(min(accuracy)), max(max(accuracy))],'Color',[1 0 0]); % single frequency line
line([min(min(fpulse)), max(max(fpulse))],[hline,hline],'Color',[0 1 0]); % single frequency line

% line([2000 2200],[0, 100])%,'Color',[1 0 0]); % single frequency line
% line([0, max(max(fpulse))],[accuracy,accuracy],'Color',[0 1 0]); % single frequency line
ylabel('accuracy [m]');
xlabel('pulse frequency [Hz]');
legend('SNBR = 0 dB','SNBR = 10 dB','SNBR = 20 dB','SNBR = 30 dB','SNBR = 40 dB','SNBR = 50 dB','SNBR = 60 dB','SNBR = 70 dB');
title('pulse frequency vs accuracy, PPSB = 20k');
hold off;

print('fpluse_vs_accuracy','-depsc');

