% SCRIPT NAME:
%   Cloud_computing.m
%
% DESCRIPTION:
%   The script loads a list of space catalogs from 3 different years. Then finds all of the conjunction events
%   of 3 NASA EOS satellites in those 3 years (2005,2015, 2023). Afterwards, the script defines 9 arbitrary satellites
%   with different orbital characteristics (altitude and inclination), adds them to the space catalogs, and then
%   finds the conjunctions for each of those arbitrary satellites in different years. Simulations are ran for 365
%   days. But note that the space catalogs used are static and only from the first 5 days of the year.
%   it is a very time consuming simulation and is designed for cloud computing.
%
% INPUT:
%   "Space_cat_years.mat" file = [3 space catalog] A list Contains the space catalogs downloaded from the 
%                                first 5 days of the years 2005,2015, and 2023 from space-track. 
%   
%
% OUTPUT:
%   "Full_event_list.mat" file = A meta data file containing:
%       - space_cat_years = [1x3 cell space catalog] space catalogs of 2005, 2015, 2023 with added 9 arbitrary
%                           satellites to the end of each space catalog
%       - Arb_sats_list = [1x9 NASA_sat] list of all the arbitrary satellites
%       - eos = [1x3 NASA_sat] list of nasa eos satellites considered wich are Landsat7 , Terra, Aqua in order.
%       - event_list_20xx = [N Conjunction_event] list of conjunction events for all 3 nasa eos satellites in the year 20xx.
%                           !!(Note that the space catalog used is only from the first 5 days of 20xx)!!
%       - event_list_arbsats = [3x1 cell] each cell contains all the conjucntions of all arbitsats 
%                              in the years 2005,2015,2023 in order 
%                              !!(Note that the space catalog used is only from the first 5 days of 20xx)!!
%       - MOID_list_20xx = [3x1 cell] list of relevant space objects for nasa eos satellites landsat 7, terra,
%                          and Aqua, in order, in the year 20xx.
%       - MOID_list_arbsats = [9x3 cell] list of relevant space objects for arbitrary satellites. Each row represents
%                             a specific arbitsat and each column represents a year (2005,2015,2023) in order)
%
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



clc; %test
clear;
addpath('Functions/');
addpath('Functions/NASA/');
addpath('Functions/');
addpath('Time_conversion/');
addpath('Data/');

%% Loading the list of space catalogs
tic

% Save workplace (1-y 0-n)
saving = 0;  %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!change if you wanna save the workspace in the end!!!!!!!!!!!!!!

% Setting up no_simulation_days
no_days = 365;

% Loading up the Space catalogs
load('Space_cat_years.mat');
disp("Satellite Catalog Loaded")
toc

%% NASA EOS satellite event extraction

% Reading NASA EOS satellites (only 3)
eos = Read_NASA_satellites;
eos(2:3)=[];

% Running the simulation 2005
disp("Starting 2005 simulation")
epoch_2005 = [2005 1 1 0 0 0];
MOID_list_2005 = cell(length(eos),1);
event_list_2005=Conjunction_event;
for eos_sat=1:length(eos)
    [event_list_2005,MOID_list_2005{eos_sat}] = Event_detection (eos(eos_sat),space_cat_2005,epoch_2005,no_days,event_list_2005);
end
disp("Finished 2005 simulation")
toc

% Running the simulation 2015
disp("Starting 2015 simulation")
epoch_2015 = [2015 1 1 0 0 0];
MOID_list_2015 = cell(length(eos),1);
event_list_2015=Conjunction_event;
for eos_sat=1:length(eos)
    [event_list_2015,MOID_list_2015{eos_sat}] = Event_detection (eos(eos_sat),space_cat_2015,epoch_2015,no_days,event_list_2015);
end
disp("Finished 2015 simulation")
toc

% Running the simulation 2023
disp("Starting 2023 simulation")
epoch_2023 = [2023 1 1 0 0 0];
MOID_list_2023 = cell(length(eos),1);
event_list_2023=Conjunction_event;
for eos_sat=1:length(eos)
    [event_list_2023,MOID_list_2023{eos_sat}] = Event_detection (eos(eos_sat),space_cat_2023,epoch_2023,no_days,event_list_2023);
end
disp("Finished 2023 simulation")
toc

%% Arbitrary satellite data handeling

% Adding arbitrary satellite to spacecats Sat_inc_alt
Sat{1} = {'Sat-00-550',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[550+6378.14,0,deg2rad(0),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{2} = {'Sat-45-550',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[550+6378.14,0,deg2rad(45),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{3} = {'Sat-90-550',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[550+6378.14,0,deg2rad(90),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{4} = {'Sat-00-800',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[800+6378.14,0,deg2rad(0),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{5} = {'Sat-45-800',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[800+6378.14,0,deg2rad(45),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{6} = {'Sat-90-800',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[800+6378.14,0,deg2rad(90),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{7} = {'Sat-00-1000',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[1000+6378.14,0,deg2rad(0),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{8} = {'Sat-45-1000',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[1000+6378.14,0,deg2rad(45),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};
Sat{9} = {'Sat-90-1000',[2,2],100,1000,date2mjd2000([2005 1 1 0 0 0]),[1000+6378.14,0,deg2rad(90),deg2rad(0),deg2rad(0),0],'PAYLOAD','MEDIUM',10};


years = [2005 2015 2023];
space_cat_years = {space_cat_2005,space_cat_2015,space_cat_2023};

MOID_list_arbsats = cell(length(Sat),length(space_cat_years));
event_list_arbsats = cell(length(space_cat_years),1);

for i = 1:length(space_cat_years)
    for j = 1:length(Sat)
        [temp_nasa_sat,temp_space_object]=create_sat(Sat{j});
        if j == 1
            [Arb_sats_list,space_cat_years{i}] = addSat (temp_nasa_sat,temp_space_object,space_cat_years{i});
        else
            [Arb_sats_list,space_cat_years{i}] = addSat (temp_nasa_sat,temp_space_object,space_cat_years{i},Arb_sats_list);
        end
    end
    
    epoch_arbsat = [years(i) 1 1 0 0 0];

    temp_event_list = Conjunction_event;
    for l=1:length(Arb_sats_list)
        [temp_event_list,MOID_list_arbsats{l,i}] = Event_detection (Arb_sats_list(l),space_cat_years{i},epoch_arbsat,no_days,temp_event_list);
    end
    event_list_arbsats{i} = temp_event_list;
end

disp("Script completed")
toc
%% Saving the workspace in the end
if saving == 1
    save('Full_event_list.mat');
    disp("Workspace saved")
end
