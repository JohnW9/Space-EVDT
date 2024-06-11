% FUNCTION NAME:
%   Closest_opp_position_delta_time
%
% DESCRIPTION:
%   Computes the exact time the spacecraft will perform a maneuver, given
%   a target maneuver time (usually 24h or 48h)
%   
% INPUT:
%   epoch_sec: the time difference between TCA and the target maneuver time
%   [s]
%   oe_2: orbital elements at the position opposite to TCA
%   oe_1: orbital elements at TCA
%
% OUTPUT:
%   closest_delta_time: closest time to target maneuver time where the
%   spacecraft is also at the position opposite to TCA
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/6/2024 - Jonathan Wei
%       * Header added
%
%

function closest_delta_time = Closest_opp_position_delta_time(epoch_sec,oe_2,oe_1)
mu = 3.986004418 * 1e14;

E1 = f2E(oe_1.anom,oe_1.e); %eccentric anomaly at TCA
E2 = f2E(oe_2.anom,oe_2.e); %eccentric anomaly at position opposite to TCA
delta_t = sqrt((oe_1.a*1e3)^3/mu)*(E2-E1 - oe_1.e*sin(E2-E1)); %time difference for one orbit
nb_increments = round(epoch_sec/delta_t); % nb of orbits to be as close as possible to epoch_sec
closest_delta_time = nb_increments * delta_t;

end