function [track_width] = Rollover(log_id,track_width, turning_radius, Ks_f, Ks_r,md,gc)

if nargin < 7
    log_id = 0;
    md = 110;
    track_width = 55*25.4;
    turning_radius = 2.3;
    Ks_f = 8143.4;
    Ks_r = 17598.7;
    gc = 0.252;
end

%%
% Convert to meters
track_width = track_width/1000;
turning_radius = turning_radius/100;
gc = gc/1000;


%% Declare initial values
% Average velocity of 35 mph
velocity = 15.64;

%%
% Mass of vehicle
mv = 195.0; % [kg]

%%
% Total mass
mass = mv + md; % [kg]

%%
% Height of centre of gravity
COG_y = 1.076 + gc - 0.252;

%%
% Roll Centre height
h_r = 1.016 + gc - 0.252; 

%%
% Front and rear separation
sep_f = 1.016;
sep_r = 1.016;

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

%%
% Define gravitational acceleration
g = 9.81;

while acc/g < Ratio
    warning('Vehicle could rollover. Increasing track width');
    track_width = track_width + 0.025;
    Ratio = (track_width/(2*COG_y) * 1/(1+Roll_rate*(1-(h_r/COG_y))));
end %while loop

fprintf(log_id,'Maximum lateral acceleration %.1f g\n',acc/g);

end %function