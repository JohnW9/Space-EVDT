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

[Kep] = Cart2Kep([r1,v1],'True','Rad'); % conversion to orbital elements

a = Kep(1);
e = Kep(2);
i = Kep(3);
Omega = Kep(4);
w = Kep(5);
anom = Kep(6);

new_anom = mod(anom + pi, 2*pi); % new true anomaly angle at the opposite side on the orbit
E = 2 * atan(sqrt((1 - e) / (1 + e)) * tan(new_anom / 2)); % eccentric anomaly
M = E - e* sin(E); % mean anomaly
[r2,v2] = Kep2Cart([a,e,i,Omega,w,M]); % conversion back to Cartesian
v2 = v2 + delta_v*(v2/norm(v2)); % apply delta v

%compute new orbital parameters
[a,e,i,Omega,w,anom] = Cart2Kep([r2,v2],'True','Rad');
new_orbital_elements = struct('a', a, 'e', e, 'i', i, 'Omega', Omega, 'w', w, 'anom', anom);

%propagate forward again

epoch_sec = current_conjunction(chosen_cdm_index).TCA_sec - time_of_maneuver;
epoch = s2date(epoch_sec);
no_days = time_of_maneuver/(60*60*24); % Simulation number of days after epoch [days]
event_list = [];
Event_detection_MTS_CDM(new_orbital_elements,current_conjunction(chosen_cdm_index),epoch,no_days,event_list);


end

