%% perform_FEA
% PERFORM_FEA Performs the FEA for geometry specified in file
function perform_FEA(filename,OD,WT)

%%
% If the number of input arguments is less than three, declare defaults.
if nargin < 3
    filename = "/home/jchar199/Documents/MCG4322/github/FEA/FEAtables.xlsx";
    OD = 25.4; % mm
    WT = 0.120*25.4; % mm
end

%% Pre-Processing
% Calculate Cross-Sectional Area of Tube (assuming all tubes are the same)
ID = OD - 2*WT;
A = (pi/4)*(OD^2 - ID^2);

%%
% Assign Young's Modulus to a variable. Again, assuming all members are
% from same material
E = 205e3; % 205e3 N/mm^2

%%
% Calculate moment of inertia, assuming all members are same size
I = (pi/64)*(OD^4 - ID^4);

%%
% Read Excel Spreadsheet
[nodes,~,~] = xlsread(filename,'Nodal');
[nnodes,~] = size(nodes);
[elements,~,~] = xlsread(filename, 'Connectivity');
[elements_rows,~] = size(elements);

%%
% Amount of unknowns per element
nunknowns = 3;

%%
% Declare an empty cell array for storing element
preproc = num2cell(elements);
  
%%
% Loop through elements vector. Find Stiffness matrices and store in
% preproc.
for k = 1:elements_rows
    
    %%
    % Find nodes corresponding to element k
    node_i = elements(k,2);
    node_j = elements(k,3);
    
    %%
    % Find nodal coordinates for nodes above
    xi = nodes(node_i,2);
    yi = nodes(node_i,3);
    xj = nodes(node_j,2);
    yj = nodes(node_j,3);
    
    %%
    % Get the length of the element and direction cosines
    L = get_length(xi,yi,xj,yj);
    assert(L > 0,'Zero Length Element %i: L = %d',k,L);
    
    %%
    % Find direction cosines
    if (xj-xi) <= 0
        l = 0;
    else
        l = (xj-xi)/L;
    end
    
    if (yj-yi) <= 0
        m = 0;
    else
        m = (yj-yi)/L;
    end
    
    
    %%
    % Build Rotation Matrix
    R = build_rotation_matrix(l,m);
    
    %%
    % Build Local Stiffness Matrix
    Ke_prime = build_local_stiffness_matrix(A,E,L,I);
    
    %%
    % Calculate Global Stiffness Matrix
    Ke = R.'*Ke_prime*R;
	
    %%
    % Assign matrix to cell array
    preproc{k,4} = Ke;
end

%% Assemblage
% Allocate memory for assemblage matrix
Ka = zeros(nunknowns*nnodes,nunknowns*nnodes);

%%
% Loop through preprocessing cell array and build assemblage matrix
for k = 1:elements_rows
   
    %%
    % Extract node numbers
    ni = preproc{k,2};
    nj = preproc{k,3};
    
    %%
    % Extract parts of stiffness matrices
    knini = preproc{k,4}(1:3,1:3);
    kninj = preproc{k,4}(1:3,4:6);
    knjni = preproc{k,4}(4:6,1:3);
    knjnj = preproc{k,4}(4:6,4:6);
    
    %%
    % Make indices for indexing Ka
    nix = ni*nunknowns - 2;
    njx = nj*nunknowns - 2;
    
    %%
    % Make the substitution in assemblage matrix
    Ka(nix:(nix+2),nix:(nix+2)) = Ka(nix:(nix+2),nix:(nix+2)) + knini;
    Ka(nix:(nix+2),njx:(njx+2)) = Ka(nix:(nix+2),njx:(njx+2)) + kninj;
    Ka(njx:(njx+2),nix:(nix+2)) = Ka(njx:(njx+2),nix:(nix+2)) + knjni;
    Ka(njx:(njx+2),njx:(njx+2)) = Ka(njx:(njx+2),njx:(njx+2)) + knjnj;
       
end

csvwrite('ka.csv',Ka);

end % end function

%% length
% LENGTH Returns the element length for inputs 1 (node i) and 2 (node j)
function L = get_length(x1,y1,x2,y2)
L = sqrt((x2-x1)^2 + (y2-y1)^2);
end

%% build_rotation_matrix
% BUILD_ROTATION_MATRIX Takes the direction cosines as inputs and returns
% the rotation matrix
function R = build_rotation_matrix(l,m)
R = [l m 0 0 0 0;
    -m l 0 0 0 0;
    0 0 1 0 0 0;
    0 0 0 l m 0;
    0 0 0 -m l 0;
    0 0 0 0 0 1];
end

%% build_local_stiffness_matrix
% BUILD_LOCAL_STIFFNESS_MATRIX Takes the cross-sectional area, Young's
% Modulus, length and section inertia of the element and returns the local
% stiffness matrix
function Ke = build_local_stiffness_matrix(A,E,L,I)

Ke = [(A*E)/L 0 0 -(A*E)/L 0 0;
    0 (12*E*I)/L^3 (6*E*I)/L^2 0 -(12*E*I)/L^3 (6*E*I)/L^2;
    0 (6*E*I)/L^2 (4*E*I)/L 0 -(6*E*I)/L^2 (2*E*I)/L;
    -(A*E)/L 0 0 (A*E)/L 0 0;
    0 -(12*E*I)/L^3 -(6*E*I)/L^2 0 (12*E*I)/L^3 (6*E*I)/L^2;
    0 (6*E*I)/L^2 (2*E*I)/L 0 -(6*E*I)/L^2 (4*E*I)/L];

end
