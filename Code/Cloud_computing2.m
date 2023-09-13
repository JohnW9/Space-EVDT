%% Data extraction script
clc;
clear;
addpath('Functions/');
addpath('Functions/NASA/');
addpath('Functions/');
addpath('Time_conversion/');
addpath('Data/');

tic

%% Load the monthly space catalog from 2006 to 2010
load("Data\long_catalog.mat");
disp("Satellite Catalog Loaded")
toc

%% Number of short term simulations and initialization
no_sims =  length(space_catalog_list);
list_monthly_events = cell (no_sims,1);

start_date = [2006 1 1 0 0 0];

%% Spacecrafts - Reading NASA EOS satellites (only 3)
eos = Read_NASA_satellites;
eos(2:3)=[];

%% Monthly simulation
temp_epoch = start_date;
for i = 1:no_sims
    temp_end = temp_epoch + [0 1 0 0 0 0];
    if temp_end(2)>12
        temp_end(2)=1;
        temp_end(1)=temp_end(1)+1;
    end

    no_days = date2mjd2000(temp_end)-date2mjd2000(temp_epoch);

    temp_event_list = Conjunction_event;
    temp_catalog = space_catalog_list{i};

    for eos_sat=1:length(eos)
        temp_event_list = Event_detection (eos(eos_sat),temp_catalog,temp_epoch,no_days,temp_event_list);
    end

    list_monthly_events{i}=temp_event_list;

    temp_epoch=temp_end;
end

%% Saving

save("Monthly_conj_events_eos_2006_2010.mat","list_monthly_events");

disp("Script completed")
toc