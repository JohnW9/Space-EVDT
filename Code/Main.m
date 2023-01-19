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
epoch = datevec(datetime('now'));     % Setting the epoch to the current time in the local timezone (Gregorian calender)
end_date= [2023 1 22 0 0 0];          % Simulation end date and time in gregorian calender
accelerator=0;

%% NASA satellites
eos = Read_NASA_satellites;
disp('NASA satellites loaded')
%% Space catalogue
space_cat = Read_Space_catalogue(1);
%% Main program run
[cdm_rep_list,event_list,cdm_list,event_detection,action_list,total_cost] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
runtime=toc;
%% Post analysis

%% After a long run
%save("Data\Final_9Jan.mat"); 
%save("Data\Final_13Jan.mat");
%save("Data\Final_15Jan.mat");
%% Load instead of the full run
%load("Data\Final_9Jan.mat"); 
%load("Data\Final_13Jan.mat");
%load("Data\Final_15Jan.mat");
%% Plotting
disp('Plotting...');
FinalPlot (epoch, end_date,cdm_rep_list,20,12)

%% For the long run
%system('shutdown -s');
%% Small test
% A=action_list';
% B=sortrows(A,5);
% sorted_action=B';