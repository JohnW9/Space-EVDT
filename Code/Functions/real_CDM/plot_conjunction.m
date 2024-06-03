% FUNCTION NAME:
%   plot_conjunction
%
% DESCRIPTION:
%   This function plots a specific conjunction, given an ordered CDM list
%   of the same conjunction.
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

function plot_conjunction(conjunction)

time_before_tca = zeros(1,length(conjunction));
Pc_list = zeros(1,length(conjunction));
for i=1:length(conjunction)
    time_before_tca(i) = conjunction(i).Creat_t_to_TCA*24; 
    Pc_list(i) = conjunction(i).Pc;
end

    figure;
    plot(time_before_tca,Pc_list, '-o', 'LineWidth',2,'MarkerSize',8);
        xlabel('time before TCA [h]');
        ylabel('Pc');
        grid on;
        set(gca, 'XDir', 'reverse');
        legend(string(conjunction(1).Primary_ID));
        disp("TCA: " + string(conjunction(1).TCA));
        disp("Event nb: " + string(conjunction(1).Event_number));
        %disp("time before tca" + string(time_before_tca));
        %disp("Pc_list" + string(Pc_list));

end