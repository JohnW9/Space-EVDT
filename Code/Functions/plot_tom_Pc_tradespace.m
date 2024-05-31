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


function plot_tom_Pc_tradespace(nb_of_maneuver_list,tom_list,red_Pc)

figure;
    plot(tom_list/3600,nb_of_maneuver_list, '-o', 'LineWidth',2,'MarkerSize',8);
    hold on;
        xlabel('time before TCA [h]');
        ylabel('number of maneuvers');
        grid on;
        set(gca, 'XDir', 'reverse');
        legend(string(red_Pc));
end