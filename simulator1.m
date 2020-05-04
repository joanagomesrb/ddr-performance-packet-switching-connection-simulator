function [PL , APD , MPD , TT, DelayMM1, DelayMG1] = simulator1(lambda,C,f,P)
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

%State variables:
State = 0;          % 0 - connection free; 1 - connection bysy
QueueOccupation= 0; % Occupation of the queue (in Bytes)
Queue= [];          % Size and arriving time instant of each packet in the queue

%Statistical Counters:
TotalPackets= 0;       % No. of packets arrived to the system
LostPackets= 0;        % No. of packets dropped due to buffer overflow
TransmittedPackets= 0; % No. of transmitted packets
TransmittedBytes= 0;   % Sum of the Bytes of transmitted packets
Delays= 0;             % Sum of the delays of transmitted packets
MaxDelay= 0;           % Maximum delay among all transmitted packets

%Auxiliary variables:
% Initializing the simulation clock:
Clock= 0;

% Initializing the List of Events with the first ARRIVAL:
EventList = [ARRIVAL , Clock + exprnd(1/lambda) , GeneratePacketSize() , 0];

%Similation loop:
while TransmittedPackets<P               % Stopping criterium
    EventList= sortrows(EventList,2);    % Order EentList by time
    Event= EventList(1,1);               % Get first event and 
    Clock= EventList(1,2);               %   and
    PacketSize= EventList(1,3);          %   associated
    ArrivalInstant= EventList(1,4);      %   parameters.
    EventList(1,:)= [];                  % Eliminate first event
    switch Event
        case ARRIVAL                     % If first event is an ARRIVAL
            TotalPackets= TotalPackets+1;
            EventList = [EventList; ARRIVAL , Clock + exprnd(1/lambda) , GeneratePacketSize() , 0];
            if State==0
                State= 1;
                EventList = [EventList; DEPARTURE , Clock + 8*PacketSize/(C*10^6) , PacketSize , Clock];
            else
                if QueueOccupation + PacketSize <= f
                    Queue= [Queue;PacketSize , Clock];
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
APD= 1000*Delays/TransmittedPackets;   % in milliseconds
MPD= 1000*MaxDelay;                    % in milliseconds
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

%Alinea e)
function W = MM1DelayCalc(lambda, C)
    bpp = 8;
    n = 65:1517;
    sum = 0;
    for i = 1:size(n,2)
       sum = sum + (n(i)+64)*(0.62/(1517-65));
    end
    u = (C * 10^6)/(((64*0.16 + 0.22*1518 + sum) ) * bpp);
    W = 1/(u-lambda);
end

function W =  MG1DelayCacl(lambda, C)
    %n = 1452;
    %n = fixed.Interval(65,1517);
    n = 65:1517;
    sum = 0;
    for i = 1:size(n,2)
       %sum = 65*(0.62/(1517-65));
       sum = sum + (n(i)+64)*(0.62/(1517-65));
    end
    bpp = 8;   
    u = (C * 10^6)/(((64*0.16 + 0.22*1518 + sum) ) * bpp);
    %weighted_avg = 0.34*1453/0.62;
    %disp(weighted_avg);
    %u = (C * 10^6)/(weighted_avg * bpp);
    
    ES = 1/u;
    ES2 = 2/u^2;
    W = (lambda * ES2)/2*(1-lambda * ES)+ES;
end