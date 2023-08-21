%% Main
% New header will be added here
clc;
clear;

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Functions\');
addpath('Time_conversion\');
addpath("Data\");
GetConfig;


%% User inputs
tic
%epoch = datevec(datetime('now'));     % Setting the epoch to the current time in the local timezone (Gregorian calender)
epoch = [2023 3 15 0 0 0];
end_date= [2023 3 25 0 0 0];           % Simulation end date and time in gregorian calender
accelerator=0;                          % details to be added
global total_budget;
global config;
total_budget = (date2mjd2000(end_date)-date2mjd2000(epoch))*config.budget_per_day;
%% NASA satellites
eos = Read_NASA_satellites;
disp('NASA satellites loaded')
%% Space catalogue
fileID=fopen("Credentials.txt");
if fileID == -1; error('Credentials.txt file, containing the space-track username and password, is missing');end
fclose(fileID);
space_cat = Read_Space_catalogue(0); % Local SC downloaded at 11:12 AM (EST) March 6th 2023
%% Additional info
if config.TPF == 1
    disp("Time prefilter method selected; Using parallel pool")
    try
        parpool;
    catch
        disp("Parallel pool already running")
    end
elseif config.TPF == 0
    delete(gcp('nocreate'));
end
%% Main program run
[cdm_rep_list,event_list,cdm_list,event_detection,total_cost,decision_list] = SpaceEVDT (epoch, end_date , eos, space_cat,accelerator);
runtime=toc;
%% After a long run
%save("Data\Final_6March.mat");
%% Load instead of the full run
%load("Data\Final_6March.mat");
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