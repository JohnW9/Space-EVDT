function state_car = Actual_state (object_id,t,space_cat,space_cat_ids)
obj_index = find(space_cat_ids==object_id);

object=space_cat(obj_index);

object = TwoBP_J2_analytic (object,t,'mjd2000');

%% Orbit determination at the time t (not TCA)
state=[object.a object.e object.i object.raan object.om M2f(object.M,object.e)];

state_car = par2car(state);