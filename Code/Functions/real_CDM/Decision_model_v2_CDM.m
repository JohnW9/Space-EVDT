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

function [real_CDM_list, nb_of_maneuver,sat_maneuver_dict] = Decision_model_v2_CDM (real_CDM_list,red_Pc,time_of_maneuver,sat_maneuver_dict)

config = GetConfig;
nb_of_maneuver = 0;

sorted_conj_list = conjunction_sort(real_CDM_list);
action_list = cell(1,length(sorted_conj_list));

   
for l=1:length(sorted_conj_list)
     %% choose last CDM before TCA
    current_conjunction = sorted_conj_list{l};
  chosen_cdm_index = choose_maneuver_cdm(current_conjunction,time_of_maneuver);
        
    %% Decision tree
        %if value_of_collision > config.CC_threshold
            %increase threshold if high value of collision
           % Pc = Pc * 10;
        %end
        Pc = current_conjunction(chosen_cdm_index).Pc;
        if (Pc>red_Pc) %red_Pc is selected in Main.m
            %red event
            %Manual process
            Manual_process_CDM(current_conjunction,chosen_cdm_index,action_det)
            action_det = "red Pc"; %temp
            nb_of_maneuver = nb_of_maneuver + 1;
            sat_maneuver_dict(current_conjunction(chosen_cdm_index).Primary_ID) = sat_maneuver_dict(current_conjunction(chosen_cdm_index).Primary_ID) + 1;
            
        elseif (Pc<config.red_event_Pc && Pc>config.yellow_event_Pc)
            %yellow event
            %high B* OD flag
            if Pc < config.red_event_Pc && Pc > config.red_event_Pc/10 %close to limit
                    if current_conjunction(chosen_cdm_index).Drag_primary > config.B_star_threshold % TO CHANGE
                        action_det = "high B* star OD flag, red Pc";
                    else
                        action_det = "yellow Pc";
                    end
            else
                action_det = "yellow Pc";
            end
        else
            %green event
            action_det = "green Pc";
        end
        action_list{l} = action_det;
end

end