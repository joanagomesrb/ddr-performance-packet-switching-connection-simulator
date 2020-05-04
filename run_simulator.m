% INPUT PARAMETERS:
lambda = 1000; %  lambda - packet rate (packets/sec)
C = 10;        %  C      - link bandwidth (Mbps)
f = 10000;     %  f      - queue size (Bytes)
P = 1000;    %  P      - number of packets (stopping criterium)

% run simulator parameters
n_times = 10;
result_PL = zeros(1, n_times);
result_APD = zeros(1, n_times);
result_MP = zeros(1, n_times);
result_TT = zeros(1, n_times);
result_MM1 = zeros(1, n_times);
result_MG1 = zeros(1, n_times);

result_W_mg1 = zeros(1, n_times);
result_W_mm1 = zeros(1, n_times);

% actual run simulator n times
for i = 1:n_times
    [PL , APD , MPD , TT, DelayMM1, DelayMG1] = simulator1(lambda,C,f,P);
    result_PL(i) = PL;
    result_APD(i) = APD;
    result_MP(i) = MPD;
    result_TT(i) = TT;
    result_W_mg1(i) = DelayMG1;
    result_W_mm1(i) = DelayMM1;
end

% 90% confidence interval PL
alfa = 0.1;
media_PL = mean(result_PL);
%media_PL = sum(result_PL)/n_times
term_PL = norminv(1-alfa/2)*sqrt(var(result_PL)/n_times);
% APD
alfa = 0.1;
media_APD = mean(result_APD);
term_APD = norminv(1-alfa/2)*sqrt(var(result_APD)/n_times);
% MP
alfa = 0.1;
media_MP = mean(result_MP);
term_MP = norminv(1-alfa/2)*sqrt(var(result_MP)/n_times);
% TT
alfa = 0.1;
media_TT = mean(result_TT);
term_TT = norminv(1-alfa/2)*sqrt(var(result_TT)/n_times);
% MG1
alfa = 0.1;
media_w = mean(result_W_mg1);
term_w = norminv(1-alfa/2)*sqrt(var(result_W_mg1)/n_times);
%MM1 W
media_w_mm1 = mean(result_W_mm1);
term_w_mm1 = norminv(1-alfa/2)*sqrt(var(result_W_mm1)/n_times);

% print results
fprintf('result PL = %6.3f +/- %6.3f\n', media_PL, term_PL)
fprintf('result APL = %6.3f +/- %6.3f\n', media_APD, term_APD)
fprintf('result MP = %6.3f +/- %6.3f\n', media_MP, term_MP)
fprintf('result TT = %6.3f +/- %6.3f\n', media_TT, term_TT)
fprintf('result W MG1 = %6.3f +/- %6.3f\n', media_w, term_w)
fprintf('result W MM1 = %6.3f +/- %6.3f\n', media_w_mm1, term_w_mm1)

