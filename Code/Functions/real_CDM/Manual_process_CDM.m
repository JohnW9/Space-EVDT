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
%OD check
OD_check_CDM(current_conjunction(chosen_cdm_index),'primary')


end

