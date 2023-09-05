%% Data extraction script
clc;
clear;
addpath('Functions\');
addpath('Functions\NASA\');
addpath('Functions\');
addpath('Time_conversion\');
addpath("Data\");


% Save workplace (1-y 0-n)
saving = 0;

% Setting up no_simulation_days
no_days = 365;

% Loading up the Space catalogs
load("Space_cat_years.mat");

%% NASA EOS satellite event extraction

% Reading NASA EOS satellites (only 3)
eos = Read_NASA_satellites;
eos(2:3)=[];

% Running the simulation 2005
epoch_2005 = [2005 1 1 0 0 0];
MOID_list_2005 = cell(length(eos),1);
event_list_2005=Conjunction_event;
for eos_sat=1:length(eos)
    [event_list_2005,MOID_list_2005{eos_sat}] = Event_detection (eos(eos_sat),space_cat_2005,epoch_2005,no_days,event_list_2005);
end

% Running the simulation 2015
epoch_2015 = [2015 1 1 0 0 0];
MOID_list_2015 = cell(length(eos),1);
event_list_2015=Conjunction_event;
for eos_sat=1:length(eos)
    [event_list_2015,MOID_list_2015{eos_sat}] = Event_detection (eos(eos_sat),space_cat_2015,epoch_2015,no_days,event_list_2015);
end

% Running the simulation 2023
epoch_2023 = [2023 1 1 0 0 0];
MOID_list_2023 = cell(length(eos),1);
event_list_2023=Conjunction_event;
for eos_sat=1:length(eos)
    [event_list_2023,MOID_list_2023{eos_sat}] = Event_detection (eos(eos_sat),space_cat_2023,epoch_2023,no_days,event_list_2023);
end


%% Arbitrary satellite data handiling

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

%% Saving the workspace in the end

save("Full_event_list.mat");
