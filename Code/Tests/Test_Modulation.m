%% Testing the modular ability of the SpaceEVDT program

clc;
clear;

addpath('..\');
addpath('..\Functions\');
addpath('..\Functions\NASA\');
addpath('..\Data\');
addpath('..\Time_conversion\');

GetConfig;

%% User inputs
tic
epoch = [2023 1 1 0 0 0];
mid = [2023 1 5 0 0 0];
end_date= [2023 1 10 0 0 0];          % Simulation end date and time in gregorian calender
accelerator=0;
global total_budget;
global config;
total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
%% NASA satellites
eos = Read_NASA_satellites;
disp('NASA satellites loaded')
%% Space catalogue
space_cat = Read_Space_catalogue(0);
%% Case 1
[cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
%% Case 2
[~,event_list1,cdm_list1,event_detection1,total_cost1,decision_list1] = SpaceEVDT (epoch, mid , eos, space_cat,accelerator);
[cdm_rep_list2,event_list2,cdm_list2,event_detection2,total_cost2,decision_list2] = SpaceEVDT (mid, end_date , eos, space_cat,accelerator,event_list1,cdm_list1,decision_list1,event_detection1,total_cost1);
%% Save
save("..\Data\Test_modular_data.mat");
%% Load
load("..\Data\Test_modular_data.mat");