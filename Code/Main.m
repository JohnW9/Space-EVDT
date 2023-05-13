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
%epoch = datevec(datetime('now'));     % Setting the epoch to the current time in the local timezone (Gregorian calender)
epoch = [2023 3 15 0 0 0];
end_date= [2023 4 15 0 0 0];           % Simulation end date and time in gregorian calender
accelerator=0;                          % details to be added
global total_budget;
global config;
total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
%% NASA satellites
eos = Read_NASA_satellites;
eos (2:3) = [];
eos=eos(1);
disp('NASA satellites loaded')
%% Space catalogue
fileID=fopen("Credentials.txt");
if fileID == -1; error('Credentials.txt file, containing the space-track username and password, is missing');end
fclose(fileID);
space_cat = Read_Space_catalogue(0); % Local SC downloaded at 11:12 AM (EST) March 6th 2023
%% Main program run
[cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
runtime=toc;
%% After a long run
%save("Data\Final_28March.mat");
%save("Data\Final_28March_new_withCommercial.mat");
%% Load instead of the full run
%load("Data\Final_6March.mat");
%load("Data\Final_28March.mat");
%% Plotting
disp('Plotting...');
FinalPlot ([2023 4 20 0 0 0], [2023 4 25 0 0 0],cdm_rep_list,20,10)
%% For the long run
%system('shutdown -s');

