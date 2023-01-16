function FinalPlot (epoch, end_date,cdm_rep_list,w,h)
if nargin>3
    saver=1;
else
    saver=0;
end

GetConfig;
global config;

% set(groot,'defaultTextInterpreter','latex'); 
% set(groot,'defaultAxesTickLabelInterpreter','latex');  
% set(groot,'defaulttextinterpreter','latex');
% set(groot,'defaultLegendInterpreter','latex');

figure()
tiledlayout(1, 1, 'TileSpacing','Compact','Padding','Compact');
nexttile;
hold on;
title("Probability of collision over time");

% The regions
X=[date2mjd2000(epoch) date2mjd2000(epoch) date2mjd2000(end_date) date2mjd2000(end_date)];
Y_green=[config.yellow_event_Pc*1e-4 config.yellow_event_Pc config.yellow_event_Pc config.yellow_event_Pc*1e-4];
Y_yellow=[config.yellow_event_Pc config.red_event_Pc config.red_event_Pc config.yellow_event_Pc];
Y_red=[config.red_event_Pc config.red_event_Pc*1e2 config.red_event_Pc*1e2 config.red_event_Pc];
green=fill(X,Y_green,'r','FaceColor',"#77AC30",'FaceAlpha',0.1,'EdgeColor','none');
yellow=fill(X,Y_yellow,'r','FaceColor',	"#EDB120",'FaceAlpha',0.1,'EdgeColor','none');
red=fill(X,Y_red,'r','FaceColor',"#A2142F",'FaceAlpha',0.1,'EdgeColor','none');


yr=yline(config.red_event_Pc,'r','LineWidth',2);
yy=yline(config.yellow_event_Pc,'Color',"#EDB120",'LineWidth',2);
for k=1:1:size(cdm_rep_list,2)
    time_series=[];
    Pc_series=[];
    for v=5:(cdm_rep_list{4,k}+4)
        time_series(end+1)=date2mjd2000(cdm_rep_list{v,k}.creation_date);
        Pc_series(end+1)=cdm_rep_list{v,k}.Pc;
    end
    p=plot(time_series,Pc_series,'-o');
    color=p.Color;
    detecton=plot(time_series(1),Pc_series(1),'square','LineWidth',5,'Color',color);
end
% For legend
dummy1=plot(NaN,NaN,'Color',[0 0 0],'Marker','square','LineWidth',5,'LineStyle', 'none');
dummy2=plot(NaN,NaN,'Color',[0 0 0],'Marker','o','LineWidth',1,'LineStyle', 'none');
dummy_green=fill(NaN,NaN,'r','FaceColor',"#77AC30",'FaceAlpha',0.6,'EdgeColor','none');
dummy_yellow=fill(NaN,NaN,'r','FaceColor',	"#EDB120",'FaceAlpha',0.6,'EdgeColor','none');
dummy_red=fill(NaN,NaN,'r','FaceColor',"#A2142F",'FaceAlpha',0.6,'EdgeColor','none');

xlabel('Time [MJD2000]');
ylabel('Pc');
set(gca, 'YScale', 'log');
grid on;
grid minor;
ylim([config.yellow_event_Pc*1e-3 config.red_event_Pc*1e1]);
%xlim([8410 8417]);
xlim([date2mjd2000(epoch) date2mjd2000(end_date)]);
legend([dummy_red dummy_yellow dummy_green dummy1 dummy2],{'Red event region','Yellow event region','Green event region','Event detected','CDM generated'});
figure_dimensions = [0 0 w h]; 
filename = "Data\" + "Pc over time"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
if saver==1; print(filename,'-dpng','-r500'); end