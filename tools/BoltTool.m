%% BoltTool
% BOLTTOOL Takes a struct input and ca lculates applicable stresses for
% semi-permanent fasteners
function BoltTool(b,n)

%%
% If the number of input arguments is less than 2, declare defaults. This
% is used for debugging and testing.
if nargin < 2
   b = struct('bdia',12.7,... % Bolt Diameter in mm
              'F',1300,...    % Shearing Force in N
              't',6.35,...    % Thickness of clamped parts
              'mxA',200,...   % Cross sectional area of weakeast connected member
              'SyM',300);     % Yield Strength of weakest clamped part);
   n = 2.0;
end

%% Pure Shear Failure Mode
% Find cross sectional area of bolt
xA = (pi/4)*b.hdia^4;

%%
% Determine shear stress
tau = b.F/xA;

%% Tensile Failure of Member
% Determine tensile stress of member using cross-sectional area of attached
% member/plate with area of bolt substracted.
sigmaM = b.F/b.mxA;

%% Crushing (Bearing Failure) of Bolt or Member
% Determine bearing stress in bolt and member
% bearing_sigmaB;

Sy = [240,4.6;
      340,4.8;
      420,5.8;
      660,8.8;
      720,9.8;
      940,10.9;
      12.9,1100];

end