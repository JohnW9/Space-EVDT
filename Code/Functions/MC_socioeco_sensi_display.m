% FUNCTION NAME:
%   MC_socioeco_sensi_display
%
% DESCRIPTION:
%   This function plots the percentage taken by the socio-economic score in
%   the total score, with respect to the total number of maneuvers
%
% INPUT:
%   decision_list = (J objects) The list containing all the actions taken by the decision model [Decision_action]
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
%   16/7/2023 - Jonathan Wei
%       * Header added
%
%

function MC_socioeco_sensi_display(decision_list)

config = GetConfig;
if ~iscell(decision_list) % for the case MC = 1
        decision_list = {decision_list};
end

maneuver_decision_matrix_primary = zeros(length(decision_list),length(config.score_socioeco_prop)); % matrix temporarily storing the number of maneuvers of the primary per MC run
maneuver_decision_matrix_secondary = zeros(length(decision_list),length(config.score_socioeco_prop));

for i = 1:length(decision_list) % loop through all decision_list (due to MC)
    current_decision_list = decision_list{i};

    for j=1:length(current_decision_list) % loop through current_decision_list
        maneuver_decision_list = current_decision_list(j).maneuver_v_based;
        for k = 1:length(maneuver_decision_list) %loop through current maneuver_decision_list
            if maneuver_decision_list(k) == 1 %primary maneuvers
                maneuver_decision_matrix_primary(i,k) = maneuver_decision_matrix_primary(i,k) + 1;
            elseif maneuver_decision_list(k) == 2 %secondary maneuvers
                maneuver_decision_matrix_secondary(i,k) = maneuver_decision_matrix_secondary(i,k) + 1;
            end
        end
    end

    maneuver_decision_av_primary = mean(maneuver_decision_matrix_primary); % average over columns, such that we have the average nb of maneuvers after MC
    maneuver_decision_av_secondary = mean(maneuver_decision_matrix_secondary);

end

figure;
plot(config.score_socioeco_prop,maneuver_decision_av_primary,'o-', 'DisplayName', 'Primary', 'LineWidth', 2);
hold on;
plot(config.score_socioeco_prop,maneuver_decision_av_secondary,'x-','DisplayName','Secondary', 'LineWidth', 2);
xlabel('Socio-economic score weight'); % Label for the x-axis
ylabel('Total number of maneuvers'); % Label for the y-axis
title('Sensitivity analysis'); % Title of the plot
legend show; % Show the legend
grid on; % Adds a grid to the plot

end