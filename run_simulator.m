% INPUT PARAMETERS:
lambda = 100; %  lambda - packet rate (packets/sec)
C = 2;        %  C      - link bandwidth (Mbps)
f = 100000;   %  f      - queue size (Bytes)
P = 1000;     %  P      - number of packets (stopping criterium)

% run simulator parameters
n_times = 10;
result_PL = zeros(1, n_times);
result_APD = zeros(1, n_times);
result_MP = zeros(1, n_times);
result_TT = zeros(1, n_times);

% actual run simulator n times
for i = 1:n_times
    [PL , APD , MPD , TT] = Simulator1(lambda,C,f,P);
    result_PL(i) = PL;
    result_APD(i) = APD;
    result_MP(i) = MPD;
    result_TT(i) = TT;
end

result_PL

% 90% confidence interval PL
alfa = 0.1;
media_PL = mean(result_PL);
term_PL = norminv(1-alfa/2)*sqrt(var(result_PL)/times);
% APD
alfa = 0.1;
media_APD = mean(result_APD);
term_APD = norminv(1-alfa/2)*sqrt(var(result_APD)/times);
% MP
alfa = 0.1;
media_MP = mean(result_MP);
term_MP = norminv(1-alfa/2)*sqrt(var(result_MP)/times);
% TT
alfa = 0.1;
media_TT = mean(result_TT);
term_TT = norminv(1-alfa/2)*sqrt(var(result_TT)/times);

% print results
fprintf('result PL = %.3e +- %.3e\n', media_PL, term_PL)
fprintf('result APL = %.3e +- %.3e\n', media_APL, term_APL)
fprintf('result MP = %.3e +- %.3e\n', media_MP, term_MP)
fprintf('result TT = %.3e +- %.3e\n', media_TT, term_TT)
