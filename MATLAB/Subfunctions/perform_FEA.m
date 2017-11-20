%% perform_FEA
% PERFORM_FEA Performs the FEA for geometry specified in file
function [axial_n,buckling_n] = perform_FEA(nodes,elements,OD,WT,md)
%%
% If the number of input arguments is less than three, declare defaults.
if nargin < 4
    clc
    close all
    addpath('../Database');
    [nodes,~,~] = xlsread('2D_FEA_tables.xlsx','Nodal');
    [elements,~,~] = xlsread('2D_FEA_tables.xlsx','Connectivity');    
    OD = 25.0;
    WT = 3.0;
    md = 110;
end

%%
% Determine size of nodes and elements vectors
[nnodes,~] = size(nodes);
[nelements,~] = size(elements);

%scatter(nodes(:,2),nodes(:,3))
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
% Yield Strength for AISI 4130 Steel ($MPa$)
Sy = 435; 

%%
% Amount of unknowns per element
nunknowns = 3;

%%
% Declare an empty cell array for storing element.
preproc = num2cell(elements);

%%
% Declare an empty vector to store the lengths and direction cosines for
% later use in post-processing.
L = zeros(nelements,1);
l = zeros(nelements,1);
m = zeros(nelements,1);
  
%%
% Loop through elements vector. Find Stiffness matrices and store in
% preproc.
for k = 1:nelements
    
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
    L(k) = get_length(xi,yi,xj,yj);
    assert(L(k) > 0,'Zero Length Element %i: L = %d',k,L);
    
    %%
    % Find direction cosines
    if abs(xj-xi) <= 1.0e-6
        l(k) = 0;
    else
        l(k) = (xj-xi)/L(k);
    end
    
    if abs(yj-yi) <= 1.0e-6
        m(k) = 0;
    else
        m(k) = (yj-yi)/L(k);
    end
    
    
    %%
    % Build Rotation Matrix
    R = build_rotation_matrix(l(k),m(k));
    
    %%
    % Build Local Stiffness Matrix
    Ke_prime = build_local_stiffness_matrix(A,E,L(k),I);
    
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
for k = 1:nelements
   
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


%%
% Declare Force vector and assign known forces.
F = zeros(nunknowns*nnodes,1);
F(12*nunknowns-2) = 22875.0;
F(13*nunknowns-1) = -md*9.81; % 110 kg * g
F(8*nunknowns-1) = -26.0*9.81; % 26 kg * g

%%
% Prepare Ka and F for solution by adding a factor $\beta$ 6 to 12 orders
% of magnitude larger than the largest entry in Ka. $\beta$ is added to
% $k_{ii}$ if $u_i$ is prescribed and the RHS of the equation is changed to
% $\beta$ times the prescribed value.
beta = (10^9)*max(max(Ka));

%%
% $u_6$ and $u_7$ are equal to zero (known values), therefore:
Ka_sol = Ka;
Ka_sol(16,16) = Ka(16,16) + beta;
Ka_sol(17,17) = Ka(17,17) + beta;
Ka_sol(18,18) = Ka(18,18) + beta;

Ka_sol(19,19) = Ka(19,19) + beta;
Ka_sol(20,20) = Ka(20,20) + beta;
Ka_sol(21,21) = Ka(21,21) + beta;
%% Solve System
% The system can now be solved to find the displacement vector U.
U = Ka_sol\F;

%% Post-Processing
% Declare displacements and strains vector
epsilon = zeros(nelements,1);

%%
% Find strains $\epsilon = \frac{\delta}{L}$ where $\delta = u_j' - u_i'$
% and $u'_j = lu_j + mv_j$ and $u'_i = lu_i + mv_i$
for k = 1:nelements
   
    %%
    % Get node numbers
    ni = elements(k,2);
    nj = elements(k,3);
    
    %%
    % Find nodal displacements for those nodes
    ui = U(nunknowns*ni-2);
    vi = U(nunknowns*ni-1);
    uj = U(nunknowns*nj-2);
    vj = U(nunknowns*nj-1);
    
    %%
    % Find $u'_i$ and $u'_j$
    ui_prime = l(k)*uj + m(k)*vj;
    uj_prime = l(k)*ui + m(k)*vi;
    
    %%
    % Find $\delta$ and $\epsilon$
    delta = uj_prime -ui_prime;
    epsilon(k) = delta/L(k);
    
    %%
    % Find %\theta_i$ and $\theta_j$
    theta_i = U(nunknowns*ni);
    theta_j = U(nunknowns*nj);
    
end

%%
% Find axial stresses in elements $\sigma = E\epsilon$
sigma = E*epsilon;

%%
% Find maximum stress
max_stress = max(abs(sigma))*sign(max(sigma))
assert(max(abs(sigma)) < Sy, 'Yielding occurs in frame members');
%%
% Find minimum safety factor
axial_n = Sy/abs(max_stress);

%% Buckling Analysis
% Equivalent lengths for both ends fixed as per AISC's Manual of Steel
% Construction
Le = L*0.65;

%%
% Find critical stress $\frac{\pi^2EI}{AL_e^2}$
critical_stress = ((pi*pi*E*I)./(A*Le.*Le));
EulerBuckling = critical_stress;
JohnsonBuckling = Sy*(1-(Sy*A*Le.*Le)./(4*pi*pi*E*I));
%%
% Compare with $\frac{S_y}{2}$
Scr = zeros(length(critical_stress),1);
Scr(critical_stress <= (Sy/2)) = EulerBuckling(critical_stress <= (Sy/2));
Scr(critical_stress > (Sy/2)) = JohnsonBuckling(critical_stress > (Sy/2));

%%
% Check for buckling against previously calculated stresses
if((sigma < 0) & (abs(sigma) > Scr))
    error('Buckling occurs in frame members');
end

%%
% Calculate Buckling Safety Factor
buckling_n = min(Scr./abs(sigma));

% fprintf('Yielding Safety Factor n = %.2d\n',axial_n);
% fprintf('Buckling Safety Factor n = %.2d\n',buckling_n);

colour_plot(nodes,elements,sigma);


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

function colour_plot(nodes,elements,sigma)

[nnodes,~,~] = size(nodes);
[nelements,~,~] = size(elements);

%%
% Add z-coordinates to the 2D nodes
nodes(:,4) = zeros(nnodes,1);

%%
% Create a figure and give it a scatter plot with the nodes
figure('Name','Axial Stress');
scatter3(nodes(:,2),nodes(:,3),nodes(:,4),'*');
cmap = jet(nelements);

index = [1:nelements].';
sigma = [index sigma];
sigma = sort(sigma,'ascend');

for k = 1:nelements
   
    x = [nodes(elements(k,2),2),nodes(elements(k,3),2)];
    y = [nodes(elements(k,2),3),nodes(elements(k,3),3)];
    line(x,y,[0,0],'Color',cmap(sigma(k,1),:),'LineWidth',2.5);
    
end
view(0,90);
colorbar;
caxis([min(sigma(:,2)),max(sigma(:,2))]);
title('Axial Stress (MPa)');
xlabel('x-coordinate (mm)');
ylabel('y-coordinate (mm)');

end