% FUNCTION NAME:
%   Event_detection
%
% DESCRIPTION:
%   This function first finds the relevant space objects to the EOS satellite under consideration.
%   The relevant space objects along with the NASA satellite are propagated for the number of days specified.
%   The propagation is carried out with a fixed timestep and using the analytic secular J2 propagator.
%   Since there is a chance of RAM overflowing, the program runs the event detection is sections of 
%   half days, clearing all the propagation data and only saving the conjunction event basic details.
%   
%
% INPUT:
%   Satellite = (1 object) Primary NASA satellites under consideration for collision avoidance [NASA_sat]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   no_days = [1x1] Simulation number of days after epoch [days]
%   timestep = [1x1] Propagation time step [sec]
%   conj_box = [1x3] The conjunction screening volume currently defined as a box in RSW directions [km km km]
%   moid_distance = [1x1] The minimum orbit intersection distance treshold, to find the relative 
%                         space objects from the space catalogue. [km]
%   event_list = (F objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   
% OUTPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%
% ASSUMPTIONS AND LIMITATIONS:
%   The epoch of all the space objects at input must be equal.
%   It is suggested that the timestep not be higher than 15 seconds, otherwise conjunction will be missed.
%   Remember that number of events in event_list must increase or stay constant after the simulation (F<=P)
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%

function event_list = Event_detection (Satellite,space_cat,no_days,timestep,conj_box,moid_distance,event_list,space_cat_ids)

box_multiplier=ceil(timestep/3); %% Experimental relation (Since the best timestep for conjunction screening
                                  % is in the order of 1 second, this value box multiplier value is used to 
                                  % enlarge the screening volume so even with larger timesteps, conjunctions
                                  % are not missed. The relation is completely imperical.


%% Finding primary sat in space catalogue and initial relevant space objects
%finding the index in the space catalogue
for i=1:length(space_cat)
    if strcmp(Satellite.name,space_cat(i).name)
        sat_index=i;
        break;
    end
end

if isempty(sat_index)
    error('Satellite name not found in the space catalogue')
end

Primary=space_cat(sat_index);

Relevant_space_objects= MOID(Primary,moid_distance,space_cat);


%% Big Loop for avoiding ram overflow

initial_date=space_cat(1).epoch; % Remember that all objects must have the same epoch

cycle_days=0.5; % Time sections of half days to avoid RAM overflow
time_cycle = initial_date:cycle_days:initial_date+no_days;
relevent_SO_frequency=5; % Renews the relevant space objects every 5 days

time_cycle(end+1)=initial_date+no_days;



for cycle=1:length(time_cycle)-1
    
    initial_date=mjd20002date(time_cycle(cycle));
    final_date=mjd20002date(time_cycle(cycle+1));
    
    Primary = Space_catalogue_reset_epoch (Primary,initial_date);

    % This is to renew the relevant space objects after the specified number of days
    if rem(cycle,ceil(relevent_SO_frequency/cycle_days))==0 && cycle~=1
        space_cat = Space_catalogue_reset_epoch (space_cat,initial_date);
        Relevant_space_objects= MOID(Primary,moid_distance,space_cat);
    else
        Relevant_space_objects = Space_catalogue_reset_epoch (Relevant_space_objects,initial_date);
    end

    Propagated_primary = main_propagator (Primary,final_date,timestep,1);
    Propagated_Relevant_space_objects  = main_propagator (Relevant_space_objects,final_date,timestep,1);
    event_list = conj_assess (Propagated_primary, Propagated_Relevant_space_objects,conj_box,event_list,space_cat,space_cat_ids,box_multiplier);
    clear Propagated_primary;
    clear Propagated_Relevant_space_objects;
end



