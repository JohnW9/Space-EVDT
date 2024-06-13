% FUNCTION NAME:
%   Past_position
%
% DESCRIPTION:
%   Computes the position of the object at the real maneuver time given the
%   position in the [real_cdm]
%   
% INPUT:
%   closest_delta_time: closest time to target maneuver time where the
%   spacecraft is also at the position opposite to TCA
%   given_cdm: the current considered cdm [real_cdm]
%   Input_Object_Designator: 'primary' or 'secondary' (object)
%
% OUTPUT:

%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/6/2024 - Jonathan Wei
%       * Header added
%
%

function [r_past,v_past] = Past_position(closest_delta_time,given_cdm, Input_Object_Designator)
config = GetConfig;
r1 = [given_cdm.(['X_ECI_' Input_Object_Designator]),...
      given_cdm.(['Y_ECI_' Input_Object_Designator]),...
      given_cdm.(['Z_ECI_' Input_Object_Designator])]; 

v1 = [given_cdm.(['X_DOT_ECI_' Input_Object_Designator]),... 
     given_cdm.(['Y_DOT_ECI_' Input_Object_Designator]),...
     given_cdm.(['Z_DOT_ECI_' Input_Object_Designator])];


real_maneuver_time = given_cdm.TCA_sec-closest_delta_time;
if given_cdm.Creation_time_sec > real_maneuver_time % if the current r1 and v1 of the cdm are after the real maneuver time
    v1 = -v1; % to propagate in the other direction
end
propagation_time = abs(real_maneuver_time-given_cdm.Creation_time_sec);
[r_pastp,v_pastp] = keplerUniversal(r1',v1',propagation_time,config.mu);
r_past = r_pastp';
v_past = v_pastp';
    
end