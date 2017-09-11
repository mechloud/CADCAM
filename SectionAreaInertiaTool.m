%% SECTIONAREAINERTIATOOL
% SECTIONAREAINERTIATOOL Takes a nx2 matrix with the OD in the first column
% and ID in the second column and calculates the section area and moment of
% inertia in imperial and metric units.
%
% Used in the literature review report.
%
% Written by Jonathan Charbonneau
% 7199186
% 11/09/2017
function SectionAreaInertiaTool(dims)

if nargin < 1
    dims = [1.050 0.824;
            1.315 1.049;
            1.660 1.380;
            1.000 0.750;
            1.250 1.000;
            1.500 1.250;];
end

imp_area = pi/4 * (dims(:,1).^2 - dims(:,2).^2);
imp_inertia = pi/64 * (dims(:,1).^4 - dims(:,2).^2);

% Convert to metric and recalculate
dims = dims*25.4;

met_area = pi/4 * (dims(:,1).^2 - dims(:,2).^2);
met_inertia = pi/64 * (dims(:,1).^4 - dims(:,2).^2);

OD = dims(:,1);
ID = dims(:,2);

T = table(OD,ID,imp_area,met_area,imp_inertia,met_inertia)




end