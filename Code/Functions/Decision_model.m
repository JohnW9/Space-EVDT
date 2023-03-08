% FUNCTION NAME:
%   Decision_model
%
% DESCRIPTION:
%   This function takes into account any failed tasking requests and newly generated CDMs
%   and decides on an observation or mitigation action. This model basically tries to replicate
%   how CARA deals with detected events and generated CDMs.
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
%   The decision tree is simple, yet complex (multiple end-notes). However the final
%   decision is one out of 4: (Do nothing, Tasking for commercial SSA provider, Maneuvering, Contacting)
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
%
%
function [event_detection,cdm_list,decision_list]=Decision_model (event_detection,cdm_list,decision_list,total_cost,t)
global config;
global total_budget;
for i=1:size(event_detection,2) %First detecting if there were any failed tasking requests (No CDM generated for the event at expected time)
    if event_detection(9,i)>t && event_detection(11,i)==-1 % The case where the commercial SSA provider was unavialable
        %event_detection(7,i)=t+config.commercial_SSA_updateInterval;
        event_detection(7,i)=NaN;
        event_detection(8,i)=1;
        event_detection(11,i)=1;
        event_number=i;
        TimeToConjunction=event_detection(9,i)-t;
        for v=length(cdm_list):-1:1 % Finding which last CDM corresponded to the same event
            if cdm_list(v).read_status==1 && cdm_list(v).label==event_detection(1,i)
                kl=v;
                break;
            else
                kl=-1;
            end
        end
        
        
        if isempty(decision_list(end).action_number)
            act_ind=1;
        else
            act_ind=length(decision_list)+1;
        end
        decision_list(act_ind).action_number=act_ind;
        decision_list(act_ind).cdm = cdm_list(kl);
        decision_list(act_ind).collision_label = event_number;
        decision_list(act_ind).cdm_number = cdm_list(kl).Num;
        decision_list(act_ind).action = "Last tasking request for this event was not satisfied; A new high priority request issued.";
        decision_list(act_ind).Pc = cdm_list(kl).Pc;
        decision_list(act_ind).TimeToConjunction = TimeToConjunction;
        decision_list(act_ind).ValueOfCollision = cdm_list(kl).value1+cdm_list(kl).value2+cdm_list(kl).CC/config.CC_normalizer;
        Possibility_of_contacting=0;
        if cdm_list(i).value2>0; Possibility_of_contacting=1;end
        decision_list(act_ind).Contact_possibility = Possibility_of_contacting;
        budget = total_budget - total_cost;
        decision_list(act_ind).available_budget = budget;
            
    end
end

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

        %% Summarized decision tree
        if ... % When to make maneuver
                (Pc>=config.red_event_Pc && TimeToConjunction<=config.TimeToConj_low) 
            action_det = "High Pc and low time to TCA. A maneuver action is decided for the primary object (No time to contact the secondary object's owner";
            event_detection(10,event_detection_index)=1;
        elseif ... % When to contact the secondary object's owner
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision>=config.value_low)
            if Possibility_of_contacting == 1
                action_det = "High Pc and medium time to TCA. The secondary object is an active payload and we are able to decide with them on a mitigation action";
                event_detection(10,event_detection_index)=1;
            else
                action_det = "High Pc and medium time to TCA. The secondary object is NOT an active payload and we are unable to contact them. A maneuver action is decided for the primary object";
                event_detection(10,event_detection_index)=1;
            end
        elseif ... % When to request tasking
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision<=config.value_low) || ...
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_high && budget>=total_budget*config.budget_tres) || ...
                (Pc<config.red_event_Pc && Pc>=config.yellow_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision>=config.value_high && budget>=total_budget*config.budget_tres) || ...
                (Pc<config.red_event_Pc && Pc>=config.yellow_event_Pc && TimeToConjunction<=config.TimeToConj_low && value_of_collision>=config.value_low && budget>=total_budget*config.budget_tres) || ...
                (Pc<=config.yellow_event_Pc && TimeToConjunction<=config.TimeToConj_low && value_of_collision>=config.value_high && budget>=total_budget*config.budget_tres)
            action_det = "Tasking. Commercial SSA provider data requested.";
            event_detection(10,event_detection_index)=0;
            event_detection(8,event_detection_index)=1;
        else
            action_det = "No action required. Waiting for further government SSA data to be available";
            event_detection(10,event_detection_index)=0;
            event_detection(8,event_detection_index)=0;
        end

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

