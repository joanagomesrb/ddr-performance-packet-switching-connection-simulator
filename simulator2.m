function [PL , APD , MPD , TT, DelayMM1, DelayMG1, PLVoip, APDvoip, MPDvoip] = simulator1(lambda,C,f,P)
% INPUT PARAMETERS:
%  lambda - packet rate (packets/sec)
%  C      - link bandwidth (Mbps)
%  f      - queue size (Bytes)
%  P      - number of packets (stopping criterium)
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
Queue= [];          % Size and arriving time instant of each packet in the queue

%Statistical Counters:
TotalPackets= 0;       % No. of packets arrived to the system
TotalPacketsVoip= 0;
LostPackets= 0;        % No. of packets dropped due to buffer overflow
LostPacketsVoip=0;
TransmittedPackets= 0; % No. of transmitted packets
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
while TransmittedPackets + TransmittedPacketsVoip <P               % Stopping criterium
    EventList= sortrows(EventList,2);    % Order EentList by time
    Event= EventList(1,1);               % Get first event and 
    Clock= EventList(1,2);               %   and
    PacketSize= EventList(1,3);          %   associated
    ArrivalInstant= EventList(1,4);      %   parameters.
    Type = EventList(1,5);
    EventList(1,:)= [];                  % Eliminate first event
    switch Event
        case ARRIVAL                     % If first event is an ARRIVAL
            % ifs para destinguir entre VOIP e DATA
            TotalPackets= TotalPackets+1;
            EventList = [EventList; ARRIVAL , Clock + exprnd(1/lambda) , GeneratePacketSize() , 0];
            if State==0
                State= 1;
                EventList = [EventList; DEPARTURE , Clock + 8*PacketSize/(C*10^6) , PacketSize , Clock];
            else
                if QueueOccupation + PacketSize <= f
                    Queue= [Queue;PacketSize , Clock, Type];
                    QueueOccupation= QueueOccupation + PacketSize;
                else
                    LostPackets= LostPackets + 1;
                end
            end
        case DEPARTURE                     % If first event is a DEPARTURE
            TransmittedBytes= TransmittedBytes + PacketSize;
            Delays= Delays + (Clock - ArrivalInstant);
            if Clock - ArrivalInstant > MaxDelay
                MaxDelay= Clock - ArrivalInstant;
            end
            TransmittedPackets= TransmittedPackets + 1;
            if QueueOccupation > 0
                EventList = [EventList; DEPARTURE , Clock + 8*Queue(1,1)/(C*10^6) , Queue(1,1) , Queue(1,2)];
                QueueOccupation= QueueOccupation - Queue(1,1);
                Queue(1,:)= [];
            else
                State= 0;
            end
    end
end

%Performance parameters determination:
PL= 100*LostPackets/TotalPackets;      % in %
PLVoip = 100*LostPacketsVoip/TotalPacketsVoip;
APD= 1000*Delays/TransmittedPackets;   % in milliseconds
APDvoip = 1000 *DelaysVoip/TransmittedPacketsVoip;
MPD= 1000*MaxDelay;                    % in milliseconds
MPDvoip = 1000* MaxDelayVoip;
TT= 10^(-6)*TransmittedBytes*8/Clock;  % in Mbps

DelayMM1 = MM1DelayCalc(lambda, C);
DelayMG1 =  MG1DelayCacl(lambda, C);
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

%Alinea e)
function W = MM1DelayCalc(lambda, C)
    bpp = 8;
    n = 65:1517;
    sum = 0;
    sum = ((65+1517)/2);
    u = (C * 10^6)/((64*0.16 + 0.22*1518 + sum*0.62)  * bpp);
    W = (1/(u-lambda))*1000;
end

function W =  MG1DelayCacl(lambda, C)
    bpp = 8; 
    
    % mean of interval (itv) 65 - 1517
    itv = (1517+65)/2;
    
    % probability of each interval
    p_64 = 0.16;
    p_itv = 1-0.16-0.22;
    p_1518 = 0.22;
   
    % ES = tempo * prob
    ES = (64*bpp/(C*10^6))*p_64 + (3 + (1518*bpp/(C*10^6))*p_1518;   
    % ES2 = tempo^2 * prob
    ES2 = (64*bpp/(C*10^6))^2 * p_64 + ((itv*bpp)/(C*10^6))^2 * p_itv + (((1518*bpp/(C*10^6))))^2 * p_1518;  
    
    % formula
    W = ((lambda * ES2)/(2*(1-lambda * ES))+ES)*1000;
end