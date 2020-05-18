% INPUT PARAMETERS:
lambda = 1000; %  lambda - packet rate (packets/sec)
C = 10;        %  C      - link bandwidth (Mbps)
f = 10000;     %  f      - queue size (Bytes)
P = 100000;    %  P      - number of packets (stopping criterium)
nvoip = 75;
r = 50;
% run simulator parameters
%DATA results initialization
n_times = 10;
result_PL = zeros(1, n_times);
result_APD = zeros(1, n_times);
result_MP = zeros(1, n_times);
result_TT = zeros(1, n_times);

%VOIP Results inititialization
result_PLvoip = zeros(1, n_times);
result_APDvoip = zeros(1, n_times);
result_MPvoip = zeros(1, n_times);

% actual run simulator n times
for i = 1:n_times
    [PL , APD , MPD , TT, PLvoip, APDvoip, MPDvoip] = simulator4(lambda,C,f,P,nvoip, r);
    result_PL(i) = PL;
    result_APD(i) = APD;
    result_MP(i) = MPD;
    result_TT(i) = TT;
    
    result_PLvoip = PLvoip;
    result_APDvoip = APDvoip;
    result_MPvoip = MPDvoip;
end

% 90% confidence interval PL
alfa = 0.1;
media_PL = mean(result_PL);
term_PL = norminv(1-alfa/2)*sqrt(var(result_PL)/n_times);
% APD
alfa = 0.1;
media_APD = mean(result_APD);
term_APD = norminv(1-alfa/2)*sqrt(var(result_APD)/n_times);
% MP
alfa = 0.1;
media_MP = mean(result_MP);
term_MP = norminv(1-alfa/2)*sqrt(var(result_MP)/n_times);
% PLvoip
alfa = 0.1;
media_PLvoip = mean(result_PLvoip);
term_PLvoip = norminv(1-alfa/2)*sqrt(var(result_PLvoip)/n_times);
% APDvoip
alfa = 0.1;
media_APDvoip = mean(result_APDvoip);
term_APDvoip = norminv(1-alfa/2)*sqrt(var(result_APDvoip)/n_times);
% MPvoip
alfa = 0.1;
media_MPvoip = mean(result_MPvoip);
term_MPvoip = norminv(1-alfa/2)*sqrt(var(result_MPvoip)/n_times);
% TT
alfa = 0.1;
media_TT = mean(result_TT);
term_TT = norminv(1-alfa/2)*sqrt(var(result_TT)/n_times);

% print results
fprintf('result PL = %6.3f +/- %6.3f\n', media_PL, term_PL)
fprintf('result APL = %6.3f +/- %6.3f\n', media_APD, term_APD)
fprintf('result MP = %6.3f +/- %6.3f\n', media_MP, term_MP)
fprintf('result TT = %6.3f +/- %6.3f\n', media_TT, term_TT)
fprintf('result PLvoip = %6.3f +/- %6.3f\n', media_PLvoip, term_PLvoip)
fprintf('result APDvoip = %6.3f +/- %6.3f\n', media_APDvoip, term_APDvoip)
fprintf('result MPvoip = %6.3f +/- %6.3f\n', media_MPvoip, term_MPvoip)

