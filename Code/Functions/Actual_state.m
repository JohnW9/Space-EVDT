% FUNCTION NAME:
%   Actual_state
%
% DESCRIPTION:
%   This function takes the space object from catalogue with its own defined epoch,
%   and propagates it to the desired time t. (Using J2 analytic propagator)
%
% INPUT:
%   object_id = [1x1] NORAD ID of the space object to be propagated
%   t = [1x1] Desired propagation date [mjd2000]
%   space_cat = (M objects) Space catalogue fed to the program as the space environment [Space_object]
%   space_cat_ids = [1xM] A matrix containing the NORAD IDs of the space catalogue objects in order
%
% OUTPUT:
%   state_car = [6x1] Cartesian state of the object at time t in the ECI frame [km;km;km;km/s;km/s;km/s]
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   Considering only secular J2 effects during the propagation.
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
function state_car = Actual_state (object_id,t,space_cat,space_cat_ids)
obj_index = find(space_cat_ids==object_id);

object=space_cat(obj_index);

object = TwoBP_J2_analytic (object,t,'mjd2000');

%% Orbit determination at the time t (not TCA)
state=[object.a object.e object.i object.raan object.om M2f(object.M,object.e)];

state_car = par2car(state);