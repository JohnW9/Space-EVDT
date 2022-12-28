%% EVENT DETECTION
% Deterministic

function event_list = Event_detection (Satellite,space_cat_reset,no_days,timestep,conj_box,moid_distance,event_list)
%% Nargin inputs

if nargin<3
    error('Minimum input is the Primary satellite, and the space catalogue, and the number of days after epoch for event detection.');
elseif nargin == 3
    conj_box=[50,50,50];
    moid_distance=100;
    timestep=15; %[s]
    event_list=Conjunction_event;
elseif nargin == 4
    conj_box=[50,50,50];
    moid_distance=100;
    event_list=Conjunction_event;
elseif nargin == 5
    moid_distance=100;
    event_list=Conjunction_event;
elseif nargin == 6
    event_list=Conjunction_event;
end

box_multiplier=ceil(timestep/3); %% Experimental relation


%% Finding primary sat in space catalogue and initial relevant space objects

space_cat_ids=zeros(1,length(space_cat_reset));
for j=1:length(space_cat_reset)
    space_cat_ids(j)=space_cat_reset(j).id;
end

%finding the index in the space catalogue
for i=1:length(space_cat_reset)
    if strcmp(Satellite.name,space_cat_reset(i).name)
        sat_index=i;
        break;
    end
end

if isempty(sat_index)
    error('Satellite name not found in the space catalogue')
end

Primary=space_cat_reset(sat_index);

Relevant_space_objects= MOID(Primary,moid_distance,space_cat_reset);


%% Big Loop for avoiding ram overflow

initial_date=space_cat_reset(1).epoch;

cycle_days=0.5;
time_cycle = initial_date:cycle_days:initial_date+no_days;
relevent_SO_frequency=5; % Renews the relevant space objects every 5 days

if time_cycle(end)~=initial_date+no_days
    time_cycle(end+1)=initial_date+no_days;
end


for cycle=1:length(time_cycle)-1
    
    initial_date=mjd20002date(time_cycle(cycle));
    final_date=mjd20002date(time_cycle(cycle+1));
    
    Primary = Space_catalogue_reset_epoch (Primary,initial_date);

    if rem(cycle,ceil(relevent_SO_frequency/cycle_days))==0 && cycle~=1
        space_cat_reset = Space_catalogue_reset_epoch (space_cat_reset,initial_date);
        Relevant_space_objects= MOID(Primary,moid_distance,space_cat_reset);
    end

    Relevant_space_objects = Space_catalogue_reset_epoch (Relevant_space_objects,initial_date);
    Propagated_primary = main_propagator (Primary,final_date,timestep,1);
    Propagated_Relevant_space_objects  = main_propagator (Relevant_space_objects,final_date,timestep,1);
    event_list = conj_assess (Propagated_primary, Propagated_Relevant_space_objects,conj_box,event_list,space_cat_reset,space_cat_ids,1,box_multiplier);
    clear Propagated_primary;
    clear Propagated_Relevant_space_objects;
end



