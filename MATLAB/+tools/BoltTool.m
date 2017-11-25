%% BoltTool
% BOLTTOOL Takes a struct input and calculates applicable stresses for
% semi-permanent fasteners
function bdia = BoltTool(b,n)

%%
% If the number of input arguments is less than 2, declare defaults. This
% is used for debugging and testing.
if nargin < 2
   b = struct('F',3000,...    % Shearing Force in N
              't',6.08,...    % Thickness of member
              'mxA',240,...   % Cross sectional area of weakeast connected member
              'SyM',250);     % Yield Strength of weakest member
   n = 4.0;
end

sizes = load('Bolt_Sizes.mat');
bolt_size = sizes.Bolt_Sizes(:,1);
k = 1; %counter

nbB = 2;
ntau = 4;

while (nbB < n) || (ntau < n)
bdia = bolt_size(k);    
%% Pure Shear Failure Mode
% Find cross sectional area of bolt
xA = (pi/4)*bdia^2;

%%
% Determine shear stress
tau = b.F/xA;

%% Tensile Failure of Member
% Determine tensile stress of member using cross-sectional area of attached
% member/plate with area of bolt substracted.
sigmaM = b.F/b.mxA;

%% Crushing (Bearing Failure) of Bolt or Member
% Determine bearing stress in bolt
bearing_sigmaB = -b.F/(bdia*b.t);

%%
% Determine bearing stress in member
bearing_sigmaM = -b.F/(bdia*b.t);

%% Safety Factors
% Calculate safety factor for tensile failure of member
nMemTensile = b.SyM/sigmaM;

%%
% Calculate safety factor for bearing load in member
nMemBearing = b.SyM/bearing_sigmaM;

%%
% Declare Proof Loads for Grade 4.8 Bolts
Sp = 310;
nbB = Sp/abs(bearing_sigmaB);
ntau = Sp/tau;

k = k + 1;
end

end % End function

