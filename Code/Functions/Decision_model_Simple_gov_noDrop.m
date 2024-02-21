% FUNCTION NAME:
%   Decision_model_Simple_gov_noDrop
%
% DESCRIPTION:
%   This function takes into account newly generated CDMs and decides which action to take.
%   This model relies on 100% availability of the governmental SSA.
%   It is assumed a conjunction is not dropped at all because of low Pc value, regardless of the time criticality
%
% INPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   cdm_list = (H objects) A list of all the CDM's generated [CDM]
%   decision_list = (L objects) The list containing all the actions taken by the decision model [Decision_action]
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%   t = [1x1] Realistic observation time [mjd2000]
%   total_budget = [1x1] Initial budget available to the COLA team dependant on the simulation time (constant)
%   operation_cost = [1x1] Total operational cost calculated by now for analyzing the CDMs [$]
%
%
% OUTPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   cdm_list = (H objects) A list of all the CDM's generated [CDM]
%   decision_list = (J objects) The list containing all the actions taken by the decision model [Decision_action]
%   operation_cost = [1x1] Total operational cost calculated by now for analyzing the CDMs [$]
%
%
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   The decision tree is simple. the final decision is one out of 2: (Do nothing, Maneuvering)
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Header added
%   01/2/2023 - Sina Es haghi
%       * More complex decision tree implemented, next_update_interval and action_list are deleted and a decision_list is replaced
%   15/2/2023 - Sina Es haghi
%       * New Decision tree implemented, the available budget is now categorized only as either high or low (one threshold)
%   20/2/2024 - Sina Es haghi
%       * Description modified plus the output of the function

%
function [event_detection,cdm_list,decision_list,operation_cost]=Decision_model_Simple_gov_noDrop (event_detection,cdm_list,decision_list,total_cost,t,total_budget,operation_cost)

config = GetConfig;


for i=length(cdm_list):-1:1 % loops through all the generated CDMs
    if cdm_list(i).read_status==1 % discards read CDMs
        %continue;
        break;
    else
        event_detection_index=find(event_detection(1,:)==cdm_list(i).label); % since the event_detection matrix has columns in the chronological order
        cdm_list(i).read_status=1;
        value_of_collision=cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC_value;
        budget = total_budget - total_cost;
        Pc=cdm_list(i).Pc;
        TimeToConjunction=date2mjd2000(cdm_list(i).tca)-t;
        Possibility_of_contacting=0;
        if cdm_list(i).value2>0; Possibility_of_contacting=1;end

        cost_of_cdm = cdm_list(i).cost;

        operation_cost = operation_cost + cost_of_cdm;

        %% Now the actual decision tree 
        if (Pc>=config.red_event_Pc && TimeToConjunction<=config.TimeToConj_low) 
            action_det = 1;
            event_detection(10,event_detection_index)=1;
        else
            action_det = 3;
            event_detection(10,event_detection_index)=0;
            event_detection(8,event_detection_index)=0;  %% The only difference between commercial no drop and gov no drop
        end

        %% Adding to decision list
        event_detection(7,event_detection_index)=NaN;

        if isempty(decision_list(end).action_number)
            act_ind=1;
        else
            act_ind=length(decision_list)+1;
        end
        decision_list(act_ind).action_number=act_ind;
        decision_list(act_ind).cdm = cdm_list(i);
        decision_list(act_ind).collision_label = event_detection_index;
        decision_list(act_ind).cdm_number = cdm_list(i).Num;
        decision_list(act_ind).action = action_det;
        decision_list(act_ind).Pc = cdm_list(i).Pc;
        decision_list(act_ind).TimeToConjunction = TimeToConjunction;
        decision_list(act_ind).ValueOfCollision = cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC/config.CC_normalizer;
        decision_list(act_ind).Contact_possibility = Possibility_of_contacting;
        decision_list(act_ind).available_budget = budget;
    end
end


%% Action list

% 1 = Mitigated
% 2 = Conjunction dropped
% 3 = Nothing