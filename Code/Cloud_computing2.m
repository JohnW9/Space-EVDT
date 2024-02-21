% SCRIPT NAME:
%   Cloud_computing2.m
%
% DESCRIPTION:
%   This script is for finding monthly conjuntion events for NASA EOS satellites by using monthly space 
%   catalogs. The space catalog is prepared beforehand with each cell containing the space catalog from 
%   the first few days of a month. the monthly space catalog spans from january of 2006 till end of 2010 
%   (containing 60 months). The output is a list of monthly total number of conjunctions for landsat7, Terra, 
%   and Aqua from Jan 2006 till end of 2010. Time consuming computation. Use cloud computing. AND do not forget
%   to save the workspace afterwards.
%
% INPUT:
%   "long_catalog.mat" file = [60x1 space catalog] A list Contains the space catalogs downloaded from the 
%                             first 5 days of each month from Jan 2006 to Dec 2010.  
%   
%
% OUTPUT:
%   "list_monthly_2006to2010.mat" file = A data file containing:
%       - list_monthly_events = [60x1 cell Conjunction_event] list of total number of conjunction events per month 
%                               for the combination of landsat 7, terra, and aqua
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   20/2/2024 - Sina Es haghi
%       * added the description
%

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

%% Total number of conjunctions detected for 3 NASA satellites per month from 2006 to 2010
temp_epoch = start_date;
total_waitbar = waitbar(0,['Processing... 0/' num2str(no_sims) ' complete']);
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
    waitbar(i/no_sims,total_waitbar,['Processing... ' num2str(i) '/' num2str(no_sims) ' complete']);
end
close(total_waitbar);
%% Saving

clear space_catalog_list
%save("Monthly_conj_events_eos_2006_2010.mat");

%save("list_monthly_2006to2010.mat");   % Uncomment this one if you wanna save the workspace after the end

disp("Script completed")
toc

