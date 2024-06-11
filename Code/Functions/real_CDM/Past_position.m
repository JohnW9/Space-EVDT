% FUNCTION NAME:
%   Past_position
%
% DESCRIPTION:
%   Computes the past position given initial position
%   
% INPUT:
%   epoch_sec: the time difference between TCA and the target maneuver time
%   [s]
%   oe_2: orbital elements at the position opposite to TCA
%   oe_1: orbital elements at TCA
%
% OUTPUT:
%   closest_delta_time: closest time to target maneuver time where the
%   spacecraft is also at the position opposite to TCA
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

function position = Past_position(closest_delta_time,given_cdm, Input_Object_Designator)

r1 = [given_cdm.(['X_ECI_' Input_Object_Designator]),...
      given_cdm.(['Y_ECI_' Input_Object_Designator]),...
      given_cdm.(['Z_ECI_' Input_Object_Designator])]; 

v1 = [given_cdm.(['X_DOT_ECI_' Input_Object_Designator]),... 
     given_cdm.(['Y_DOT_ECI_' Input_Object_Designator]),...
     given_cdm.(['Z_DOT_ECI_' Input_Object_Designator])];


    
end