clc;
clear;
%%%%%%%%%%%%%%com porte%%%%%%%%%%%%%%
%ar='COM6';
Vaegtm='COM8';
%condcom='COM8';
%%%%%%fysiske parametre%%%%%%
densitet=1; %g/ml
mema=(0.003185);      %membran areal [m^2]       Ny rund: 0.036 * antal skiver     Keramisk: 0.19    Rav-hus,plast: 0.011432
flow=[];
tidflow=[];
flux=[];
Pumpcon=0; %om pumpen skal forts?tte(0=nej eller 1=ja)
excel=1; %om pumpen skal forts?tte(0=nej eller 1=ja)
    exname='C6260V2';    %%%%Excel name
Pumpstart=0; %pumpe start  sekunder
Pumpend=0; %pumpe efter k?rt program i sek
SampleDuration=60*8; %Definerer hvor lang tid den skal k?re [s]
Delay=1; %Definerer den tid, man vil have, mellem hver m?ling [s]
plotrow=2;    %antal rows i loop-plot
plotcol=2;    %antal columns i loop-plota
%%%%% styre Pumper %%%%%
FeedRPM=0; %?nsket RPM for feed D3 bruge ikke lige nu
PermRPM=35; % ?nsket RPM for permeat

%%%%%%%%%%%%%definer conductivitets variable%%%%%%%%%%%%%%%
%s1 = serial(condcom); % Conductivity meter
%set(s1,'BaudRate',1200,'Databits',8,'StopBit',1,'Terminator','CR/LF')
%cond=[];
temp=[];
condi=[];
j=1;

%%%% Definer temperatur variable %%%%
Tfm=[];
Tfo=[];
Tfi=[];
Tpo=[];
Tpi=[];
pH=[];
Conductivity=[];
Turb=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%a = arduino(ar, 'Mega2560', 'Libraries', 'PaulStoffregen/OneWire')
%date = datestr(now, 'yyyy-mm-dd_HH.MM');    %dato format indstilles til fil navngivning



%kalibrering fra rpm til volt
%Fpump=FeedRPM*0.01666666667; 
%Ppump=PermRPM*0.01666666667;

%%%%writePWMVoltage(a,'D30',Fpump)
%%%%writePWMVoltage(a,'D20',Ppump)

%%Pumpe opstartstid%%%%%%%%%
%Pumptime=rem(now,1)*24*60*60;
%Pumpstartend=Pumptime+Pumpstart;

tic;
%while Pumptime<Pumpstartend
%Pumptime=rem(now,1)*24*60*60;
%end
%Programstart=toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% vaegparametre %%%%%%%%%%%%%%%%%%
s=serial(Vaegtm); %her defineres en digital dataoutput session
set(s,'BaudRate',9600,'DataBits',8,'FlowControl','none','Parity','none','Stopbits',1,'Terminator','LF');

%Faste parametre
TimeStart=toc; %Definerer starttid, ved rem(now,1) f?s kun tid (i sekunder)
LastTime=toc; %Definerer sidste tid, som l?bende omdefineres og bruges til at regne ny tid

EndTime=TimeStart+SampleDuration; %Definerer, hvad tiden skal v?re til slut
i=1; %i er antal m?linger
j=0;
date = datestr(now, 'yyyy-mm-dd_HH.MM');    %dato format indstilles til fil navngivning
Startdato=floor(now)+rem(now,1); % fordi Malene og Anders ikke vidste hvad de lavede

fopen(s);


while LastTime<EndTime
    ThisTime=toc;% beregner ny tid
    if ThisTime>i*Delay; %Kun hvis der er g?et to sekunder*antal m?lepunkter siden start, m? den g?re f?lgende
        LastTime=toc; %Beregner ny tid
       
        fprintf(s,'w')
        vaegtstr=fscanf(s); %henter data fra v?gt som string
        vaegt(i)=str2double(vaegtstr(5:13));
        tid(i)=LastTime-TimeStart; %Udregner hvad tiden er ved m?lingen
        volumen(i)=vaegt(i)*densitet;
       
        if i>1
        flow(i-1)=(volumen(i)-volumen(i-1))/(tid(i)-tid(i-1));
        tidflow(i-1)=tid(i);
        flux(i-1)=flow(i-1)/mema;
        end


subplot(plotrow,plotcol,1)
        plot(tid,vaegt)
        title('Weight over time')
        xlabel('Time [s]')
        ylabel('Weight [g]')
        


       %%%%% end l?ser af temperatur
        
       tid(i)=toc
       
        i=i+1;
        pause(0.5) %m? ikke v?re st?rre end delay
       
    end
end
fclose(s)
delete(s)
clear('s')


        if excel==1
            
            %%%%from here%%%%%%
data = [tid',vaegt'];
    filename = strcat(exname,date,'.xlsx');
    warning off MATLAB:xlswrite:Addsheet
    col_header={'time','weight'};
    xlswrite(filename,col_header,'Tempdata','A2');
    xlswrite(filename,data,'Tempdata','A3');
    
    %%%%%to here%%%%

        end
