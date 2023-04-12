clc;
pc_max =zeros(1,length(event_list));
no_cdm_event = zeros(1,length(event_list));
for i=1:length(event_list)
    pc_max(i)=cdm_rep_list{2,i};
    no_cdm_event(i)=cdm_rep_list{4,i};
end

figure()
%yyaxis left;
hold on;
plot(pc_max,'-o');
set(gca, 'YScale', 'log');
ylim([1e-10 1e-3]);
grid on;
ylabel('Maximum Pc of the event')

% yyaxis right;
% hold on;
% plot(no_cdm_event,'-o');
% grid on;
% ylabel('Number of CDMs generated for event')
% ylim([0 26]);

xlabel('Event number');
xlim([0 350]);

w=20;
h=12;
figure_dimensions = [0 0 w h]; 
filename = "..\Data\" + "max Pc and CDMs"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500');
