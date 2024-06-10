
% FUNCTION NAME:
%   Event_detection_MTS_CDM
%
% DESCRIPTION:
%   The modified version of Event_detection, adapted for the re-propagation
%   in Maneuver Trade Space.
%   
%
% INPUT:
%   Satellite = (1 object) Primary NASA satellites under consideration for collision avoidance [NASA_sat]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   epoch = [1x6] Simulation start date in Gregorian calender [yy mm dd hr mn sc]
%   no_days = [1x1] Simulation number of days after epoch [days]
%   event_list = (F objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   space_cat_ids = [1xM] A matrix containing the NORAD IDs of the space catalogue objects in order
%   
% OUTPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   Relevant_object_list = [Vx1] a list of relevant space objects detected throughout the simulation time
%
% ASSUMPTIONS AND LIMITATIONS:
%   It is suggested that the timestep not be higher than 15 seconds, otherwise conjunctions may be missed.
%   Remember that number of events in event_list must increase or stay constant after the simulation (F<=P)
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%  20/05/2023 - Jonathan Wei
%           * Header added
%

function [event_list,Relevant_object_list] = Event_Detection_MTS_CDM (new_orbital_elements,current_cdm,epoch,no_days,event_list)

%global config;
config = GetConfig;
%%

if nargout == 2
    Relevant_object_list(length(space_cat)) = Space_object;
    list_length = 0;
end


%% Finding primary sat in space catalogue and initial relevant space objects
%finding the index in the space catalogue

sat_index=NaN;
for i=1:length(space_cat)
    if strcmp(cdm_list(cdm_index).id1,space_cat(i).id)
        sat_index=i;
        break;
    end
end

if isnan(sat_index)
    error('Satellite name not found in the space catalogue')
end
Primary = real_CDM2space_object(current_cdm,'Primary',new_orbital_elements);
%Primary=space_cat(sat_index);
Secondary = real_CDM2space_object(current_cdm,'Secondary');
%% Big Loop for avoiding ram overflow

initial_date=date2mjd2000(epoch);

cycle_days=config.cycle_days; % Time sections to avoid RAM overflow

%WB_conjAssess = waitbar(0,['Finding conjunctions for ' Primary.name]);
%start_timer = tic;


time_cycle = initial_date:cycle_days:initial_date+no_days;
%relevent_SO_frequency=config.relevent_SO_frequency; % Renews the relevant space objects every 5 days

%time_cycle(end+1)=initial_date+no_days;

timestep = config.timestep;

for cycle=1:length(time_cycle)-1

    initial_date=mjd20002date(time_cycle(cycle));
    final_date=mjd20002date(time_cycle(cycle+1));

    %Primary = Space_catalogue_reset_epoch (Primary,initial_date);

    % This is to renew the relevant space objects after the specified number of days
    %if rem(cycle,ceil(relevent_SO_frequency/cycle_days))==0 || cycle==1
     %   space_cat = Space_catalogue_reset_epoch (space_cat,initial_date);
     %   Relevant_space_objects= MOID(Primary,space_cat);
%{
        %% Adding to the relevant object list
        if nargout==2
            for pl = 1:length(Relevant_space_objects)
                exist = 0;
                for dh = 1:list_length
                    if Relevant_object_list(dh).id == Relevant_space_objects(pl).id
                        exist =1;
                    end
                end
                if exist == 0
                    list_length = list_length+1;
                    Relevant_object_list(list_length)=Relevant_space_objects(pl);
                end
            end
        end

    else
        Relevant_space_objects = Space_catalogue_reset_epoch (Relevant_space_objects,initial_date);
    end

%}  

        %ts = toc(start_timer);
        Propagated_primary = main_propagator(Primary,final_date,timestep,1);
        Propagated_Relevant_space_objects  = main_propagator(Secondary,final_date,timestep,1);
        % propagate primary and relevant secondary objects
        event_list = conj_assess(Propagated_primary, Propagated_Relevant_space_objects,event_list,config);
        % screen for conjunctions
        clear Propagated_primary;
        clear Propagated_Relevant_space_objects;
        %te = toc(start_timer);
        %time_remaining = ceil((length(time_cycle)-1-cycle)*(te-ts)/60); % Remaining computation time in minutes
        %waitbar(cycle/length(time_cycle),WB_conjAssess,['Finding conjunctions for ' Primary.name ', est. time: ' num2str(time_remaining) ' mins']);
     end

if config.TPF == 0
    close(WB_conjAssess);
end

if nargout == 2
    Relevant_object_list(list_length+1:end) = [];
end


