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