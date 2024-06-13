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
mu = config.mu;
%if current_conjunction(chosen_cdm_index) > config.WRMS_high
%    action_det = "high WRMS warning";
%elseif  current_conjunction(chosen_cdm_index) < config.WRMS_low
%    action_det = "low WRMS warning"; 
%end

%% MTS

% position at the cdm close to time of maneuver
r0_primary = [current_conjunction(chosen_cdm_index).X_ECI_primary,...
     current_conjunction(chosen_cdm_index).Y_ECI_primary,...
     current_conjunction(chosen_cdm_index).Z_ECI_primary];
v0_primary = [current_conjunction(chosen_cdm_index).X_DOT_ECI_primary,...
     current_conjunction(chosen_cdm_index).Y_DOT_ECI_primary,...
     current_conjunction(chosen_cdm_index).Z_DOT_ECI_primary];

r0_secondary = [current_conjunction(chosen_cdm_index).X_ECI_secondary,...
     current_conjunction(chosen_cdm_index).Y_ECI_secondary,...
     current_conjunction(chosen_cdm_index).Z_ECI_secondary];
v0_secondary = [current_conjunction(chosen_cdm_index).X_DOT_ECI_secondary,...
     current_conjunction(chosen_cdm_index).Y_DOT_ECI_secondary,...
     current_conjunction(chosen_cdm_index).Z_DOT_ECI_secondary];


epoch_sec = current_conjunction(chosen_cdm_index).TCA_sec - current_conjunction(chosen_cdm_index).Creation_time_sec;
[r1p,v1p] = keplerUniversal(r0_primary',v0_primary',epoch_sec,mu); %position at TCA
r1 = r1p';
v1 = v1p';
[Kep1] = Cart2Kep([r1,v1],'True','Rad'); % conversion to orbital elements
oe_1 = Kep2struct(Kep1); %orbital elements at TCA

[r1p_sec,v1p_sec] = keplerUniversal(r0_secondary',v0_secondary',epoch_sec,mu);
r1_sec = r1p_sec';
v1_sec = v1p_sec';
[Kep1_sec] = Cart2Kep([r1_sec,v1_sec],'True','Rad');
oe_1_sec = Kep2struct(Kep1_sec);

%find the place at the opposite side on the orbit
oe_2 = oe_1; % orbital elements at position opposite of TCA
oe_2.anom = mod(oe_1.anom + pi, 2*pi); % new true anomaly angle at the opposite side on the orbit
E = 2 * atan(sqrt((1 - oe_1.e) / (1 + oe_1.e)) * tan(oe_2.anom / 2)); % eccentric anomaly
M = E - oe_1.e* sin(E); % mean anomaly
[Cart] = Kep2Cart([oe_1.a,oe_1.e,oe_1.i,oe_1.Omega,oe_1.w,M]); % conversion back to Cartesian
r2 = [Cart(1),Cart(2),Cart(3)]; %[km]
v2 = [Cart(4),Cart(5),Cart(6)]; %[km/s]

% apply delta v
delta_v = 0.1; %[km/s]
v3 = v2 + delta_v*(v2/norm(v2)); 

%compute new orbital parameters
[Kep2] = Cart2Kep([r2,v3],'True','Rad');
oe_3_primary = Kep2struct(Kep2); %orbital elements with applied delta v
%propagate forward again
closest_delta_time = Closest_opp_position_delta_time(time_of_maneuver,oe_2,oe_1); %compute the real time at which the s/c is at the opposite position
[r_secondary,v_secondary] = Past_position(closest_delta_time,current_conjunction(chosen_cdm_index),'secondary'); %compute position of secondary object when maneuvring
[Kep_sec] = Cart2Kep([r_secondary,v_secondary],'True','Rad');
oe_3_secondary = Kep2struct(Kep_sec);


epoch = s2date(epoch_sec);
no_days = closest_delta_time/(60*60*24); % Simulation number of days after epoch [days]
event_list = [];
%event_list = Event_Detection_MTS_CDM(oe_3_primary,oe_3_secondary,current_conjunction(chosen_cdm_index),epoch,no_days,event_list);
if ~isempty(event_list)
    disp('not empty');
end

%propagate forward to TCA again
% primary position at TCA
[rf_primaryp,vf_primaryp] = keplerUniversal(r2',v3',closest_delta_time);
rf_primary = rf_primaryp';
vf_primary = vf_primaryp';

[Kepf_primary] = Cart2Kep([rf_primary,vf_primary],'True','Rad');
oef_primary = Kep2struct(Kepf_primary);

% secondary position at TCA
[rf_secondaryp,vf_secondaryp] = keplerUniversal(r_secondary',v_secondary',closest_delta_time);
rf_secondary = rf_secondaryp';
vf_secondary = vf_secondaryp';

[Kepf_secondary] = Cart2Kep([rf_secondary,vf_secondary],'True','Rad');
oef_secondary = Kep2struct(Kepf_secondary);

%visualisation
pos_list = {r1,r2,r2,r_secondary,rf_primary,rf_secondary};
orbital_el_list = {oe_1,oe_2,oe_3_primary,oe_3_secondary,oef_primary,oef_secondary};
disp(pos_list);
disp(orbital_el_list);
plot_orbit(pos_list,orbital_el_list);

end

