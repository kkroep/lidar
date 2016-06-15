clear all;
close;
clc;

Nsamples = 10;
Ssamples = 600;
no_samples = 1e3;


ToF = 0.75; % percentage of full thing
pulse_period = 5e-8; % [s]
LSB = pulse_period/no_samples; % binsize 
samples  = ceil(pulse_period/(LSB));

N = ones(1,samples);
N = N/sum(N);
S = zeros(1,samples);


ToFloc = floor(ToF*length(S));
S(ToFloc:ToFloc+2)=0.333;

hold on;

c = N;
for i=1:Nsamples-1
    c = conv(c,N);
end

plotter = 0:1/length(c):1-1/length(c);
plot(plotter,c);

for i=1:Ssamples
    c = conv(c,S);
end

plotter = 0:1/length(c):1-1/length(c);
plot(plotter,c);


start = 0;
threshold = max(c)/2;
for i=1:length(c)
    if c(i)> threshold
        if start ==0
            start=i;
        end
        c(i)=threshold;
        finish = i;
    else
        c(i)=0;
    end
end

percentage = (finish-start)/length(c);
fprintf('\n\nSNR = %f [dB]\n', 10*log10(Ssamples/Nsamples));
fprintf('Pulse time = %f ns\n', pulse_period*1e9);
fprintf('FWHM = %f ps\n', percentage*pulse_period*1e12);
fprintf('sigma = %f ps\n\n', (percentage*pulse_period*1e12)/2.35);


plot(plotter,c, 'linewidth', 2);

S=S*max(c)*4;
plotter = 0:1/length(S):1-1/length(S);
plot(plotter,S);

N=N*0.1;
plotter = 0:1/length(N):1-1/length(N);
plot(plotter,N);


hold off;

