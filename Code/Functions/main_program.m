function [event_list,cdm_list,event_detection,action_list,total_cost] = main_program (epoch, end_date , eos, space_cat, conj_box , moid_distance,accelerator,space_cat_ids)
%% Input check
if nargin<4
    error('Insufficient number of inputs.');
elseif nargin==4
    conj_box=[2,25,25];                   %[km,km,km] in order, RSW directions
    moid_distance=200;                    %[km]
    accelerator=0;
elseif nargin==5
    moid_distance=200;                    %[km]
    accelerator=0;
elseif nargin==6
    accelerator=0;
end

%% Pre-process
timestep=15;                              %[s]
space_cat = Space_catalogue_reset_epoch (space_cat,epoch);
no_days=date2mjd2000(end_date)-date2mjd2000(epoch);
%% Propagation and event detection
event_list=Conjunction_event;
for eos_sat=1:length(eos)
    event_list = Event_detection (eos(eos_sat),space_cat,no_days,timestep,conj_box,moid_distance,event_list);
end
%% Event list to matrix conversion
%event_matrix = list2matrix (event_list,space_cat,space_cat_ids,accelerator);
event_matrix = list2matrix (event_list);
disp('Event list converted to conjunction event matrix');
%% Saving 
save('Data\Intermediate_9Jan.mat');

%% Loading
%load('Data\Temp_modular_before_CARAPROCESS.mat');

%%
[cdm_list,event_detection,action_list,total_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos);
