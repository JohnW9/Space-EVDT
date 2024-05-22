% FUNCTION NAME:
%   Decision_model_V2_TLE
%
% DESCRIPTION:
%   This function implements the Decision model V2 for the use of TLEs. The
%   Deicision model is simplified compared to Decision_model_V2_CDMs, due
%   to lack of input data. The code implements Pc vs HBR, MTS, SWTS
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
%   04/5/2023 - Jonathan Wei
%       * Header added
%
%

function [event_detection,cdm_list,decision_list]=Decision_model_v2_TLE (event_detection,cdm_list,decision_list,total_cost,t,total_budget)

config = GetConfig;
%dealing with a failed tasking request (to the commercial SSA)
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
        %adds decision details to the decision_list
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
        if cdm_list(i).value2>0; Possibility_of_contacting=1;
        end

        %% Decision tree
        if value_of_collision > config.CC_threshold
            %increase threshold if high value of collision
            Pc = Pc * 10;
        end

        if (Pc>config.red_event_Pc)
            %red event
            %Manual process
            [cdm_list,action_det]=Manual_process(event_detection,cdm_list,i, event_detection_index, space_cat);
            action_det = "red Pc";
        elseif (Pc<config.red_event_Pc && Pc>config.yellow_event_Pc)
            %yellow event
            action_det = "yellow Pc";
            %do OD
        else
        %green event
        action_det = "green Pc";
        end

        if TimeToConjunction<config.TimeToConj_low
            %Excecute_maneuver
        end

        %event_detection(10,event_detection_index)=0; -> should be the case by default
        
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