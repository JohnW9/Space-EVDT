% FUNCTION NAME:
%   choose_maneuver_cdm
%
% DESCRIPTION:
%   This function chooses the CDM to consider for a maneuver in a list of
%   CDMs of the same conjunction. Specifically, it will choose the one just
%   before the chosen maneuver time
%
% INPUT:
%
%
% OUTPUT:
%
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   30/5/2024 - Jonathan Wei
%       * Header added
%
%

function chosen_cdm_index = choose_maneuver_cdm(current_conjunction,time_of_maneuver)
  for current_cdm_index = 1:length(current_conjunction)
            if current_conjunction(current_cdm_index).Creation_time_sec > current_conjunction(current_cdm_index).TCA_sec-time_of_maneuver
                chosen_cdm_index = current_cdm_index;
                break;
            elseif current_cdm_index == length(current_conjunction) % if no cdm is within chosen time range
                chosen_cdm_index = current_cdm_index; % choose last cdm available
            end
  end
end