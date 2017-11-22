%% write_equations
% WRITE_EQUATIONS This function takes all the inputs after processing from
% the GUI and writes the Equations file for use in Solidworks
function write_equations(POD,PWT,SOD,SWT,BHS,FL,FW,FH,TW,RH)

if nargin < 9
    warning('Not enough input arguments, using default values');
    POD = 25.0;
    PWT = 3.0;
    SOD = 25.0;
    SWT = 0.89;
    BHS = 13.0;
    FL  = 1828.8;
    FW  = 914.4;
    FH  = 1219.2;
    TW  = 1397.0;
    RH  = 250.0;
end

%%
% Declare cell array to hold strings and values
output = cell(17,2);

%% Populate cell array
% Variables that will change with parametrization
output{1,1}  = 'PrimaryOD';         output{1,2}  = num2str(POD);
output{2,1}  = 'PrimaryWT';         output{2,2}  = num2str(PWT);
output{3,1}  = 'SecondaryOD';       output{3,2}  = num2str(SOD);
output{4,1}  = 'SecondaryWT';       output{4,2}  = num2str(SWT);
output{5,1}  = 'BoltHoleSize';      output{5,2}  = num2str(BHS);
output{6,1}  = 'FrameLength';       output{6,2}  = num2str(FL);
output{7,1}  = 'FrameWidth';        output{7,2}  = num2str(FW);
output{8,1}  = 'FrameHeight';       output{8,2}  = num2str(FH);
output{9,1}  = 'BendingRadius';     output{9,2}  = num2str(114.3);
output{10,1} = 'TrackWidth';        output{10,2} = num2str(TW);
output{11,1} = 'RideHeight';        output{11,2} = num2str(RH);

%%
% Equations and variables that do not change with parametrization
output{12,1} = 'Alpha';
output{12,2} = 'atn ( ( "RideHeight" - 152 ) / "SuspWidth" )';

output{13,1} = 'SuspWidth';
output{13,2} = '( "TrackWidth" / 2 ) - 7in - ( "FrameWidth" - 24in ) / 2';

output{14,1} = 'ShockAngle';        output{14,2} = '60';

output{15,1} = 'Beta';              
output{15,2} = 'atn ( (("TrackWidth"/2)-20in)/11in)';

output{16,1} = 'Theta';
output{16,2} = 'atn (5.5in /(("TrackWidth"/2)-10in) )';

output{17,1} = 'Omega';
output{17,2} = 'atn (9in /(("TrackWidth"/2)-10in) )';

%% Write to file
% Determine user
switch getenv('username')
    case ''
        % John - Ubuntu
        fname = 'Equations.txt';
    otherwise
        fname = 'Z:\2017\MCG4322A\Digital Files\BAJA2B\Solidworks\Equations.txt';
end

%%
% Open the file
try
    efid = fopen(fname,'w+');
catch
    error('Cannot write to %s\n',fname);
end

%%
% Print values to file
for k = 1:17
    fprintf(efid,'"%s" = %s\n',output{k,1},output{k,2});
end

%%
% Close the file
try
    fclose(efid);
    fprintf('Successfully wrote file %s\n',fname);
catch
    error('Not able to close file %s\n',fname);
end