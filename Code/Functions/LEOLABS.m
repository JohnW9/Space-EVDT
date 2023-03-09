% FUNCTION NAME:
%   LEOLABS
%
% DESCRIPTION:
%   Since in orbit determination, we never know the exact accurate state of the objects,
%   this function intakes the actual states of the objects, both at time t and at TCA to
%   perform a random estimation of the state. Either it will  estimate the state at time
%   t and then propagate forward to the TCA, or vice versa. This version currently uses
%   the former method and propagated the estimated state to TCA. This is the commercial
%   SSA provider and thus has higher accuracies.
%
% INPUT:
%   actual_state_at_t = [6x1] Actual cartesian state of the object at real time t [km;km;km;km/s;km/s;km/s]
%   actual_state_at_tca = [6x1] Actual cartesian state of the object at tca [km;km;km;km/s;km/s;km/s]
%   t = [1x1] Realistic observation time [mjd2000]
%   tca = [1x1] Conjunction's Time of Closest Approach [mjd2000]
%
%
% OUTPUT:
%   state_car = [6x1] Estimated state of the object in the ECI frame at time t [km;km;km;km/s;km/s;km/s]
%   P0 = [6x6]  Covariance matrix of the object at time t in RSW direction [units in km^2 and km^2/s^2]
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   The random estimation in this function uses the normal distribution variable with a
%   pre defined standard deviation in all ECI position directions.
%   The covariance matrix is a simple diagonal matrix defined in the RSW direction.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Adding header
%   13/1/2023 - Sina Es haghi
%       * Modifying the stochastic functions to the technology model
%   20/1/2023 - Sina Es haghi
%       * Modifying so that the object's estimated position is a sample in the middle of it's covariance matrix
%   08/3/2023 - Sina Es haghi
%       * Modifying so that the object's estimated velocity is a sample in the middle of it's covariance matrix
%
function [state_car,P0,state_car_tca]=LEOLABS (actual_state_at_t,actual_state_at_tca,t,tca)
global config;

P0 = config.commercial_SSA_cov;

%% Extracting the standard deviations in the RSW direction from the covariance matrix
std_r = sqrt(P0(1,1));
std_s = sqrt(P0(2,2));
std_w = sqrt(P0(3,3));
std_vr = sqrt (P0(4,4));
std_vs = sqrt (P0(5,5));
std_vw = sqrt (P0(6,6));
%% Converting the states to RSW, sampling the OD with the standard deviations, and converting back to ECI
pos=actual_state_at_t(1:3);
vel=actual_state_at_t(4:6);
[T_rsw2eci,T_eci2rsw] = ECI2RSW(pos,vel);
pos_rsw = T_eci2rsw * pos;
vel_rsw = T_eci2rsw * vel;
estimated_pos_rsw = pos_rsw + normrnd(0,std_r,[1 1])*[1;0;0] + normrnd(0,std_s,[1 1])*[0;1;0] + normrnd(0,std_w,[1 1])*[0;0;1];
estimated_vel_rsw = vel_rsw + normrnd(0,std_vr,[1 1])*[1;0;0] + normrnd(0,std_vs,[1 1])*[0;1;0] + normrnd(0,std_vw,[1 1])*[0;0;1];
pos = T_rsw2eci*estimated_pos_rsw; % Estimated position of the satellite back in the ECI frame
vel = T_rsw2eci*estimated_vel_rsw;


state_car=[pos;vel];
if nargout==3
    state_car_tca= TwoBP_J2_analytic_car_state (state_car,tca-t);
end


%% Initial Covariance matrix in RSW frame
% e_r = 0.001; % Error in R direction position [km]
% e_s = 0.001; % Error in S direction position [km]
% e_w = 0.001; % Error in W direction position [km]
% e_vr= 0.0001; % Error in R direction velocity [km/s]
% e_vs= 0.0001; % Error in R direction velocity [km/s]
% e_vw= 0.0001; % Error in R direction velocity [km/s]

