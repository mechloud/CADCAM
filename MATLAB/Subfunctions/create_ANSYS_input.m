function create_ANSYS_input(nodes,elements,POD,PWT,SOD,SWT,meshsize)

if nargin < 6
    filename = '/home/jchar199/Documents/MCG4102/project/vire-labrosse/Tables.xlsx';
    %%
    % Read Excel Spreadsheet
    [nodes,~,~] = xlsread(filename,'Nodal - 2D');
    [elements,~,~] = xlsread(filename, 'Connectivity - 2D');
    
    POD = 25;
    PWT = 3;
    SOD = 25;
    SWT = 0.9;
    meshsize = 1;
end

%%
% Get the size of the nodes and elements vectors
[nnodes,~] = size(nodes);
[nelements,~] = size(elements);

%%
% Open a file for writing the ANSYS input code
output_filename = 'ansys_input.txt';
fid = fopen(output_filename,'w+');

%% Pre-Processing
% Create keypoints
fprintf(fid,'/PREP7\n! Create nodes \n');
for k = 1:nnodes
    fprintf(fid,'K,%i,%.1f,%.1f,%.1f\n',k,nodes(k,2),nodes(k,3),nodes(k,4));
end

%%
% Create lines between nodes
fprintf(fid,'\n! Create lines between nodes');
for k = 1:nelements
    fprintf(fid,'LSTR,%i,%i\n',elements(k,2),elements(k,3));
end

%%
% Declare Element Type and Section information
fprintf(fid,'\n! Declare Element Type\nET,1,BEAM188\n');
fprintf(fid,'\n! Set Section Information\n');
fprintf(fid,['\nSECTYPE,1,BEAM,CTUBE,Primary\n',...
    'SECDATA,%.1f,%.1f,%i\n'],POD-2*PWT,POD,12);
fprintf(fid,['\nSECTYPE,2,BEAM,CTUBE,Secondary\n',...
    'SECDATA,%.1f,%.1f,%i\n'],SOD-2*SWT,SOD,12);

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
fprintf(fid,'\n! Apply constraints\n');
fprintf(fid,'DK,1,,0,,0,ALL\nDK,5,UZ,0,,0\n');

fprintf(fid,'\n! Apply loads\n');
fprintf(fid,'FK,2,FZ,-100000\nFK,3,FZ,-100000\nFK,4,FZ,-100000\n');

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