% FUNCTION NAME:
%   plot_V_sensitivity
%
% DESCRIPTION:
%   This function plots the scale factor of the Vulnerability part of the
%   collision value (value1 and value2) with respect to the total number of
%   maneuvers
%
% INPUT:
%   decision_list = (U objects) The list containing all the actions taken by the decision model [Decision_action]
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
%   10/7/2023 - Jonathan Wei
%       * Header added
%
%

function plot_V_sensitivity(decision_list)
config = GetConfig;
if ~iscell(decision_list) % for the case MC = 1
        decision_list = {decision_list};
end
maneuver_dict_matrix = zeros(length(decision_list),length(config.v_scale_factor)); %matrix temporarily storing the maneuvers per scale factor
maneuver_dict_tot = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
for index = 1:length(config.v_scale_factor)
    maneuver_dict_tot(config.v_scale_factor(index)) = 0;
end


for i = 1:length(decision_list) % loop through all decision_list (due to MC)
    current_decision_list = decision_list{i};

    for j=1:length(current_decision_list) % loop through current_decision_list
        maneuver_dict = current_decision_list(i).maneuver_dict;
        nb_of_maneuvers = cell2mat(maneuver_dict.values);

        for k = 1:length(maneuver_dict) % loop through maneuver_dict of one [Decision action]
            %maneuver_dict_tot(config.v_scale_factor(j)) = maneuver_dict_tot(config.v_scale_factor(j)) + nb_of_maneuvers(j);
            maneuver_dict_matrix(i,k) = maneuver_dict_matrix(i,k) + nb_of_maneuvers(k);
        end
    end 
end
maneuver_dict_averaged = mean(maneuver_dict_matrix); % average over columns, such that we have the average nb of maneuvers after MC
for idx = 1:length(config.v_scale_factor)
    maneuver_dict_tot(config.v_scale_factor(idx)) = maneuver_dict_averaged(idx);
end

figure;
    plot(config.v_scale_factor, maneuver_dict_averaged, 'o-', 'LineWidth', 2);
    xlabel('Scale Factor');
    ylabel('Number of maneuvers');
    title('Vulnerability sensibility');
    grid on;

end
