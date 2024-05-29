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
max_Pc = 0;
for i=1:length(conjunction)
    time_before_tca(i) = (conjunction(i).TCA_sec-conjunction(i).Creation_time_sec)/3600; 
    Pc_list(i) = conjunction(i).Pc;
    if conjunction(i).Pc > max_Pc
        max_Pc = conjunction(i).Pc;
    end
end

if max_Pc > 1e-4
    figure;
    plot(time_before_tca,Pc_list, '-o', 'LineWidth',2,'MarkerSize',8);
        xlabel('time before TCA [h]');
        ylabel('Pc');
        grid on;
        set(gca, 'XDir', 'reverse');
end

end