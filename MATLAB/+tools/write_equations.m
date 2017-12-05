%% write_equations
% WRITE_EQUATIONS This function takes all the inputs after processing from
% the GUI and writes the Equations file for use in Solidworks
function write_equations(POD,PWT,SOD,SWT,fbdia,rbdia,FL,FW,FH,TW,RH,...
			 ack,h,odt,idt,ltr,rbl,pr,N,PD,bore,RL,ir_d,...
			 ss,stcl,stcangle,otod,otid,osid,osod)

if nargin < 28
    warning('Not enough input arguments, using default values');
    POD = 25.0;
    PWT = 3.0;
    SOD = 25.0;
    SWT = 0.89;
    fbdia = 12.7;
    rbdia = 12.7;
    FL  = 1828.8;
    FW  = 914.4;
    FH  = 1219.2;
    TW  = 1397.0;
    RH  = 250.0;
end

%% Populate cell array
% Variables that will change with parametrization
output{1,1}  = 'PrimaryOD';         output{1,2}  = num2str(POD);
output{2,1}  = 'PrimaryWT';         output{2,2}  = num2str(PWT);
output{3,1}  = 'SecondaryOD';       output{3,2}  = num2str(SOD);
output{4,1}  = 'SecondaryWT';       output{4,2}  = num2str(SWT);
output{5,1}  = 'fbdia';             output{5,2}  = num2str(fbdia);
output{6,1}  = 'rbdia';             output{6,2}  = num2str(rbdia);
output{7,1}  = 'FrameLength';       output{7,2}  = num2str(FL);
output{8,1}  = 'FrameWidth';        output{8,2}  = num2str(FW);
output{9,1}  = 'FrameHeight';       output{9,2}  = num2str(FH);
output{10,1} = 'BendingRadius';     output{10,2} = num2str(114.3);
output{11,1} = 'TrackWidth';        output{11,2} = num2str(TW);
output{12,1} = 'RideHeight';        output{12,2} = num2str(RH);

%%
% Equations and variables that do not change with parametrization
output{13,1} = 'Alpha';
output{13,2} = 'abs(atn ( ( "RideHeight" - 152 ) / "SuspWidth" ))';

output{14,1} = 'SuspWidth';
output{14,2} = '( "TrackWidth" / 2 ) - 7in - ( "FrameWidth" - 24in ) / 2';

output{15,1} = 'ShockAngle';        output{15,2} = '60';

output{16,1} = 'Beta';              
output{16,2} = 'abs(atn ( ( ("TrackWidth"/2) -7.25in- ( (25.6in+ ("FrameWidth"-36in))/2) )/11in))';

output{17,1} = 'Theta';
output{17,2} = 'abs(atn (5.5in /(("TrackWidth"/2)-10in) ))';

output{18,1} = 'Omega';
output{18,2} = 'abs(atn (9in /(("TrackWidth"/2)-10in) ))';
			    
output{19,1} = 'ackangle';
output{19,2} = num2str(ack);

output{20,1} = 'ODtie';
output{20,2} = [num2str(odt) 'm'];

output{21,1} = 'IDtie';
output{21,2} = [num2str(idt) 'm'];

output{22,1} = 'Ltie';
output{22,2} = [num2str(ltr) 'mm'];

output{23,1} = 'BoxLength';
output{23,2} = [num2str(rbl) 'm'];

output{24,1} = 'Pr';
output{24,2} = [num2str(pr) 'in'];

output{25,1} = 'N';
output{25,2} = num2str(N);

output{26,1} = 'PD';
output{26,2} = [num2str(PD) 'in'];

output{27,1} = 'bore';
output{27,2} = [num2str(bore) 'in'];

output{28,1} = 'RL';
output{28,2} = [num2str(RL) 'm'];

output{29,1} = 'D-inner';
output{29,2} = [num2str(ir_d) 'm'];

output{30,1} = 's';
output{30,2} = [num2str(ss) 'm'];

output{31,1} = 'L-steering_column';
output{31,2} = [num2str(stcl) 'm'];

output{32,1} = 'OD-outer';
output{32,2} = [num2str(otod) 'm'];

output{33,1} = 'ID-outer';
output{33,2} = [num2str(otid) 'm'];

output{34,1} = 'ID-sleeve';
output{34,2} = [num2str(osid) 'm'];

output{35,1} = 'OD-sleeve';
output{35,2} = [num2str(osod) 'm'];

output{36,1} = 'hknuckle';
output{36,2} = [num2str(h) 'm'];

output{37,1} = 'H';
output{37,2} = [num2str(191.7) 'mm'];

output{38,1} = 'steering_column_angle';
output{38,2} = num2str(stcangle);

%% Write to file
% Determine user

switch getenv('username')
    case ''
        % John - Ubuntu
        fname = 'Equations.txt';
    case 'just-'
        % Justin home computer
        fname = 'C:\Users\just-\Google Drive\University\8 - Fall 2017\MCG4322\GrabCAD\CADCAM\Equations.txt';
    otherwise
        fname = 'Z:\2017\MCG4322A\Digital Files\BAJA 2B\Solidworks\Equations.txt';
end

%%
% Open the file
try
    efid = fopen(fname,'w+');
catch
    error('Cannot write to %s\r',fname);
end

%%
% Print values to file
[n,~] = size(output);
for k = 1:n
    fprintf(efid,'"%s" = %s\r',output{k,1},output{k,2});
    fprintf(efid,'\n');
end

%%
% Close the file
try
    fclose(efid);
    fprintf('Successfully wrote file %s\r',fname);
catch
    error('Not able to close file %s\r',fname);
end
