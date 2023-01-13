%% Main
% New header will be added here
clc;
clear;

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Time_conversion\');
addpath("Data\");

tic
%% User inputs
conj_box=[2,25,25];                   %[km,km,km] in order, RSW directions
moid_distance=200;                    %[km]
epoch = datevec(datetime('now'));     % Setting the epoch to the current time in the local timezone (Gregorian calender)
end_date= [2023 1 20 0 0 0];          % Simulation end date and time in gregorian calender
accelerator=0;
%% NASA satellites
eos = Read_NASA_satellites;
eos = Valuing_NASA_EOS (eos);
disp('NASA satellites loaded and valued')
%% Space catalogue
space_cat = Read_Space_catalogue(1);
%% Main program run
[event_list,cdm_list,event_detection,action_list,total_cost] = SpaceEVDT (epoch, end_date , eos, space_cat, conj_box , moid_distance,accelerator);
runtime=toc;
%% Load instead of the full run
%load("Data\Full_data_raw"); 
%% Post analysis
cdm_rep_list = CDM_rep_list (event_detection,cdm_list);
%% After a long run
%save("Data\Final_9Jan.mat"); 
%save("Data\Final_13Jan.mat");
%% Load instead of the full run
%load("Data\Final_9Jan.mat"); 
%load("Data\Final_13Jan.mat");
%% Plotting

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
Y_green=[1e-11 1e-7 1e-7 1e-11];
Y_yellow=[1e-7 1e-4 1e-4 1e-7];
Y_red=[1e-4 1e-2 1e-2 1e-4];
green=fill(X,Y_green,'r','FaceColor',"#77AC30",'FaceAlpha',0.1,'EdgeColor','none');
yellow=fill(X,Y_yellow,'r','FaceColor',	"#EDB120",'FaceAlpha',0.1,'EdgeColor','none');
red=fill(X,Y_red,'r','FaceColor',"#A2142F",'FaceAlpha',0.1,'EdgeColor','none');


yr=yline(1e-4,'r','LineWidth',2);
yy=yline(1e-7,'Color',"#EDB120",'LineWidth',2);
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
ylim([1e-10 1e-3]);
%xlim([8410 8417]);
xlim([date2mjd2000(epoch) date2mjd2000(end_date)]);
legend([dummy_red dummy_yellow dummy_green dummy1 dummy2],{'Red event region','Yellow event region','Green event region','Event detected','CDM generated'});
figure_dimensions = [0 0 20 12]; 
filename = "Data\" + "Pc over time"; % Figures is a folder to put everything and Test is the file name
set(gcf,'PaperUnits','centimeters','PaperPosition', figure_dimensions);
print(filename,'-dpng','-r500'); 
%% For the long run
%system('shutdown -s');
%% Small test
% A=action_list';
% B=sortrows(A,5);
% sorted_action=B';