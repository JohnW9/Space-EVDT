% FUNCTION NAME:
%   Manual_process_CDM
%
% DESCRIPTION:
%   This function simulates the manual process of NASA CARA for CDMs.
%
% INPUT:
%
%
% OUTPUT:
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   03/06/2024 - Jonathan Wei
%       * Header added

function action_det = Manual_process_CDM(current_conjunction,chosen_cdm_index,action_det,time_of_maneuver)
config = GetConfig;

%if current_conjunction(chosen_cdm_index) > config.WRMS_high
%    action_det = "high WRMS warning";
%elseif  current_conjunction(chosen_cdm_index) < config.WRMS_low
%    action_det = "low WRMS warning"; 
%end

%MTS
%find the place at the opposite side on the orbit
r1 = [current_conjunction(chosen_cdm_index).X_ECI_primary,...
     current_conjunction(chosen_cdm_index).Y_ECI_primary,...
     current_conjunction(chosen_cdm_index).Z_ECI_primary];
v1 = [current_conjunction(chosen_cdm_index).X_DOT_ECI_primary,...
     current_conjunction(chosen_cdm_index).Y_DOT_ECI_primary,...
     current_conjunction(chosen_cdm_index).Z_DOT_ECI_primary];

[Kep1] = Cart2Kep([r1,v1],'True','Rad'); % conversion to orbital elements

oe_1 = Kep2struct(Kep1); %orbital elements at TCA

oe_2 = oe_1; % orbital elements at position opposite of TCA
oe_2.anom = mod(oe_1.anom + pi, 2*pi); % new true anomaly angle at the opposite side on the orbit
E = 2 * atan(sqrt((1 - oe_1.e) / (1 + oe_1.e)) * tan(oe_1.anom / 2)); % eccentric anomaly
M = E - oe_1.e* sin(E); % mean anomaly
[Cart] = Kep2Cart([oe_1.a,oe_1.e,oe_1.i,oe_1.Omega,oe_1.w,M]); % conversion back to Cartesian
r2 = [Cart(1),Cart(2),Cart(3)]; %[km]
v2 = [Cart(4),Cart(5),Cart(6)]; %[km/s]

% apply delta v
delta_v = 0.0001; %[km/s]
v2 = v2 + delta_v*(v2/norm(v2)); 

%compute new orbital parameters
[Kep2] = Cart2Kep([r2,v2],'True','Rad');
oe_3 = Kep2struct(Kep2); %orbital elements with applied delta v

%propagate forward again
epoch_sec = current_conjunction(chosen_cdm_index).TCA_sec - time_of_maneuver; 
closest_delta_time_primary = Closest_opp_position_delta_time(epoch_sec,oe_2,oe_1); %compute the real time at which the s/c is at the opposite position
position_secondary = Past_position(closest_delta_time_primary,current_conjunction(chosen_cdm_index));
epoch = s2date(epoch_sec);
no_days = time_of_maneuver/(60*60*24); % Simulation number of days after epoch [days]
event_list = [];
event_list = Event_Detection_MTS_CDM(oe_3,current_conjunction(chosen_cdm_index),epoch,no_days,event_list);
if ~isempty(event_list)
    disp('not empty');

end

end

