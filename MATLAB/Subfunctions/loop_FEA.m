%% Loop_FEA
% LOOP_FEA Loops to find appropriate sizes
function [OD,WT] = loop_FEA(FL,FH,md)

if nargin < 3
    FL = 1422;
    FH = 1220;
    md = 110;
    addpath('../Database');
end

%%
% Declare default safety factor
SF = 4.0;

%%
% Load nodal data
nodal = load('2dfea.mat');
nodes = nodal.nodes;
elements = nodal.elements;

%%
% Load tube size database
sizes = load('tube_sizes.mat');
OD = sizes.tube_sizes(:,1);
WT = sizes.tube_sizes(:,2);

%%
% Change frame geometry
nodes = change_frame_geometry(nodes,FL,FH);

%%
% Perform an initial FEA
[res,ASF,BSF] = perform_FEA(nodes,elements,OD(1),WT(1),md);

%%
% Increase tube size until safety factors are satisfactory;
ctr = 1;
while (ASF < SF && BSF < SF && ctr < length(OD))
    [res,ASF,BSF] = perform_FEA(nodes,elements,OD(ctr + 1),WT(ctr + 1),md);
    ctr = ctr + 1;
end

OD = OD(ctr - 1);
WT = WT(ctr - 1);
colour_plot(nodes,elements,res);
fprintf('The required primary tube size is %.1f mm OD and %.1f mm wall thickness\n',OD,WT);


end

%% change_frame_geometry
% CHANGE_FRAME_GEOMETRY Changes the size of the frame depending on the
% desired inputs. Returns nodal coordinate table.
function nodes = change_frame_geometry(nodes,FL,FH)

xcoords = nodes(:,2);
ycoords = nodes(:,3);

for k = 1:length(xcoords)
    if xcoords(k) > 890
        xcoords(k) = xcoords(k) + FL - 1422;
    end
    if ycoords(k) > 1220
        ycoords(k) = ycoords(k) + FH - 1220;
    end
end

nodes(:,2) = xcoords;
nodes(:,3) = ycoords;

end
