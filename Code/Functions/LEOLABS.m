function [state_car,P0]=LEOLABS (object_id,t,space_cat,space_cat_ids)

obj1_index = find(space_cat_ids==object_id);

temp_objects(1)=space_cat(obj1_index);

temp_objects(1) = TwoBP_J2_analytic (temp_objects(1),t,'mjd2000'); %% THIS CAN BE CHANGED 

%% Orbit determination at the time t (not TCA)
state1=[temp_objects(1).a temp_objects(1).e temp_objects(1).i temp_objects(1).raan temp_objects(1).om M2f(temp_objects(1).M,temp_objects(1).e)];

state_car = par2car(state1);

%%HERE YOU CAN STOCHASTICNESS IF NEEDED

%% Initial Covariance matrix in RSW frame
e_r = 0.001; % Error in R direction position [km]
e_s = 0.001; % Error in S direction position [km]
e_w = 0.001; % Error in W direction position [km]
e_vr= 0.0001; % Error in R direction velocity [km/s]
e_vs= 0.0001; % Error in R direction velocity [km/s]
e_vw= 0.0001; % Error in R direction velocity [km/s]

P0 = diag([e_r^2 e_s^2 e_w^2 e_vr^2 e_vs^2 e_vw^2]);