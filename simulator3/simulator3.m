function [PL , APD , MPD , TT, PLvoip, APDvoip, MPDvoip, DelayMG1_voip, DelayMG1_data] = simulator3(lambda,C,f,P, n)
% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
%  n      - number of VoIP flows
% OUTPUT PARAMETERS:
%  PL   - packet loss (%)
%  APD  - average packet delay (milliseconds)
%  MPD  - maximum packet delay (milliseconds)
%  TT   - transmitted throughput (Mbps)

%Events:
ARRIVAL= 0;       % Arrival of a packet            
DEPARTURE= 1;     % Departure of a packet

DATA = 1;
VOIP = 2;

%State variables:
State = 0;          % 0 - connection free; 1 - connection bysy
QueueOccupation= 0; % Occupation of the queue (in Bytes)
QueueOccupationVoIP=0;
Queue= [];          % Size and arriving time instant of each packet in the queue
QueueVoIP=[];

%Statistical Counters:
TotalPackets= 0;       % No. of packets arrived to the system
TotalPacketsVoip= 0;
LostPackets= 0;        % No. of packets dropped due to buffer overflow
LostPacketsVoip=0;
TransmittedPackets= 0; % No. of transmitted packets
TransmittedPacketsVoip= 0;
TransmittedBytes= 0;   % Sum of the Bytes of transmitted packets
Delays= 0;             % Sum of the delays of transmitted packets
DelaysVoip= 0;   
MaxDelay= 0;           % Maximum delay among all transmitted packets
MaxDelayVoip= 0;

%Auxiliary variables:
% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first ARRIVAL:
EventList = [ARRIVAL , Clock + exprnd(1/lambda) , GeneratePacketSize() , 0, DATA];
for i=1:n
    EventList = [EventList; ARRIVAL, Clock + 0.02*rand(), GeneratePacketSizeVoip(), 0 , VOIP];
end 

%Similation loop:
while (TransmittedPackets + TransmittedPacketsVoip) < P               % Stopping criterium
    EventList= sortrows(EventList,2);    % Order EentList by time
    Event= EventList(1,1);               % Get first event and 
    Clock= EventList(1,2);               %   and
    PacketSize= EventList(1,3);          %   associated
    ArrivalInstant= EventList(1,4);      %   parameters.
    Type = EventList(1,5);
    EventList(1,:)= [];                  % Eliminate first event
    switch Event
        case ARRIVAL                     % If first event is an ARRIVAL
            if Type == DATA
                TotalPackets= TotalPackets+1;
                EventList = [EventList; ARRIVAL , Clock + exprnd(1/lambda) , GeneratePacketSize() , 0, Type];
                if State==0
                    State= 1;
                    EventList = [EventList; DEPARTURE , Clock + 8*PacketSize/(C*10^6) , PacketSize , Clock, Type];
                else
                    if QueueOccupation + QueueOccupationVoIP + PacketSize <= f
                        Queue = [Queue;PacketSize , Clock, Type];
                        QueueOccupation= QueueOccupation + PacketSize;
                    else
                        LostPackets= LostPackets + 1;
                    end
                end
            end
            if Type == VOIP
                TotalPacketsVoip = TotalPacketsVoip+1;
                    EventList = [EventList; ARRIVAL, Clock + 0.016 + 0.008*rand(), GeneratePacketSizeVoip(), 0 , Type];
                if State==0
                    State= 1;
                    EventList = [EventList; DEPARTURE , Clock + 8*PacketSize/(C*10^6) , PacketSize , Clock, Type];
                else
                    if QueueOccupation + QueueOccupationVoIP + PacketSize <= f
                        QueueVoIP = [QueueVoIP;PacketSize , Clock, Type];
                        QueueOccupationVoIP = QueueOccupationVoIP + PacketSize;
                    else
                        LostPacketsVoip= LostPacketsVoip + 1;
                    end
                end
            end
        case DEPARTURE
            if Type == DATA
                TransmittedBytes= TransmittedBytes + PacketSize;
                Delays= Delays + (Clock - ArrivalInstant);
                if Clock - ArrivalInstant > MaxDelay
                    MaxDelay= Clock - ArrivalInstant;
                end
                TransmittedPackets= TransmittedPackets + 1;
                if QueueOccupationVoIP > 0
                    EventList = [EventList; DEPARTURE , Clock + 8*QueueVoIP(1,1)/(C*10^6) , QueueVoIP(1,1) , QueueVoIP(1,2), QueueVoIP(1,3)];
                    QueueOccupationVoIP = QueueOccupationVoIP - QueueVoIP(1,1);
                    QueueVoIP(1,:) = [];
                else
                    if QueueOccupation > 0
                    EventList = [EventList; DEPARTURE , Clock + 8*Queue(1,1)/(C*10^6) , Queue(1,1) , Queue(1,2), Queue(1,3)];
                    QueueOccupation = QueueOccupation - Queue(1,1);
                    Queue(1,:) = [];    
                    else
                        State= 0;
                    end
                end
            end
            if Type == VOIP
                TransmittedBytes= TransmittedBytes + PacketSize;
                DelaysVoip= DelaysVoip + (Clock - ArrivalInstant);
                if Clock - ArrivalInstant > MaxDelayVoip
                    MaxDelayVoip= Clock - ArrivalInstant;
                end
                TransmittedPacketsVoip= TransmittedPacketsVoip + 1;
                if QueueOccupationVoIP > 0
                    EventList = [EventList; DEPARTURE , Clock + 8*QueueVoIP(1,1)/(C*10^6) , QueueVoIP(1,1) , QueueVoIP(1,2), QueueVoIP(1,3)];
                    QueueOccupationVoIP= QueueOccupationVoIP - QueueVoIP(1,1);
                    QueueVoIP(1,:)= [];
                else
                    if QueueOccupation > 0
                    EventList = [EventList; DEPARTURE , Clock + 8*Queue(1,1)/(C*10^6) , Queue(1,1) , Queue(1,2), Queue(1,3)];
                    QueueOccupation= QueueOccupation - Queue(1,1);
                    Queue(1,:)= [];    
                    else
                        State= 0;
                    end
                end
            end
    end
end
%Performance parameters determination:
PL= 100*LostPackets/TotalPackets;      % in %
PLvoip = 100*LostPacketsVoip/TotalPacketsVoip;
APD= 1000*Delays/TransmittedPackets;   % in milliseconds
APDvoip = 1000 *DelaysVoip/TransmittedPacketsVoip;
MPD= 1000*MaxDelay;                    % in milliseconds
MPDvoip = 1000* MaxDelayVoip;
TT= 10^(-6)*TransmittedBytes*8/Clock;  % in Mbps
[DelayMG1_voip, DelayMG1_data] =  MG1_Calc(lambda, C, n);
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

function out = GeneratePacketSizeVoip()
    out = randi([110 130]);
end

function [W1, W2] = MG1_Calc(lambda, C, n)
        
    % variable initialization
    lambda2 = lambda;
    bpp = 8;  
    nr_bytes_data = 65:1517;
    % medium packet size VoIP
    mps = (110+130)/2;
    % average time between arrivals 
    %avg_time = (16+22)/2; % in miliseconds

    % lambda --> arrival rate
    lambda1 = (1/(20*10^-3)) *  n; % in seconds
    
    % ESs data
    sum = 0;
    sum2 = 0;
    for i = 1:size(nr_bytes_data,2)
        sum = sum + (nr_bytes_data(i)*bpp)*(0.62/(1518-65));
        sum2 = sum2 + ((nr_bytes_data(i)*bpp)/(C*10^6))^2*(0.62/(1518-65));
    end
    
    % miu --> packets per second --> connection capacity / medium packet size (in
    % bits)
    u1 = (C*10^6) / (mps*bpp);
    u2 = (C * 10^6)/(64*bpp*0.16 + 0.22*1518*bpp + sum);
    
    p_64 = 0.16;
    p_1518 = 0.22;
   
    % ES = tempo * prob
    ES_data = (64*bpp/(C*10^6))*p_64 + sum/(C*10^6) + (1518*bpp/(C*10^6))*p_1518;   
    % ES2 = tempo^2 * prob
    ES2_data = ((64*bpp/(C*10^6))^2 * p_64) + sum2 +  ((1518*bpp/(C*10^6)))^2 * 0.22;  
    
    % ES voip has a uniform distribution between 110 and 130
    % ES2 --> service time
    %ES_voip = 1/u2;
    bytes_voip = 110:130;
    sum3 = 0;
    sum4 = 0;
    for i = 1:size(bytes_voip, 2)
        sum3 = sum3 + (((bytes_voip(i))*bpp/(C*10^6)))*(1/21);
        sum4 = sum4 + (((bytes_voip(i))*bpp/(C*10^6))^2)*(1/21);
    end
   
    ES_voip = sum3;
    ES2_voip = sum4;
    
    p1 = (lambda1/u1);
    p2 = (lambda2/u2);
    
    WQ1 = ((lambda1*ES2_voip) + (lambda2*ES2_data)) / (2*(1-p1));
    WQ2 = ((lambda1*ES2_voip) + (lambda2*ES2_data)) / (2*(1-p1)*(1-p1-p2));

    % atraso do sistema � igual ao atraso da fila de espera mais o tempo
    % que os pacotes demoram a serem transmitidos
    W1 = (WQ1 + ES_voip) * 1000;
    W2 = (WQ2 + ES_data) * 1000;
   
end