% FUNCTION NAME:
%   plot_conjunction_list
%
% DESCRIPTION:
%   This function plots manages the chosen conjunctions to plot, given a
%   list of real_CDMs
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
%   29/5/2024 - Jonathan Wei
%       * Header added
%

function plot_conjunction_list(real_CDM_list)
config = GetConfig;
sorted_conj_list = conjunction_sort(real_CDM_list);


for i=1:length(sorted_conj_list)
   chosen_cdm_index = choose_maneuver_cdm(sorted_conj_list{i},config.time_of_maneuver);
   if sorted_conj_list{i}(chosen_cdm_index).Pc > config.red_event_Pc
        plot_conjunction(sorted_conj_list{i});
   end
end 


end