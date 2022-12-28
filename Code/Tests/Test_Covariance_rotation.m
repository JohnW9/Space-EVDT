% Covariance rotation test
clc;
clear;

addpath('..\Functions\');
addpath('..\Functions\NASA\');
addpath('..\Data\');
addpath('..\Time_conversion\');

r=[4000;-6000;8000];
v=[0.1;0.6;-6];

e_r = 0.001; % Error in R direction position [km]
e_s = 0.001; % Error in S direction position [km]
e_w = 0.001; % Error in W direction position [km]
e_vr= 0.0001; % Error in R direction velocity [km/s]
e_vs= 0.0001; % Error in R direction velocity [km/s]
e_vw= 0.0001; % Error in R direction velocity [km/s]

P0_rsw = diag([e_r^2 e_s^2 e_w^2 e_vr^2 e_vs^2 e_vw^2]);

% Mine based on Chen
[T1_rsw2eci,~] = ECI2RSW(r,v); % Notations taken from chen's book
J1_rsw2eci=[T1_rsw2eci zeros(3);zeros(3) T1_rsw2eci];
P0_eci = J1_rsw2eci * P0_rsw * J1_rsw2eci';

% Method 2 by NASA
P0_eci_2 = RIC2ECI(P0_rsw,r,v);

error=P0_eci-P0_eci_2;