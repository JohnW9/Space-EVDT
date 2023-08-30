% FUNCTION NAME:
%   NextUpdateIntervalAssignment
%
% DESCRIPTION:
%   When an observation request is decided on (either governmental or commercial SSA provider),
%   this function will decide when the next conjunction object data can be updated! It uses the
%   pre-defined update frequency of each of the SSA providers, but adds a stochastic twist to it
%   and the next update time will be a uniformly random number between 0.5 and 1.5 multiplied by 
%   the pre-defined interval.
%
% INPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   t = [1x1] Realistic observation time [mjd2000]
%
% OUTPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   1/2/2023 - Sina Es haghi
%       * Initial implementation
%   23/2/2023 - Sina Es haghi
%       * Using the random_generator function
%

function event_detection = NextUpdateIntervalAssignment (event_detection,t)

config = GetConfig;

for i = size(event_detection,2):-1:1
    
    if ~isnan(event_detection(7,i))
        continue;
    end

    if event_detection(8,i)==1
        event_detection(7,i) = t + random_generator(config.commercial_SSA_updateInterval_lower,config.commercial_SSA_updateInterval_upper,[1,1]);
    else
        event_detection(7,i) = t + random_generator(config.government_SSA_updateInterval_lower,config.government_SSA_updateInterval_upper,[1,1]);
    end
end
