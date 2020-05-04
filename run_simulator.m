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

result_WQ_mg1 = zeros(1, n_times);
result_W_mm1 = zeros(1, n_times);
result_WQ_mm1 = zeros(1, n_times);

% actual run simulator n times
for i = 1:n_times
    [PL , APD , MPD , TT] = simulator1(lambda,C,f,P);
    result_PL(i) = PL;
    result_APD(i) = APD;
    result_MP(i) = MPD;
    result_TT(i) = TT;
    result_WQ_mg1(i) = MG1DelayCacl(lambda, C, f);
    result_W_mm1(i) = MM1DelayCalc(lambda, C, f);
    result_WQ_mm1(i) = MM1DelayCalc(lambda, C, f);
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
media_wq = mean(result_WQ_mg1);
term_wq = norminv(1-alfa/2)*sqrt(var(result_WQ_mg1)/n_times);
%MM1 WQ
media_wq_mm1 = mean(result_WQ_mm1);
term_wq_mm1 = norminv(1-alfa/2)*sqrt(var(result_WQ_mm1)/n_times);
%MM1 W
media_w_mm1 = mean(result_W_mm1);
term_w_mm1 = norminv(1-alfa/2)*sqrt(var(result_W_mm1)/n_times);

% print results
fprintf('result PL = %6.3f +/- %6.3f\n', media_PL, term_PL)
fprintf('result APL = %6.3f +/- %6.3f\n', media_APD, term_APD)
fprintf('result MP = %6.3f +/- %6.3f\n', media_MP, term_MP)
fprintf('result TT = %6.3f +/- %6.3f\n', media_TT, term_TT)
fprintf('result WQ MG1 = %6.3f +/- %6.3f\n', media_wq, term_wq)
fprintf('result WQ MM1 = %6.3f +/- %6.3f\n', media_wq_mm1, term_wq_mm1)
fprintf('result W MM1 = %6.3f +/- %6.3f\n', media_w_mm1, term_w_mm1)

function [W, WQ] = MM1DelayCalc(lambda, C, f)
    bpp = 8;    
    u = (C * 10^6)/(f * bpp);
    W = 1/(u-lambda);
    WQ = W - 1/u;
end

function WQ =  MG1DelayCacl(lambda, C, f)
    bpp = 8;    
    u = (C * 10^6)/(GeneratePacketSize() * bpp);
    ES = 1/u;
    ES2 = 2/u^2;
    WQ = (lambda * ES2)/2*(1-lambda * ES);
end

function out= GeneratePacketSize()
    aux= rand();
    if aux <= 0.16
        out= 64;
    elseif aux >= 0.78
        out= 1518;
    else
        out = randi([65 1517]);
    end
end

