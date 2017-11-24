%% steering
% STEERING Calculations
function steering(FW,TW,WB,SR,FL,Weight,CG)%add weight and center of mass 

if nargin < 7
    warning(['Number of arguments input to function not sufficient,',...
             ' using default values']);
    FW = 36*0.0254;
    TW = 55*0.0254;
    WB = 64*0.0254;
    SR = 4;
    FL = WB + 8*0.0254;
    Weight = 350; %kg
    CG=0.4;
end


%% Declare global variables
% Maximum tire turning angle [deg]
maxturn = 45;

%%
% Length of steering arm [m]
Lknuckle = 3*0.0254;

%%
% Length from front of roll cage to rack and pinion [m]
Lfromfront=2*0.0254;

%%
% Length from center of tire to kingpin pivot point [m]
Lkp = 4.5*0.0254; %m

%%
% Material Properties
Sy = 276*10^6; %Sy of aluminum 6061 in Pa 
E  = 68.9*10^9; %E of aluminum 6061 in Pa
syb = 240*10^6; %sy of bolt in Pa

[ltr,ackangle,Pr] = steering_geometry(TW,Lkp,WB,SR,FW,Lfromfront,maxturn,...
                                      Lknuckle);
[Ft,Fr] = steering_forces(Weight,CG);

[ni,no,h] = steering_knuckle(Fr,Ft,Sy) 
%sends back new value of cross section height for steering arm

[nt,nr,OD,ID] = Tie_Rod (Fr,Ft,Sy,Ltierod)

[slotsize,nt,nr] = Steering_column_part4 (torin,torr,Sy)

[tubesize,nt,nr] = Steering_column_part2 (torin,torr,Sy)

[tubesize,nt,nr] = steering_column_part3 (torin,torr,Sy)

[tubesize,nt,nr] = steering_column_part1 (torin,torr,Sy,slotsize)

end

function [Ltierod,ackangle,Pr,stclength,racklength,rackboxlength] = steering_geometry(track,Lkp,WB,...
                                                   steeringratio,...
                                                   framewidth,...
                                                   lff,... % length from front
                                                   maxturn,...
                                                   Lknuckle,...
                                                   firewalllength)

%%
% Rack Offset [m]
roffset= 2*0.0254;

%%
% Ackerman angle
ackangle = atand((((track/2)-Lkp)/WB));
% ** OUTPUT TO SOLIDWORKS **

%% 
% minimum turning radius
R = (WB/tand(maxturn))+(track/2); %minimum turning radius from center of vehicle

% %% 
% % outer tire turn angle 
% delta_o = atand(WB/(R+(track/2))) %outer tire turning angle

%%
% Length of the tie rod
Ltierod = sqrt((track/2-framewidth/2-Lkp-3*sind(ackangle))^2 ...
          +(abs(lff-roffset)^2));
%   ** output length of tie rod to solidworks **

%% Motion needed from Rack
% Distance between rack and pivot point @ ackangle
La = (Lknuckle*cosd(ackangle-90))+sqrt(Ltierod^2-(abs(lff-roffset)...
    +(Lknuckle*(cosd(ackangle-90))))^2);

%%
% Distance between rack and pivot point @ max turn angle (45deg)
Lm = (Lknuckle*cosd(ackangle-45))+sqrt(Ltierod^2-(abs(lff-roffset)...
    +(Lknuckle*(cosd(ackangle-45))))^2);

%%
% Difference between those lengths is the movement required by the rack
Lneeded = Lm - La;

%% Pinion Radius
% Calculated pinion radius required for desired steering ratio
Pr = (Lneeded*steeringratio)/(2*pi); 
%   ** output pinion radius to solidworks

%%
% Print to log file 
fprintf('The minimum turning radius of the vehicle is %.1f [m]\n',R);

%%
%length of steering column
stclength = sqrt((firewalllength-(36*0.0254))^2+((48*0.0254)^2));

%%
% rack length 
racklength = framewidth + (2*0.0254);
rackboxlength = framewidth;

end
% **need to find max and min gear radius to create and use database** %
% *** also need to fix the values i use here *** %

function gear_calculations()
%%
%gear wear calculations
PDi=0.875; % pitch diameter of the gear in inch
PDm=0.875*0.0254; % pitch diamter of the gear in m
Bore=0.375*0.0254; %bore of the gear
DP=16; %diametral pitch of the gear 
%Module = something (metric)
Facei=0.75; %face width of gear in inch
Facem=0.75*0.0254; %face width of gear in m
OD=(PDi+0.125); %outer diameter of gear
Pa=20; %pressure angle in deg

Mn=1; % constant for spur gears
V=2;  %m/s max velocity of gear 
Qv=7; %type of gearing constant 
Wt=320; %force transfered through the gear in newtons i guess
Cp=191;
%Cp=sqrt((1/(pi*(2*(1-.3^2)/(200*10^9)))))


I=((cosd(Pa)*sind(Pa))/(2*Mn)); %contact ratio 

B=0.25*((12-Qv)^(2/3));
A=50+(56*(1-B));
Kv=((A+sqrt(200*V))/A)^B; %metric constant

Cpf=(Facei/(10*PDi))-0.025;
Cmc=1; %uncrowned teeth
Cpm=1; %constant
A=0.127;
B=0.0158;   %values found froom a table for comercial enclosed units
C=-0.93*10^(-4);
Cma=A+B*Facei+(C*Facei^2);
Ce=1; %constant
Km=1+(Cmc*((Cpf*Cpm)+(Cma*Ce)));

Ko=1.5;
Ks=1;
Cf=1;

sigmaw=Cp*(sqrt(Wt*Ko*Kv*Ks*(Km/((PDi*25.4)*(Facei*25.4)))*(Cf/I)))

Zn=1.5;
Sc=1896;
Kt=1;
Kr=1.5;
Ch=1;

Sh=((Sc*Zn*Ch)/(Kt*Kr))/sigmaw

%%
% bending stress in gear
J=0.22;
Kb=1;
Wt=7.106;
simgmab=Wt*Ko*Kv*Ks*(PDi/Facei)*(((Km*Kb)/J));
St=482.63*10^6;
Yn=2.5;
Sf=(St*Yn/1*1.5)/sigmab



end




function [Ft,Fr] = steering_forces(Weight,CG)
%%
% determing the forces acting on the system
mu = 0.75; %friction coefficient between tire and track surface
G = 9.8; %garvity m/s^2
assumed_force = 750; %set impact force hitting the side of the tire 

%math

% ** outputed values **
Ftoturn = 174;
Froad= (2225*(11*0.0254))/(4.5*0.0254);
torquein = 
torqueroad = 

end




function [ni,no,h] = Steering_knuckle (Fr,Ft,Sy)

%%
% bending in initially curved beams 
h = 1.5*0.0254; %height of cross section on the arm connecting to the tie rod
b = 1*0.0254;     %width of base of the cross section 
ro = 0.0508;  %outer radius of initially curved beam
ri = 0.0254;  %inner radius of initially curved beam 
Ft = 174;  %force acting on arm ((will alter later))
Fr = 200;
rn = h/(log(ro/ri)); %radius of the neutral axis
rc = ri+(h/2); %radius of the centroidal axis
Ci = rn-ri;  %distance from neutral axis to inner fiber
Co = ro-rn;  %distance from neutral axis to outer fiber
e = rc-rn;  %distance from centroidal axis to neutral axis

A = b*h; %area of cross section 

sigmait = Ft*Ci/(A*e*ri) % inner fiber stress
sigmaot = -Ft*Co/(A*e*ri) %outer fiber stress

sigmair = Fr*Ci/(A*e*ri)
sigmaor = -Fr*Co/(A*e*ri)

nit = sigmait/Sy %safety factor of inner fiber 
not = sigmaot/Sy %safety factor of outer fiber

nir = sigmair/Sy
nor = sigmaor/Sy

while nir<2 && nor<2 && nit<2 && not<2
h=h+(0.125*0.0254)
A=b*h

sigmait = Ft*Ci/(A*e*ri) % inner fiber stress
sigmaot = -Ft*Co/(A*e*ri) %outer fiber stress

sigmair = Fr*Ci/(A*e*ri)
sigmaor = -Fr*Co/(A*e*ri)

nit = sigmait/Sy %safety factor of inner fiber 
not = sigmaot/Sy %safety factor of outer fiber

nir = sigmair/Sy
nor = sigmaor/Sy
end
end




function [nt,nr,OD,ID] = Tie_Rod (Fr,Ft,Sy,Ltierod)
%% 
%buckling stress tie rod
Ft = 174; % force compressing tie rod ((to be changed))
Fr = 200;
OD = 19.05/1000; % outer diameter of tie rod 
ID = 16.1/1000; %inner diameter of tie rod
A = ((pi*OD^2)/4)-((pi*ID^2)/4) %cross sectional area
I = pi/64*(OD^4-ID^4) %momment of inertia 
Lc = Ltierod %corrected buckling tie rod length (tie rod length)
ratio = pi^2*E*I/(A*Lc^2) %comparisson to be compared with Sy/2

if (Sy/2 >= ratio)
    Scr = (pi^2*E*I)/(A*Lc^2)
else  %depending on if its larger or smaller than the ratio Scr will change
    Scr = Sy*(1-((Sy*A*Lc^2)/(4*pi^2*E*I)))
end

sigmat = Ft/A %buckling stress on the tie rod 
sigmar = Fr/A
ntiet = sigmat/Sy %buckling safety factor of the tie rod 
ntier = sigmar/Sy
% ((need to calculate the tension in the tie rod))


end




function [tubesize,nt,nr] = Steering_column_part1 (torin,torr,Sy,slotsize)
%% 
% torsion on steering column part#1
OD = 25.4/1000; %m outer diameter of rod
R = OD/2;  %radius of rod 
J = ((pi*OD^4)/32)-(2*(slotsize^4/6)); %polar moment of inertia of rod 
tauin = ((torin*R)/J) %torsional stress on rod 
nin = ((Sy*.58)/tauin) %torsional stress safety factor of rod
taur = ((torr*R)/J) %torsional stress on rod 
nr = ((Sy*.58)/taur) %torsional stress safety factor of rod

while nin<2 && nr<2
    
    %OD = increase rod size 
    R = OD/2;  %radius of rod 
    J = ((pi*OD^4)/32)-(2*(slotsize^4/6)); %polar moment of inertia of rod 
    tauin = ((torin*R)/J) %torsional stress on rod 
    nin = ((Sy*.58)/tauin) %torsional stress safety factor of rod
    taur = ((torr*R)/J) %torsional stress on rod 
    nr = ((Sy*.58)/taur) %torsional stress safety factor of rod
end

end


function [tubesize,nt,nr] = Steering_column_part2 (torin,torr,Sy)
%%
% torsion on steering column part#2
OD = 28.58/1000;  %m Outer diameter of steering column sleev%torque in steering column ((need to be changed))e 
ID = 25.63/1000; %m Inner diamter of steering column sleeve
R = OD/2; %radius of steering column sleeve
J = ((pi*OD^4)/32)-((pi*ID^4)/32); %polar moment of inertia on steering column sleeve
taur = ((torin*R)/J); % torsional stress on steering column upper sleeve
nr = ((Sy*.58)/taur); %torsional stress safety factor of rod  
tauin = ((torin*R)/J); % torsional stress on steering column upper sleeve
nin = ((Sy*.58)/tauin); %torsional stress safety factor of rod  

while nt<2 && nr<2
    %OD = increase tube size %
    %ID = increase tube size %
    R = OD/2;
    J = ((pi*OD^4)/32)-((pi*ID^4)/32);
    taur = ((torin*R)/J);
    nr = ((Sy*.58)/taur);
    tauin = ((torr*R)/J);
    nin = ((Sy*.58)/tauin);
end    

end


function [tubesize,nt,nr] = steering_column_part3 (torin,torr,Sy)
%%
% torsion on steering column part#3
b=1.48/1000; % bolt hole thickness 
d=12/1000;  %bolt hole diameter
OD=(15.88*2)/1000;  %m outer diameter of bigger sleeve
ID=(14.40*2)/1000; %m inner diameter of bigger sleeve
R=OD/2; % radius of bigger sleeve
J=((pi*OD^4)/32)-((pi*ID^4)/32)-(((b*d)*(b^2+d^2))/12); %polar momment of inertia of bigger sleeve 

tauin=((torin*R)/J) %torsional stress on bigger sleeve
nin=((Sy*.58)/tauin) %torsional stress on bigger sleeve safety factor 
taur=((torr*R)/J) %torsional stress on bigger sleeve
nr=((Sy*.58)/taur) %torsional stress on bigger sleeve safety factor 

while nin<2 && nr<2
    %OD = increase tube size %
    %ID = increase tube size %
    R = OD/2;
    J = ((pi*OD^4)/32)-((pi*ID^4)/32);
    tauin = ((torin*R)/J);
    nin = ((Sy*.58)/tauin);
    taur = ((torr*R)/J);
    nr = ((Sy*.58)/taur);
end    


end


function [slotsize,nt,nr] = steering_column_part4 (torin,torr,syb)
%%
% shear on steering pins
OD=10/1000;  %m outer diameter of bolt 
R=OD/2;  %of outer tube sleeve
r=6.35/1000; %m radius of slot 
A=pi*r^2; % area of cross section of the bolt
tauin=((torin/R)/A) %shear stress on the bolt
nin=((syb*.58)/tauin) %coresponding safety factor of the bolt
taur=((torr/R)/A) %shear stress on the bolt
nr=((syb*.58)/taur) %coresponding safety factor of the bolt

while nin<2 && nr<2
    %increase slot size
    r=6.35/1000; %m radius of slot 
    A=pi*r^2; % area of cross section of the bolt
    
    tauin=((torin/R)/A) %shear stress on the bolt
    nin=((syb*.58)/tauin) %coresponding safety factor of the bolt
    taur=((torr/R)/A) %shear stress on the bolt
    nr=((syb*.58)/taur) %coresponding safety factor of the bolt
end

end
