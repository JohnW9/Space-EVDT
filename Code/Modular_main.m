%% Modular main

clc;
clear;

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Time_conversion\');
addpath("Data\");

%% User inputs
conj_box=[2,25,25];                   %[km,km,km] in order, RSW directions
moid_distance=200;                    %[km]
epoch = datevec(datetime('now'));     % This is in the current timezone
end_date= [2023 1 15 0 0 0];
%% NASA satellites
eos = Read_NASA_satellites;
eos = Valuing_NASA_EOS (eos);
eos=eos(3);
disp('NASA satellites loaded and valued')
%% Space catalogue
space_cat = Read_Space_catalogue(1);
space_cat_ids=zeros(1,length(space_cat));
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end
%% Main program run
[event_list,cdm_list,action_list] = main_program (epoch, end_date , eos, space_cat, conj_box , moid_distance,0,space_cat_ids);


