function create_ANSYS_input(type,nodes,elements,POD,PWT,SOD,SWT,meshsize,md)

if nargin < 9
    warning('Not enough input arguments, default parameters will be used');
    
    %%
    % Load the geometry
    addpath('../Database');
    nodal = load('baja_3D_geometry.mat');
    nodes = nodal.nodes;
    elements = nodal.elements;
    
    type = 'front';
    
    POD = 25;
    PWT = 3;
    SOD = 25;
    SWT = 0.9;
    meshsize = 1;
    md = 110;
end

%%
% Get the size of the nodes and elements vectors
[nnodes,~] = size(nodes);
[nelements,~] = size(elements);

%%
% Open a file for writing the ANSYS input code
switch getenv('username')
    case ''
        % Empty string is returned on Ubuntu
        output_filename = 'ansys_input.txt';
    case 'Jonathan'
        output_filename = '2D_FEA_Results.txt';
    otherwise
        output_filename = 'C:/BAJA2A/ansys_input.txt';
end
fid = fopen(output_filename,'w+');

%% Pre-Processing
% Create keypoints
fprintf(fid,'/PREP7\n! Create nodes \n');
for k = 1:nnodes
    %fprintf(fid,'K,%i,%.1f,%.1f,%.1f\n',k,nodes(k,2),nodes(k,3),nodes(k,4));
    fprintf(fid,'K,%i,%.1f,%.1f,%.1f\n',k,nodes(k,2),nodes(k,3),0);
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
fprintf(fid,'\n! Set Section Information\n');
fprintf(fid,['\nSECTYPE,1,BEAM,CTUBE,Primary\n',...
    'SECDATA,%.1f,%.1f,%i\n'],POD-2*PWT,POD,1);
fprintf(fid,['\nSECTYPE,2,BEAM,CTUBE,Secondary\n',...
    'SECDATA,%.1f,%.1f,%i\n'],SOD-2*SWT,SOD,1);
% Last parameter in the last two fprintf's used to be 12

%%
% Assign Material properties
fprintf(fid,'\n! Assign Material Properties\n');
fprintf(fid,'MP,EX,1,205e3\n');
fprintf(fid,'MP,PRXY,1,0.29\n');

%%
% Assign Properties to Lines
fprintf(fid,'\n! Assign Properties to Lines\n');
for k = 1:nelements
    fprintf(fid,['LSEL,S,LINE,,%i,,,0\n',...
        'LATT,1,,1,,,,%i\n!\n'],k,elements(k,4));
end

%%
% Select and mesh all lines
fprintf(fid,'\n! Select All Lines\nALLSELL\n');
fprintf(fid,'\n! Specifiy size on unmeshed lines\nLESIZE,ALL,,,%i,,1,,,\n',meshsize');
fprintf(fid,'\n! Mesh all lines\nLMESH,ALL');

%%
% Display Elements in ANSYS Mechanical APDL GUI
fprintf(fid,'\n! Display elements\n/ESHAPE,1\nEPLOT\n');

%% Solution
% Apply constraints and loads
fprintf(fid,'\n/SOLU');

switch type
    case '2d'
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
        disp('Front Type')
        fprintf(fid,'\n! Apply constraints\n');
        fprintf(fid,'DK,27,,0,,0,ALL\n');
        fprintf(fid,'DK,28,,0,,0,ALL\n');
        fprintf(fid,'DK,8,,0,,0,ALL\n');
        fprintf(fid,'DK,9,,0,,0,ALL\n');
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
        % Apply impact load to nodes 1 and 16
        fprintf(fid,'FK,1,FZ,-11438.0\n');
        fprintf(fid,'FK,16,FZ,-11438.0\n');
    otherwise
        error('Type of simulation not recognized');
end

%%
% Solve
fprintf(fid,'\n! Solve\nSOLVE\nFINISH\n');

%% Post-Processing
% Post-process
fprintf(fid,'\n! Post-Processing\n/POST1\nETABLE,\nFINISH\n');

%%
% Close the file
fclose(fid);

end