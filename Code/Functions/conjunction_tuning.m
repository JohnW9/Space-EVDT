% FUNCTION NAME:
%   conjunction_tuning
%
% DESCRIPTION:
%   This function basically takes in the states of the space objects close to the 
%   TCA (t0) and uses tuning similar to MOID to find the exact time of TCA and the
%   real miss distance. (Finding the local minimum in the distance between the two objects around time t0)
%
% INPUT:
%   state0_1 = [6x1] The cartesian state of object 1 close to TCA, at time t0 [km;km;km;km/s;km/s;km/s]
%   state0_2 = [6x1] The cartesian state of object 2 close to TCA, at time t0 [km;km;km;km/s;km/s;km/s]
%   t0 = [1x1] Time close to TCA [days]
%
% OUTPUT:
%   miss_dist = [1x1] The tuned miss distance between the two objects [km]
%   tca = [1x1] The tuned time of closest approach [mjd2000]
%
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   23/2/2023 - Sina Es haghi
%       * Initial implementation
%
function [miss_dist,tca] = conjunction_tuning (state0_1,state0_2,t0)

global config;

timestep = config.fine_prop_timestep/86400;
min_d = norm(state0_1(1:3)-state0_2(1:3));
state1 = state0_1;
state2 = state0_2;
d = min_d;
tca = t0;

while timestep >= config.superfine_prop_timestep/86400

    % Backward propagation
    state_back_1 = TwoBP_J2_analytic_car_state (state1,-timestep);
    state_back_2 = TwoBP_J2_analytic_car_state (state2,-timestep);
    d_back = norm(state_back_1(1:3)-state_back_2(1:3));

    % Forward propagation
    state_forw_1 = TwoBP_J2_analytic_car_state (state1,+timestep);
    state_forw_2 = TwoBP_J2_analytic_car_state (state2,+timestep);
    d_forw = norm(state_forw_1(1:3)-state_forw_2(1:3));

    distances = [d_back d d_forw];

    [minimum_dist,minimum_index] = min(distances);

    if minimum_index == 2 || norm(minimum_dist-d)<0.00001
        timestep = timestep * 0.1 ;
    else
        if minimum_index == 3
            d=minimum_dist;
            tca = tca + timestep;
            state1 = state_forw_1;
            state2 = state_forw_2;
        else
            d=minimum_dist;
            tca = tca - timestep;
            state1 = state_back_1;
            state2 = state_back_2;
        end
    end
end

if d>min_d
    error('Error in conjunction miss distance tuning');
end

miss_dist = d;


end