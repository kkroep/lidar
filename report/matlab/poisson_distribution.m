clear all;
clc;
close;



lambda_s = 1;
lambda_n = 0.02;

max_threshold = 100

for k=0:max_threshold
    Ps(k+1) = lambda_s^k*exp(-lambda_s)/factorial(k);
    Pn(k+1) = lambda_n^k*exp(-lambda_n)/factorial(k);
end

hold on;
plot(0:max_threshold, Ps);
plot(0:max_threshold, Pn);
hold off;