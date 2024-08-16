% FUNCTION NAME:
%   Decision_model_V2_CDM
%
% DESCRIPTION:
%   This function implements the Decision model V2 for the use of CDMs.
%
% INPUT:
%  real_CDM_list: list of real CDMs [real_CDM]
%  red_PC: currently considered Pc threshold (for maneuvring)
%  time_of_maneuver: currently considered time of maneuver
%  sat_maneuver_dict: dictionnary mapping 
%
% OUTPUT:
%  real_CDM_list: list of real CDMs [real_CDM]
%  nb_of_maneuver: resulting number of maneuvers
%  sat_maneuver_dict: dictionnary mapping satellite id to number of
%  maneuvers
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   24/5/2024 - Jonathan Wei
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
    current_ID=current_conjunction(chosen_cdm_index).Primary_ID;
    %if current_conjunction(chosen_cdm_index).Primary_ID == 43613
   
    %% Decision tree
        %if value_of_collision > config.CC_threshold
            %increase threshold if high value of collision
           % Pc = Pc * 10;
        %end
        Pc = current_conjunction(chosen_cdm_index).Pc;
        if (Pc>red_Pc) %red_Pc is selected in Main.m
            %red event
            % OD check
            [CollectedScores,CompositeScore,CurrentEval] = OD_check_CDM(current_conjunction(chosen_cdm_index),'primary');
            [CollectedScores,CompositeScore,CurrentEval] = OD_check_CDM(current_conjunction(chosen_cdm_index),'secondary');
            %Manual process
            Manual_process_CDM(current_conjunction,chosen_cdm_index,action_det,time_of_maneuver)
            action_det = "red Pc"; %temp
            nb_of_maneuver = nb_of_maneuver + 1;
            sat_maneuver_dict(current_conjunction(chosen_cdm_index).Primary_ID) = sat_maneuver_dict(current_conjunction(chosen_cdm_index).Primary_ID) + 1;
            
        elseif (Pc<config.red_event_Pc && Pc>config.yellow_event_Pc)
            %yellow event
            %high B* OD flag
            if Pc < config.red_event_Pc && Pc > config.red_event_Pc/10 %close to limit
                    if current_conjunction(chosen_cdm_index).Drag_primary > config.B_star_threshold
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
   % end
end

end