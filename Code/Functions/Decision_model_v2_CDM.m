% FUNCTION NAME:
%   Decision_model_V2_CDM
%
% DESCRIPTION:
%   This function implements the Decision model V2 for the use of CDMs.
%
% INPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   cdm_list = (H objects) A list of all the CDM's generated [CDM]
%   decision_list = (L objects) The list containing all the actions taken by the decision model [Decision_action]
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%   t = [1x1] Realistic observation time [mjd2000]
%
%
% OUTPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   cdm_list = (H objects) A list of all the CDM's generated [CDM]
%   decision_list = (J objects) The list containing all the actions taken by the decision model [Decision_action]
%
%
%
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   24/5/2023 - Jonathan Wei
%       * Header added
%
%

function Decision_model_v2_CDM (real_CDM_list_full)

config = GetConfig;
cdm_length = size(real_CDM_list_full,1)
for i=1:length(real_CDM_list_full) % loops through all the generated CDMs
        %% Decision tree
        if value_of_collision > config.CC_threshold
            %increase threshold if high value of collision
            Pc = Pc * 10;
        end

        if (Pc>config.red_event_Pc)
            %red event
            %Manual process
            [cdm_list,action_det]=Manual_process(event_detection,cdm_list,i, event_detection_index);
    
        elseif (Pc<config.red_event_Pc && Pc>config.yellow_event_Pc)
            %yellow event
            %high B* OD flag
            if cdm_list(i).Pc < config.red_event_Pc && cdm_list(i).Pc > config.red_event_Pc/10 %close to limit
                    if event_detection(16,event_detection_index) > config.B_star_threshold
                        action_det = "high B* star OD flag, red Pc";
                    else
                        action_det = "yellow Pc";
                    end
            else
                action_det = "yellow Pc";
            end
                %do OD
        else
            %green event
            action_det = "green Pc";
        end

        if TimeToConjunction<config.TimeToConj_low
            %Excecute_maneuver
        end

    end
end