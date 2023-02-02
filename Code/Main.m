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
end_date= [2023 2 3 0 0 0];          % Simulation end date and time in gregorian calender
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
[cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
runtime=toc;
%% After a long run
%save("Data\Final_1Feb_v2.mat");
%% Load instead of the full run
%load("Data\Final_1Feb_v2.mat");
%% Plotting
disp('Plotting...');
FinalPlot (epoch, end_date,cdm_rep_list,20,12)
%% For the long run
%system('shutdown -s');
%% Post processing (Collision value)
%{
figure()
cdm_values = zeros(1,length(cdm_list));
for i=1:length(cdm_list)
    cdm_values(i)=cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC/config.CC_normalizer;
end
ind = 1:length(cdm_values);
scatter(ind,cdm_values);
%% Post processing (Collision number of pieces)
figure()
cdm_collisions = zeros(1,length(cdm_list));
for i=1:length(cdm_list)
    cdm_collisions(i)=cdm_list(i).CC;
end
ind = 1:length(cdm_collisions);
scatter(ind,cdm_collisions);
%}