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

function action_det = Manual_process_CDM(current_conjunction,chosen_cdm_index,action_det)
config = GetConfig;

%if current_conjunction(chosen_cdm_index) > config.WRMS_high
%    action_det = "high WRMS warning";
%elseif  current_conjunction(chosen_cdm_index) < config.WRMS_low
%    action_det = "low WRMS warning"; 
%end

%MTS
%find the place at the opposite side on the orbit
r = [current_conjunction(chosen_cdm_index).X_ECI_primary,...
     current_conjunction(chosen_cdm_index).Y_ECI_primary,...
     current_conjunction(chosen_cdm_index).Z_ECI_primary];
v = [current_conjunction(chosen_cdm_index).X_ECI_DOT_primary,...
     current_conjunction(chosen_cdm_index).Y_ECI_DOT_primary,...
     current_conjunction(chosen_cdm_index).Z_ECI_DOT_primary];

[a,e,i,Omega,w,anom] = Cart2Kep([r,v],'True','Rad');
new_anom = mod(anom + pi, 2*pi);
E = 2 * atan(sqrt((1 - e) / (1 + e)) * tan(new_anom / 2)); % eccentric anomaly
M = E - e* sin(E); % mean anomaly
[r,v] = Kep2Cart([a,e,i,Omega,w,M]);

%compute new orbital parameters
%propagate forward again


end

