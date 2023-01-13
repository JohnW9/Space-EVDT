% FUNCTION NAME:
%   CARA_process
%
% DESCRIPTION:
%   Given an epoch and end date, this function tries to replicate how NASA CARA operates, by feeding
%   the conjunction events in a timely matter and dependent on when a conjunction is assumed to be 
%   noticed. This process containes the main components of V, D, and T model of the EVDT framework.
%   This is function is like a discrete event simulation that loops over the timespan of the simulation
%   dates and actions are taken at different discrete times.
%
% INPUT:
%   event_matrix = [5xP] Matrix containing the conjunction event details in a timely order.
%   epoch = [1x6] Simulation start date in Gregorian calender [yy mm dd hr mn sc]
%   end_date = [1x6] Simulation end date in Gregorian calender [yy mm dd hr mn sc]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   space_cat_ids = [1xM] A matrix containing the NORAD IDs of the space catalogue objects in order
%   eos = (N objects)  Primary NASA satellites under consideration for collision avoidance [NASA_sat]
%   detection_time = [1x1] Number of days before a conjunction when the conjunction event is detected 
%                          (basically the assumed realistic propagation time) [days]
%   accelerator = [1x1] This value is for the manipulating the miss distance of a conjunction at the time of 
%                       closest approach. the accelerator will decrease the miss distance with the relation of
%                       10^-(accelerator). (0 by default)
%
% OUTPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   cdm_list = (Q objects) List of all CDMs generated in the chronological order [CDM]
%   event_detection = [13xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km]'
%   action_list = [5xL] A matrix containing all the actions taken by the Decision model [--,--,--,days,--]'
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%
%
%     event_detection details:
%     row1: Conjunction event ID number (in chronological order)
%     row2: Time of detection in [MJD2000]
%     row3: Primary satellite NORAD ID
%     row4: Secondary space object NORAD ID
%     row5: Estimated Miss distance in [km]
%     row6: Number of times the cdm is generated for the event
%     row7: Next expected conjunction update [MJD2000]
%     row8: Type of SSA to use
%     row9: TCA [MJD2000]
%     row10: Mitigation status (0-not mitigated 1-mitigated -1-not mitigated and TCA passed)
%     row11: Request status (0-no special tasking request 1-commercial SSA request -1-commercial request denied by the provider)
%     row12: Last successful observation time [MJD2000]
%     row13: Real miss distance (either manipulated or not) [km]
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   The next expected conjunction update is modeled in a very simple matter, and can be improved later.
%   The minimum "Reality time step" is assumed to be 1 day.
%   Most OD updates are assumed to be done at the same time in the day instead of being distributed thruogh
%   out the day. This should be fixed.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%   12/1/2023 - Sina Es haghi
%       * Modified the event_detection matrix to include latest successful observation
%

function [cdm_list,event_detection,action_list,total_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,detection_date,accelerator)

if nargin<7
    detection_date=7;
    accelerator=0;
end


ti=date2mjd2000(epoch);
tf=date2mjd2000(end_date);

det_matrix=event_matrix(1:5,:);
det_matrix(2,:)=det_matrix(2,:)-detection_date; % Basically det_matrix is the same as event_matrix, with detection time included instead of TCA

dt_default=1; % Days

t=ti;

total_cost=0;
ind_det=0;
ind_cdm=0;

cdm_list=CDM;
action_list=[];

event_detection=zeros(13,1);
event_detection(1)=NaN;

while t<=tf %% Loops over Reality time
    
    for i=1:size(det_matrix,2) % Finds if any conjunction are detected by the real time
        % This is how the detected events are fed to the system one by one
        if det_matrix(2,i)<=t
            if isnan(event_detection(1)) || isempty(find(event_detection(1,:)==det_matrix(1,i)))
                ind_det=ind_det+1;
                event_detection(1:5,ind_det)=det_matrix(:,i);
                event_detection(6,ind_det)=0;
                event_detection(7,ind_det)=t; % Basically saying that the government SSA provider should detect the event at this time cycle
                event_detection(8,ind_det)=0;
                event_detection(9,ind_det)=event_matrix(2,i);
                event_detection(10,ind_det)=0;
                event_detection(11,ind_det)=0;
                event_detection(13,ind_det)=NaN;
            end
        end
    end

    for j=1:size(event_detection,2)
        
        
        if event_detection(10,j)~=0 % if the conjunction is mitigated or the TCA is passed, don't analyze it
            continue;
        elseif event_detection(9,j)<t % If the TCA of the event just passed and no mitigation action was carried out, change the event status to "ignored"
            event_detection(10,j)= -1;
        elseif event_detection(7,j)<=t % If the next update time is passed, do the update
            
            [actual_objects_states,event_detection(:,j),actual_objects_states_at_tca] = states_manipulator (event_detection(:,j),t,space_cat,space_cat_ids,accelerator);
            
            [event_detection(:,j),conjunction_data,cost] = Technology_model (event_detection(:,j),t,actual_objects_states,actual_objects_states_at_tca);
            if event_detection(11,j)==-1
                continue;
            end
            cdm = CDM_generator (event_detection(:,j),conjunction_data,t,space_cat,space_cat_ids,eos);
            ind_cdm=ind_cdm+1;
            cdm_list(ind_cdm)=cdm;
            total_cost=total_cost+cost;
        end

    end

    [event_detection,cdm_list,action_list]=Decision (event_detection,cdm_list,action_list,total_cost,t);

    % Find minimum dt
    min_dt=1;
    for l=1:size(event_detection,2)
        delta=event_detection(7,l)-t;
        if delta>0 && delta<min_dt
            min_dt=delta;
        end
    end
    dt=min([dt_default min_dt]);
    t=t+dt;
end

disp('done');