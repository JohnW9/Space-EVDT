%% Main
% New header will be added here
clc;
clear;

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Time_conversion\');
addpath("Data\");
GetConfig;


%% User inputs
tic
epoch = datevec(datetime('now'));     % Setting the epoch to the current time in the local timezone (Gregorian calender)
%epoch = [2023 1 25 0 0 0];
end_date= [2023 2 28 0 0 0];          % Simulation end date and time in gregorian calender
accelerator=0;
global total_budget;
global config;
total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
%% NASA satellites
eos = Read_NASA_satellites;
disp('NASA satellites loaded')
%% Space catalogue
space_cat = Read_Space_catalogue(1);
%% Main program run
[~,event_list,cdm_list,event_detection,action_list,total_cost,decision_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
runtime=toc;
%% Post analysis
% [~,event_list,cdm_list,event_detection,action_list,total_cost] = SpaceEVDT (epoch, [2023 1 27 12 0 0] , eos, space_cat,accelerator);
% save("Data\interim_data.mat");
% load("Data\interim_data.mat");
% [cdm_rep_list,event_list,cdm_list,event_detection,action_list,total_cost] = SpaceEVDT ([2023 1 27 12 0 0], end_date , eos, space_cat,accelerator,event_list,cdm_list,event_detection,action_list,total_cost);
%% After a long run
%save("Data\Final_9Jan.mat"); 
%save("Data\Final_13Jan.mat");
%save("Data\Final_15Jan.mat");
%save("Data\Final_31Jan.mat");
%save("Data\Final_1Feb_v2.mat");
%% Load instead of the full run
%load("Data\Final_9Jan.mat"); 
%load("Data\Final_13Jan.mat");
%load("Data\Final_15Jan.mat");
%load("Data\Final_1Feb.mat");
%load("Data\Final_1Feb_v2.mat");
%% Plotting
disp('Plotting...');
cdm_rep_list = CDM_rep_list (event_detection,cdm_list);
FinalPlot (epoch, end_date,cdm_rep_list,20,12)

%% For the long run
%system('shutdown -s');
%% Small test
% A=action_list';
% B=sortrows(A,5);
% sorted_action=B';
%% Post processing
figure()
cdm_values = zeros(1,length(cdm_list));
for i=1:length(cdm_list)
    cdm_values(i)=cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC/7000;
end
ind = 1:length(cdm_values);
scatter(ind,cdm_values);
%% Post processing
figure()
cdm_collisions = zeros(1,length(cdm_list));
for i=1:length(cdm_list)
    cdm_collisions(i)=cdm_list(i).CC;
end
ind = 1:length(cdm_collisions);
scatter(ind,cdm_collisions);