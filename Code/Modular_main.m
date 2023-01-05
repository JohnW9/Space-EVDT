%% Modular main

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
epoch = datevec(datetime('now'));     % This is in the current timezone
end_date= [2023 1 16 0 0 0];
%% NASA satellites
eos = Read_NASA_satellites;
eos = Valuing_NASA_EOS (eos);
disp('NASA satellites loaded and valued')
%% Space catalogue
space_cat = Read_Space_catalogue(1);
space_cat_ids=zeros(1,length(space_cat));
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end
%% Main program run
[event_list,cdm_list,event_detection,action_list,total_cost] = main_program (epoch, end_date , eos, space_cat, conj_box , moid_distance,0,space_cat_ids);
runtime=toc;
%% After a long run
%save("Data\Full_data_raw"); 

%% Load instead of the full run
%load("Data\Full_data_raw"); 
%% Post analysis
cdm_rep_list = CDM_rep_list (event_detection,cdm_list);
%% Plotting
figure()
hold on;
title("Probability of collision over time");
yr=yline(1e-4,'r','LineWidth',2);
yy=yline(1e-7,'Color',"#EDB120",'LineWidth',2);
for k=1:size(cdm_rep_list,2)
    time_series=[];
    Pc_series=[];
    for v=5:cdm_rep_list{4,k}
        time_series(end+1)=date2mjd2000(cdm_rep_list{v,k}.creation_date);
        Pc_series(end+1)=cdm_rep_list{v,k}.Pc;
    end
    plot(time_series,Pc_series,'-o');
end
legend([yr yy],{'Red event limit','Yellow event limit'});
xlabel('Time [MJD2000]');
ylabel('Pc');
set(gca, 'YScale', 'log');
grid on;
grid minor;
ylim([1e-10 1e-3]);
%% For the long run
%system('shutdown -s');
%% Small test
A=action_list';
B=sortrows(A,5);
sorted_action=B';