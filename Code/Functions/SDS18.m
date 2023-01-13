function [state_car,P0,state_car_tca]=SDS18 (actual_stats_at_t,actual_stats_at_tca,t,tca)
% Two ways, add stochasticness at t (more realistic) then propagate word, or vice versa. I go with method 1

std=0.1; %standard deviation in orbit determination
std=0; % For now


pos=actual_stats_at_t(1:3)+normrnd(0,std,[3,1]);
state_car=[pos;actual_stats_at_t(4:6)];
if nargout==3
    state_car_tca= TwoBP_J2_analytic_car_state (state_car,tca-t);
end
% Other stochastic methods can also be used

%% Initial Covariance matrix in RSW frame
e_r = 0.01; % Error in R direction position [km]
e_s = 0.01; % Error in S direction position [km]
e_w = 0.01; % Error in W direction position [km]
e_vr= 0.001; % Error in R direction velocity [km/s]
e_vs= 0.001; % Error in R direction velocity [km/s]
e_vw= 0.001; % Error in R direction velocity [km/s]

P0 = diag([e_r^2 e_s^2 e_w^2 e_vr^2 e_vs^2 e_vw^2]); 