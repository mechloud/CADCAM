%% BoltTool
% BOLTTOOL Takes a struct input and calculates applicable stresses for
% semi-permanent fasteners
function bdia = BoltTool(b,n)

%%
% If the number of input arguments is less than 2, declare defaults. This
% is used for debugging and testing.
if nargin < 2
   b = struct('F',1500,...    % Shearing Force in N
              't',6.08,...    % Thickness of member
              'mxA',240,...   % Cross sectional area of weakeast connected member
              'SyM',250);     % Yield Strength of weakest member
   n = 2.0;
end

sizes = load('Bolt_Sizes.mat');
bolt_size = sizes.Bolt_Sizes(:,1);
k = 1; %counter
blength = 63.5;

nbB = 0;
ntau = 0;
nbend = 0;

while (nbB < n) || (ntau < n) || (nbend < n)
bdia = bolt_size(k);    
%% Pure Shear Failure Mode
% Find cross sectional area of bolt
xA = (pi/4)*bdia^2; 

%%
% Determine shear stress
% From Equation \ref{eq:pureshear}
tau = b.F/xA;

%% Tensile Failure of Member
% Determine tensile stress of member using cross-sectional area of attached
% member/plate with area of bolt substracted.
% From Equation \ref{eq:tension}
sigmaM = b.F/b.mxA;

%% Crushing (Bearing Failure) of Bolt or Member
% Determine bearing stress in bolt
% From Equation \ref{eq:bearing}
bearing_sigmaB = -b.F/(bdia*b.t);

%%
% Determine bearing stress in member
% From Equation \ref{eq:bearing}
bearing_sigmaM = -b.F/(bdia*b.t);

%% Safety Factors
% Calculate safety factor for tensile failure of member
% From Equation \ref{eq:ntension}
nMemTensile = b.SyM/sigmaM;

%%
% Calculate safety factor for bearing load in member
% From Equation \ref{eq:nbearing}
nMemBearing = b.SyM/bearing_sigmaM;

%%
% Declare Proof Loads for Grade 4.8 Bolts
Sp = 310;
% From Equation \ref{eq:nbearing}
nbB = b.SyM/abs(bearing_sigmaB);
% From Equation \ref{eq:nshear}
ntau = Sp/tau;

%%
% Bending Stress
% From Equation \ref{eq:moment}
Mmax=(blength*b.F)/4;
% From Equation \ref{eq:bend}
sigmaB=(Mmax*(bdia/2))/((pi*bdia^4)/64);
% From Equation \ref{eq:nbend}
nbend = Sp/sigmaB;

%%
k = k + 1;
end

end % End function

