%% BoltTool
% BOLTTOOL Takes a struct input and calculates applicable stresses for
% semi-permanent fasteners
function BoltTool(b,n)

%%
% If the number of input arguments is less than 2, declare defaults. This
% is used for debugging and testing.
if nargin < 2
   b = struct('bdia',12.7,... % Bolt Diameter in mm
              'F',1300,...    % Shearing Force in N
              't',0.125,...    % Thickness of member
              'mxA',200,...   % Cross sectional area of weakeast connected member
              'SyM',600);     % Yield Strength of weakest member
   n = 2.0;
end

%% Pure Shear Failure Mode
% Find cross sectional area of bolt
xA = (pi/4)*b.bdia^4;

%%
% Determine shear stress
tau = b.F/b.mxA;

%% Tensile Failure of Member
% Determine tensile stress of member using cross-sectional area of attached
% member/plate with area of bolt substracted.
sigmaM = b.F/b.mxA;

%% Crushing (Bearing Failure) of Bolt or Member
% Determine bearing stress in bolt
bearing_sigmaB = -b.F/b.bdia;

%%
% Determine bearing stress in member
bearing_sigmaM = -b.F/(b.bdia*b.t);

%% Safety Factors
% Calculate safety factor for tensile failure of member
nMemTensile = b.SyM/sigmaM;

%%
% Calculate safety factor for bearing load in member
nMemBearing = b.SyM/bearing_sigmaM;

%%
% Ensure these safety factors are higher than input safety factor
assert(abs(nMemTensile) > n,'Possible Tensile Failure of Member');
assert(abs(nMemBearing) > n,'Possible Bearing Failure of Member');

%%
% Declare Proof Loads for Grade 4.8 Bolts
Sp = 310;
nbB = Sp/abs(bearing_sigmaB);
ntau = Sp/tau;

if (ntau > n) && (nbB > n)
    disp('Bolts okay!');
else
    disp('Bolts not okay...');
    fprintf('Safety Factor for shear %d\n',ntau);
    fprintf('Safety Factor for bearing %d\n',nbB);
end

end % End function

