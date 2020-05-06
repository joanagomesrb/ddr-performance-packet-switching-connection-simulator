C= 2;
f= 100000;
P= 100000;

%lambda= [250, 500, 750, 1000, 1250, 1350, 1450, 1550, 1650, 1750, 2000, 2250, 2500];
% alinea f e g
lambda= [50, 100, 150, 200, 250, 270, 290, 310, 330, 350, 400, 450, 500];

n_cases = 13;

fileID = fopen('alinea_g.txt', 'w');


for i = 1:n_cases
	for j = lambda
        disp(j)
		[PL , APD , MPD , TT, DelayMM1, DelayMG1] = run2_simulator1(j,C,f,P, fileID);
    end
end

fclose(fileID);