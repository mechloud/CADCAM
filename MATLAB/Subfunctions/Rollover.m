function [track_width] = Rollover(track_width, turning_radius, mass, COG_y, Ks_f, Ks_r, sep_f, sep_r)

if nargin < 8
    COG_y = 1.076;
    Ks_f = 8143.4;
    Ks_r = 17598.7;
    sep_f = 1.016;
    sep_r = 1.016;
end

%% Declare initial values
% average velocity of 35 mph
velocity = 15.64;

%%
% Roll Centre height
h_r = 1.016; 

%% 
% Find front and back roll stiffness
K_f = 0.5*Ks_f*sep_f^2;
K_r = 0.5*Ks_r*sep_r^2;

%% 
% Find roll rate
Roll_rate = (mass*9.81*h_r)/(K_f + K_r - mass*9.81*h_r);

%%
% Ratio of lateral acceleration to gravitational acceleration
Ratio = (track_width/(2*COG_y) * 1/(1+Roll_rate*(1-(h_r/COG_y))));

%% 
% finding the lateral acceleration
acc = velocity^2 / turning_radius;

while acc > Ratio*9.81
    track_width = track_width + 25.4;
    Ratio = (track_width/2) / COG_y;
end %while loop

end %function