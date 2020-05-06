
function [PL , APD , MPD , TT, DelayMM1, DelayMG1] = run2_simulator1(lambda,C,f,P, fileID)
    n_times = 10;

    result_PL = zeros(1, n_times);
    result_APD = zeros(1, n_times);
    result_MP = zeros(1, n_times);
    result_TT = zeros(1, n_times);
    
    for i = 1:n_times
        [PL , APD , MPD , TT, DelayMM1, DelayMG1] = simulator1(lambda,C,f,P);
        result_PL(i) = PL;
        result_APD(i) = APD;
        result_MP(i) = MPD;
        result_TT(i) = TT;
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

    fprintf(fileID, 'result PL  _%4.4f_ = %6.3f +/- %6.3f\n', lambda, media_PL, term_PL)
    fprintf(fileID, 'result APL _%4.4f_ = %6.3f +/- %6.3f\n', lambda, media_APD, term_APD)
    fprintf(fileID, 'result MP  _%4.4f_ = %6.3f +/- %6.3f\n', lambda, media_MP, term_MP)
    fprintf(fileID, 'result TT  _%4.4f_ = %6.3f +/- %6.3f\n', lambda, media_TT, term_TT)

end