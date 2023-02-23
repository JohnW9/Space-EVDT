% FUNCTION NAME:
%   states_manipulator
%
% DESCRIPTION:
%   This program takes the basic details of the conjunction event and produces the actual
%   states of the objects at TCA. However, for analytic purposes, it can reduce the miss distance
%   and then propagate the objects back to find the states of the objects at time t (manipulated).
%
% INPUT:
%   event_column = [14x1] A matrix with one column corresponding to a conjunction,Containing important 
%                         space object informations. 
%                         [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   t = [1x1] Realistic observation time [mjd2000]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   space_cat_ids = [1xM] A matrix containing the NORAD IDs of the space catalogue objects in order
%   accelerator = [1x1] This value is for the manipulating the miss distance of a conjunction at the time of 
%                       closest approach. the accelerator will decrease the miss distance with the relation of
%                       10^-(accelerator). (0 by default)
%
%     event_column details:
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
%     row14: Real Time of Closes Approach [mjd2000]
%
% OUTPUT:
%   actual_objects_states = [12x1] Actual cartesian states of the 2 objects at real time t [units in km and km/s]
%   event_column = [14x1] A matrix with one column corresponding to the same conjunction,Containing important 
%                         space object informations. Some are modified since input. 
%                         [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   actual_objects_states_at_tca = [12x1] Actual cartesian states of the 2 objects at TCA [units in km and km/s]
%
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   12/1/2023 - Sina Es haghi
%       * Initial development
%   13/1/2023 - Sina Es haghi
%       * Header added
%
function [actual_objects_states,event_column,actual_objects_states_at_tca] = states_manipulator (event_column,t,space_cat,space_cat_ids,accelerator)
%% Finding the actual cartesian states of the objects at TCA
TCA=event_column(9);
state_car1= Actual_state (event_column(3),TCA,space_cat,space_cat_ids);
state_car2= Actual_state (event_column(4),TCA,space_cat,space_cat_ids);
%% Manipulating the distance to the order of the accelerator
current_pos_distance=state_car2(1:3)-state_car1(1:3);
new_pos_distance=current_pos_distance/10^accelerator;
state_car2(1:3)=state_car1(1:3)+new_pos_distance;
event_column(13)=norm(new_pos_distance);
%% Converting the states of TCA to time t, resulting in the Actual (and manipulated) object states at current time
time_to_tca=TCA-t;
%propagate backwards
state_f_1 = TwoBP_J2_analytic_car_state (state_car1,-time_to_tca);
state_f_2 = TwoBP_J2_analytic_car_state (state_car2,-time_to_tca);

actual_objects_states=[state_f_1;state_f_2];
if nargout==3
    actual_objects_states_at_tca=[state_car1;state_car2];
end