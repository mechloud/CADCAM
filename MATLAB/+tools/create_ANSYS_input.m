function create_ANSYS_input(log_id,type,nodes,elements,POD,PWT,SOD,SWT,md)

if nargin < 8
    warning('Not enough input arguments, default parameters will be used');
    
    log_id = 0;
    %%
    % Load the geometry
    addpath('Database');
    
    type = 'front';
    
    if ~strcmp(type,'2d')
        nodal = load('baja_3D_geometry.mat');
    else
        nodal = load('2dfea.mat');
    end
    nodes = nodal.nodes;
    elements = nodal.elements;

    POD = 25.4;
    PWT = 3.048;
    SOD = 25.4;
    SWT = 0.89;
    md = 110;
    
    
end % end nargin

%%
% Get the size of the nodes and elements vectors
[nnodes,~] = size(nodes);
[nelements,~] = size(elements);

%%
% Create filename 
if strcmp(getenv('username'),'Jonathan')
    output_filename = sprintf('C:\\Users\\Jonathan\\Documents\\UOttawa\\MCG4322 - CADCAM\\GitHub\\CADCAM\\ANSYS\\%s_ANSYS_input.txt',type);
    warning('Writing file to path on Jonathan`s computer');
else
    output_filename = sprintf('%s_ANSYS_input.txt',type);
end

fid = fopen(output_filename,'w+');


fprintf('Writing ANSYS input file for %s impact case\n',type);

%% Pre-Processing
% Create keypoints
if ~strcmp(type,'2d')
    fprintf(fid,'/TITLE, 3D Analysis of Vehicle for %s impact\n',type);
else
    fprintf(fid,'/TITLE, 2D Analysis of Vehicle for %s impact\n',type);
end

fprintf(fid,'/PREP7\n! Create nodes \n');
for k = 1:nnodes
    if strcmp(type,'2d')
        fprintf(fid,'K,%i,%.1f,%.1f,%.1f\n',k,nodes(k,2),nodes(k,3),0);
    else
        fprintf(fid,'K,%i,%.1f,%.1f,%.1f\n',k,nodes(k,2),nodes(k,3),nodes(k,4));
    end
end
if ~strcmp(type,'2d')
    %%
    % Sort array for faster processing by ANSYS
    elements = sortrows(elements,4);
    
    %%
    % Extract elements depending on material flag
    primaries = elements((elements(:,4) == 1),:);
    secondaries = elements((elements(:,4) == 2),:);
    [rp,~] = size(primaries);
    [rs,~] = size(secondaries);
    
    %%
    % Renumber the elements
    primaries(:,1) = 1:1:rp;
    secondaries(:,1) = (rp+1):1:(rs+rp);
    
    %%
    % Reconstruct elements vector
    elements = [primaries;
        secondaries];
end
%%
% Create lines between nodes
fprintf(fid,'\n! Create lines between nodes\n');
for k = 1:nelements
    fprintf(fid,'LSTR,%i,%i\n',elements(k,2),elements(k,3));
end

%%
% Declare Element Type and Section information
fprintf(fid,'\n! Declare Element Type\nET,1,BEAM188\n');
fprintf(fid,'\n! Element key options\nKEYOPT,1,3,3\n');
fprintf(fid,'\n! Set Section Information\n');
fprintf(fid,['\nSECTYPE,1,BEAM,CTUBE,Primary\n',...
    'SECDATA,%.3f,%.3f,%i\n'],(POD-2*PWT)/2,POD/2,12);
fprintf(fid,['\nSECTYPE,2,BEAM,CTUBE,Secondary\n',...
    'SECDATA,%.3f,%.3f,%i\n'],(SOD-2*SWT)/2,SOD/2,12);
% Last parameter in the last two fprintf's used to be 12

%%
% Assign Material properties
fprintf(fid,'\n! Assign Material Properties\n');
fprintf(fid,'MP,EX,1,205e3\n');
fprintf(fid,'MP,PRXY,1,0.29\n');

%%
% Assign Properties to Lines
fprintf(fid,'\n! Attribute line properties to elements\n');
if ~strcmp(type,'2d')
    fprintf(fid,['LSEL,S,LINE,,1,%i,,0\n',...
                 'LATT,1,,1,,,,1\n!\n'],rp);
    fprintf(fid,['LSEL,S,LINE,,%i,%i,,0\n',...
                 'LATT,1,,1,,,,2\n!\n'],rp+1,rs+rp);
else
    fprintf(fid,['LSEL,S,LINE,,1,%i,,0\n',...
             'LATT,1,,1,,,,1\n!\n'],nelements);
end


%%
% Select and mesh all lines
fprintf(fid,'\n! Select All Lines\nALLSELL\n');
fprintf(fid,'\n! Specifiy size on unmeshed lines\nLESIZE,ALL,6,,,,1,,,\n');
fprintf(fid,'\n! Mesh all lines\nLMESH,ALL');

%%
% Display Elements in ANSYS Mechanical APDL GUI
fprintf(fid,'\n! Display elements\n/ESHAPE,1\nEPLOT\n');

%% Solution
% Apply constraints and loads
fprintf(fid,'\n/SOLU');
switch type
    case '2d'
        % This case shouldn't happen unless this function is run by itself
        % and the nargin < 9
        disp('2D Type')
        fprintf(fid,'\n! Apply constraints\n');
        fprintf(fid,'DK,6,,0,,0,ALL\n');
        fprintf(fid,'DK,7,,0,,0,ALL\n');
        driver_weight = -md*9.81;
        fprintf(fid,'\n! Apply loads\n');
        fprintf(fid,'FK,13,FY,%.1f\n',driver_weight);
        fprintf(fid,'FK,12,FX,22875\n');
        fprintf(fid,'FK,8,FY,-255.06\n');
    case 'front'
        fprintf(fid,'\n! Apply constraints\n');
        fprintf(fid,'DK,27,UZ,0,,0\n');
        fprintf(fid,'DK,28,UZ,0,,0\n');
        fprintf(fid,'DK,8,UX,0,,0\n');
        fprintf(fid,'DK,8,UY,0,,0\n');
        fprintf(fid,'DK,8,UZ,0,,0\n');
        fprintf(fid,'DK,9,UX,0,,0\n');
        fprintf(fid,'DK,9,UY,0,,0\n');
        fprintf(fid,'DK,9,UZ,0,,0\n');
        driver_weight = -md*9.81;
        fprintf(fid,'\n! Apply loads\n');
        %%
        % Distribute mass of drivetrain between nodes 11 and 6
        fprintf(fid,'FK,6,FY,-127.53\n');
        fprintf(fid,'FK,11,FY,-127.53\n');
        %%
        % Distribute mass of driver between nodes 19 and 22
        fprintf(fid,'FK,19,FY,%.1f\n',driver_weight/2);
        fprintf(fid,'FK,22,FY,%.1f\n',driver_weight/2);
        
        %%
        % Impact Loading
        fprintf(fid,['!FK,1,FZ,-45750.0\n',...
                     '!FK,16,FZ,-45750.0\n',...
                     'FK,24,FZ,-45750.0\n',...
                     'FK,31,FZ,-45750.0\n']);
    case 'rear'
        fprintf(fid,'\n! Apply constraints\n');
        fprintf(fid,'DK,1,,0,,0,ALL\n');
        fprintf(fid,'DK,16,,0,,0,ALL\n');
        fprintf(fid,'DK,24,,0,,0,ALL\n');
        fprintf(fid,'DK,31,,0,,0,ALL\n');
        driver_weight = -md*9.81;
        fprintf(fid,'\n! Apply loads\n');
        %%
        % Distribute mass of drivetrain between nodes 11 and 6
        fprintf(fid,'FK,6,FY,-127.53\n');
        fprintf(fid,'FK,11,FY,-127.53\n');
        %%
        % Distribute mass of driver between nodes 19 and 22
        fprintf(fid,'FK,19,FY,%.1f\n',driver_weight/2);
        fprintf(fid,'FK,22,FY,%.1f\n',driver_weight/2);
        
        %%
        % Impact Loading
        fprintf(fid,['FK,8,FZ,-22875.0\n',...
                     'FK,9,FZ,-22875.0\n',...
                     'FK,27,FZ,-22875.0\n',...
                     'FK,29,FZ,-22875.0\n']);
    case 'side'
        fprintf(fid,'\n! Apply constraints\n');
        fprintf(fid,'DK,12,,0,,0,ALL\n');
        fprintf(fid,'DK,16,,0,,0,ALL\n');
        fprintf(fid,'DK,29,,0,,0,ALL\n');
        fprintf(fid,'DK,31,,0,,0,ALL\n');
        driver_weight = -md*9.81;
        fprintf(fid,'\n! Apply loads\n');
        %%
        % Distribute mass of drivetrain between nodes 11 and 6
        fprintf(fid,'FK,6,FY,-127.53\n');
        fprintf(fid,'FK,11,FY,-127.53\n');
        %%
        % Distribute mass of driver between nodes 19 and 22
        fprintf(fid,'FK,19,FY,%.1f\n',driver_weight/2);
        fprintf(fid,'FK,22,FY,%.1f\n',driver_weight/2);
        
        %%
        % Impact Loading
        fprintf(fid,'FK,26,FX,-22875.0\n');
        fprintf(fid,'FK,5,FX,-22875.0\n');
    case 'rollover'
        fprintf(fid,'\n! Apply constraints\n');
        fprintf(fid,'DK,34,UX,0,,0\n');
        fprintf(fid,'DK,34,UY,0,,0\n');
        fprintf(fid,'DK,35,ALL,0,,0\n');
        fprintf(fid,'DK,36,ALL,0,,0\n');
        fprintf(fid,'DK,37,UX,0,,0\n');
        fprintf(fid,'DK,37,UY,0,,0\n');
        driver_weight = -md*9.81;
        fprintf(fid,'\n! Apply loads\n');
        %%
        % Distribute mass of drivetrain between nodes 11 and 6
        fprintf(fid,'FK,6,FY,127.53\n');
        fprintf(fid,'FK,11,FY,127.53\n');
        %%
        % Distribute mass of driver between nodes 19 and 22
        fprintf(fid,'FK,19,FY,%.1f\n',-driver_weight/2);
        fprintf(fid,'FK,22,FY,%.1f\n',-driver_weight/2);
        
        %%
        % Impact Loading
        fprintf(fid,['FK,1,FY,22875.0\n',...
                     'FK,5,FY,22875.0\n',...
                     'FK,12,FY,22875.0\n',...
                     'FK,16,FY,22875.0\n']);             
    otherwise
        warning(['Type of Simulation not recognized,',...
                 ' no loads or displacements inserted']);
end % end switch for load case

%%
% Solve
fprintf(fid,'\n! Solve\nSOLVE\nFINISH\n');

%% Post-Processing
% Post-process
fprintf(fid,['\n! Post-Processing\n/POST1\n',...
             'ETABLE,AXIAL,SMISC,31\n',...
             'PLETAB,AXIAL,NOAV\nFINISH\n']);

%%
% Close the file
try
    fclose(fid);
    fprintf(log_id,'\nWrote ANSYS input file for %s impact case\n',type);
catch
    if log_id ~= 0
        fprintf(log_id,'\nCould not successfully write ANSYS input file\n');
    else
        fprintf('\nWrote ANSYS input file for %s impact case\n',type);
    end
end

end