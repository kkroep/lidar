% Laser power vs SNBR plot
clear all;
close;
clc;




PB = 0.178;


for i=1:15
    SNR(i) = (i-4)*10;
    PS(i) = PB*10^(SNR(i)/10);
end

semilogy(SNR, PS*10);
ylabel('Laser power [W]')
xlabel('SNBR [dB]');

title('SNBR vs Laser power');

line([min(SNR) max(SNR)],[50 50],'Color',[1 0 0]);