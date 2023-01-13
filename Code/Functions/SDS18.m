% FUNCTION NAME:
%   SDS18
%
% DESCRIPTION:
%   Since in orbit determination, we never know the exact accurate state of the objects,
%   this function intakes the actual states of the objects, both at time t and at TCA to
%   perform a random estimation of the state. Either it will  estimate the state at time
%   t and then propagate forward to the TCA, or vice versa. This version currently uses
%   the former method and propagated the estimated state to TCA. This is the govenment
%   SSA provider and thus has less accuracies.
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
%
function [state_car,P0,state_car_tca]=SDS18 (actual_state_at_t,actual_state_at_tca,t,tca)

std=0.1; %standard deviation in orbit determination
std=0; % For now


pos=actual_state_at_t(1:3)+normrnd(0,std,[3,1]); % Estimate of the position of the object at time t
state_car=[pos;actual_state_at_t(4:6)];
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