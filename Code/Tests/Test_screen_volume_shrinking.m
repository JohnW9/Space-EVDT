%%Test
screening_volumes = {[0.4 25 25],[0.4 12 12],[0.4 2 2],[0.5 5 5]};
no_conj = zeros(1,length(screening_volumes)+1);
no_conj(1) = length(event_list);
for i=1:length(screening_volumes)
    new_event_list = screening_vol_contractor (event_list,1,screening_volumes{i},space_cat,space_cat_ids);
    no_conj(i+1)=length(new_event_list);
end
%%
set(groot,'defaultTextInterpreter','latex'); 
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
mean_conjs=ceil(no_conj/3);
bar (1:5,mean_conjs);
text(1:length(mean_conjs),mean_conjs,num2str(mean_conjs'),'vert','bottom','horiz','center'); 
box off
%ylim([0 400]);
xticks([1:5]);
%yticks([5,16,34,87,110,349]);
xticklabels({'[2x25x25]','[0.4x25x25]','[0.4x12x12]','[0.4x2x2]','[0.5x5x5]'});
xtickangle(-30);
xlabel('Screening volume dimensions in RIC (Ellipsoid) [km]')
ylabel('Number of conjunctions per satellite')
grid on;
w=10;
h=10;
figure_dimensions = [0 0 w h]; 
filename = "..\Data\" + "No of Conjunctions per screen vol"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500');