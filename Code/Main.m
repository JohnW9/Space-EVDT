%% Main script

%% Initialization
clc;
clear;


addpath('Functions\');
addpath('Functions\NASA\');
addpath('Time_conversion\');
addpath("Data\");


%% Input data from user

generation=1;                         % 0 if you want to load data and 1 if you want to generate new data
download_catalogue=0;                 % 0 if you want to load local space catalogue, and 1 if you want to download new
epoch_reset_date=[2023 1 1 0 0 0];    %[yyyy mm dd hr m s]
no_days=1;                            %[days]
timestep=15;                          %[s]
conj_box=[2,25,25];                   %[km,km,km] in order, RSW directions
moid_distance=200;                    %[km]


%% Read data

eos = Read_NASA_satellites;
disp('NASA EOS satellites read');
eos=eos(1);


space_cat = Read_Space_catalogue(download_catalogue);
disp('Space catalogue read');

%% Propagate the space catalogue to the same epoch

space_cat = Space_catalogue_reset_epoch (space_cat,epoch_reset_date);
disp('Space catalogue propagated to same epoch');

%% Deterministic event detection
if generation==1
    event_list=Conjunction_event;

    for eos_sat=1:length(eos)
        initial_length=length(event_list);
        if eos_sat==1
            initial_length=initial_length-1;
        end
        event_list = Event_detection (eos(eos_sat),space_cat,no_days,timestep,conj_box,moid_distance,event_list);
        final_length=length(event_list);
        disp([ num2str(final_length-initial_length) ,' events for ', eos(eos_sat).name , ' satellite detected'])
    end
end
%% Load data instead
if generation == 0
    %load("Data\Landsat_Final_workspace.mat");
    load("Data\temp_workspace.mat");
    disp('Events loaded');
end
%% Valuing the NASA satellites
eos = Valuing_NASA_EOS (eos);
disp('NASA satellites valuated');
%% Converting the event list to a sorted event matrix

space_cat_ids=zeros(1,length(space_cat));
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end


event_matrix=zeros(18,size(event_list,2));
temp_objects(2)=Space_object;
for l=1:size(event_list,2)
    % Takes 6 first rows
    event_matrix(1:6,l)=[event_list(l).id event_list(l).tca event_list(l).primary_id event_list(l).secondary_id event_list(l).mis_dist event_list(l).status]';
    obj1_index = find(space_cat_ids==event_matrix(3,l));
    obj2_index = find(space_cat_ids==event_matrix(4,l));
    temp_objects(1)=space_cat(obj1_index);
    temp_objects(2)=space_cat(obj2_index);
    temp_objects(1) = TwoBP_J2_analytic (temp_objects(1),event_matrix(2,l),'mjd2000');
    temp_objects(2) = TwoBP_J2_analytic (temp_objects(2),event_matrix(2,l),'mjd2000');
    % Rest of the rows
    event_matrix(7:18,l)=[temp_objects(1).a temp_objects(1).e temp_objects(1).i temp_objects(1).raan temp_objects(1).om temp_objects(1).M ...
                          temp_objects(2).a temp_objects(2).e temp_objects(2).i temp_objects(2).raan temp_objects(2).om temp_objects(2).M]';
end
% Sort events by occurance times
[~,tca_index_sort]=sort(event_matrix(2,:));
sorted_event_matrix=event_matrix(:,tca_index_sort);
sorted_event_matrix(1,:)=1:size(sorted_event_matrix,2);
event_matrix=sorted_event_matrix;
disp('Event list analyzed and sorted');

% Event list details:
% row1: Conjunction event ID number (in chronological order)
% row2: Time of Closest Approach (TCA) in [MJD2000]
% row3: Primary satellite NORAD ID
% row4: Secondary space object NORAD ID
% row5: Miss distance in [km]
% row6: Risk mitigation status (1 asserts the risk is mitigated, 0 asserts the risk is not mitigated)
% row7-12: Orbital elements of the Primary satellite at TCA in [a:km e:-- i:rad raan:rad aop:rad M:rad]
% row13-18: Orbital elements of the Secondary space object at TCA in [a:km e:-- i:rad raan:rad aop:rad M:rad]

%% Stochastic events
modified_event_matrix = Stochastic_event_matrix (event_matrix,0);
event_matrix=modified_event_matrix;
%% CDM generation

cdm_list(size(event_matrix,2))=CDM;

failed_indexer=0;
Pc_red_thres=1e-4;
Pc_yellow_thres=1e-7;
Pc_red=[0;0];
Pc_red_ind=0;
Pc_yellow=[0;0];
Pc_yellow_ind=0;
Pc_green=[0;0];
Pc_green_ind=0;

for l=1:size(event_matrix,2)
    try
        cdm_list(l)=CDM_generator (event_matrix(:,l),3,space_cat,space_cat_ids,eos); % generating CDM's 7 days before TCA
        if cdm_list(l).Pc>=Pc_red_thres
            Pc_red_ind=Pc_red_ind+1;
            Pc_red(1:2,Pc_red_ind)=[cdm_list(l).Pc;l];
        elseif cdm_list(l).Pc>=Pc_yellow_thres
            Pc_yellow_ind=Pc_yellow_ind+1;
            Pc_yellow(1:2,Pc_yellow_ind)=[cdm_list(l).Pc;l];
        else
            Pc_green_ind=Pc_green_ind+1;
            Pc_green(1:2,Pc_green_ind)=[cdm_list(l).Pc;l];
        end
    catch
        failed_indexer=failed_indexer+1; % Still have to figure out why some fail (failing is NOT due to covariance matrix)
        failed_index_list(failed_indexer)=l;
    end

end
disp('CDMs generated');

%time_of_simulation=toc;
%% Clearing up the workspace
clearvars -except eos event_matrix event_list space_cat space_cat_ids cdm_list Pc_red Pc_yellow Pc_green failed_index_list time_of_simulation
%% Save the workspace
%save('Data\Allsats_1month.mat');
%% Shutdown afterwards
%system('shutdown -s');