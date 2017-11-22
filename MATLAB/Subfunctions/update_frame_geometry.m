%% update_frame_geometry
% UPDATE_FRAME_GEOMETRY Changes the geometry of the frame as per the user's
% requested dimensions.
function nodes = update_frame_geometry(nodal, FL,FH,FW)

%%
% Split the vector with the nodes
node_numbers = nodal(:,1);
xcoords = nodal(:,2);
ycoords = nodal(:,3);
zcoords = nodal(:,4);

%%
% Calculate the change in frame dimensions
dx = FW - 914.4;
dy = FH - 1219.2;
dz = FL - 1828.8;

n = length(node_numbers);

%%
% Loop through all nodes and make required changes
for k = 1:n
   
    if xcoords(k) < 0
        xcoords(k) = xcoords(k) - dx;
    else
        xcoords(k) = xcoords(k) + dx;
    end
    
    if ycoords(k) > 460.0
        ycoords(k) = ycoords(k) + dy;
    end
    
    if zcoords(k) > -1319.0
        zcoords(k) = zcoords(k) -dz;
    end
    
end

%%
% Reconstruct nodes vector
nodes = [node_numbers,xcoords,ycoords,zcoords];

end