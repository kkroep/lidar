clear all;
close;
clc;

for n = 1:9
    Nsamples = 10;
    Ssamples = ceil(2^(n-5)*100);
    no_samples = 5e3;


    ToF = 0.75; % percentage of full thing
    pulse_period = 5e-8; % [s]
        LSB = pulse_period/no_samples; % binsize 
    samples  = ceil(pulse_period/(LSB));

    N = ones(1,samples);
    N = N/sum(N);
    S = zeros(1,samples);

    T_laser_pulse = 100e-12; % [s]
    laser_samples = ceil(100e-12/LSB);
    ToFloc = floor(ToF*length(S));
    S(ToFloc:ToFloc+laser_samples)=1/laser_samples;

    c = N;
    for i=1:Nsamples-1
        c = conv(c,N);
    end

    for i=1:Ssamples
        c = conv(c,S);
    end

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
    SNR(n) = 10*log10(Ssamples/Nsamples);
    fprintf('\n\nSNR = %f [dB]\n', SNR(n));

    FWHM(n) = percentage*pulse_period*1e9;
    fprintf('FWHM = %f ps\n', FWHM(n));
    
    var_s = 100e-12;
    var_n = pulse_period/sqrt(12);
    VARmean = (Ssamples*var_s^2+Nsamples*var_n^2)/(Ssamples+Nsamples)^2;
    FWHM_calc(n) = sqrt(VARmean)*2.35*1e9;
    fprintf('FWHM calculated = %f ps\n', FWHM_calc(n));

end

hold on;
title('accuracy vs SNBR, T_{pulse} = 50 ns, PPS_N = 10');
plot(SNR, FWHM);
plot(SNR, FWHM_calc, ':');
legend('simulated','calculated');
xlabel('SNBR [dB]');
ylabel('FWHM [ns]');
hold off;
