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

function real_CDM_list = Decision_model_v2_CDM (real_CDM_list)

config = GetConfig;
conjunction = real_CDM.empty; % temporary list of 1 single conjunction (can contain several CDMs)
conjunction_list = {}; %cell array of conjunctions
current_index = 1;

for i=1:length(real_CDM_list) % loops through all the generated CDMs

        %% Regroup the CDMs by conjunction
        if real_CDM_list(i).Event_number == current_index
            conjunction(end+1) = real_CDM_list(i); %#ok<AGROW>
        else
            conjunction_list{end+1} = conjunction; %#ok<AGROW>
            conjunction = real_CDM.empty;
            conjunction(end+1) = real_CDM_list(i); %#ok<AGROW> %don't forget to add the current element
            current_index = current_index+1;

            if i == length(real_CDM_list) %handling the last element of the list
                conjunction_list{end+1} = conjunction; %#ok<AGROW>
            end
        end
end

sorted_conj_list = cell(1,length(conjunction_list)); %empty cell array for sorted conjunctions
action_list = cell(1,length(conjunction_list));

time_of_maneuver = 24*3600; %temp, time of maneuver before TCA

for j=1:length(conjunction_list)

        for current_cdm_index = 1:length(conjunction_list{j})
            conjunction_list{j}(current_cdm_index).Creation_time_sec = date2sec(conjunction_list{j}(current_cdm_index).Creation_time); %#ok<AGROW>

            conjunction_list{j}(current_cdm_index).TCA_sec = date2sec(conjunction_list{j}(current_cdm_index).TCA); %#ok<AGROW>
            %save the second format in the real_cdm themselves
        end
end

for h=1:length(conjunction_list)
    current_conjunction_list = conjunction_list{h};
    TCA_list = [current_conjunction_list.TCA_sec];
    [~, ind] = sort([TCA_list]); %#ok<NBRAK2>
    sorted_current_conj_list = current_conjunction_list(ind);
    sorted_conj_list{h} = sorted_current_conj_list;
end



    %% choose last CDM before TCA
for l=1:length(conjunction_list)
    current_conjunction_list = conjunction_list{l};
    for current_cdm_index = 1:length(current_conjunction_list)
            if current_conjunction_list(current_cdm_index).Creation_time_sec > current_conjunction_list(current_cdm_index).TCA_sec-time_of_maneuver
                chosen_cdm_index = current_cdm_index;
                break;
            elseif current_cdm_index == length(current_conjunction_list) % if no cdm is within chosen time range
                chosen_cdm_index = current_cdm_index; % choose last cdm available
            end
    end
        
    %% Decision tree
        %if value_of_collision > config.CC_threshold
            %increase threshold if high value of collision
           % Pc = Pc * 10;
        %end
        Pc = current_conjunction_list(chosen_cdm_index).Pc;
        if (Pc>config.red_event_Pc)
            %red event
            %Manual process
            %[cdm_list,action_det]=Manual_process(event_detection,cdm_list,i, event_detection_index);
            action_det = "red Pc"; %temp
        elseif (Pc<config.red_event_Pc && Pc>config.yellow_event_Pc)
            %yellow event
            %high B* OD flag
            if Pc < config.red_event_Pc && Pc > config.red_event_Pc/10 %close to limit
                    if current_conjunction_list(chosen_cdm_index).Drag_primary > config.B_star_threshold % TO CHANGE
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