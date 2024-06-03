% FUNCTION NAME:
%   plot_tom_Pc_tradespace
%
% DESCRIPTION:
% 
% INPUT:
%
% OUTPUT:
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   31/5/2024 - Jonathan Wei
%       * Header added


function plot_tom_Pc_tradespace(nb_of_maneuver_list_total,tom_list,red_Pc_list)

legend_list = cell(1,length(nb_of_maneuver_list_total));

figure;
    for i = 1:length(nb_of_maneuver_list_total)
        plot(tom_list/3600,nb_of_maneuver_list_total{i}, '-o', 'LineWidth',2,'MarkerSize',8);
        hold on;
            xlabel('time before TCA [h]');
            ylabel('number of maneuvers');
            grid on;
            set(gca, 'XDir', 'reverse');
            legend_list{i} = 'Pc ' + string(red_Pc_list(i)); 
            %legend('Pc ' + string(red_Pc_list(i)));
    end
    legend(legend_list);

    hold off;
end