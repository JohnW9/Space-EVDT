% FUNCTION NAME:
%   Decision_model
%
% DESCRIPTION:
%   This function takes into account any failed tasking requests and newly generated CDMs
%   and decides on an observation or mitigation action. This model basically tries to replicate
%   how CARA deals with detected events and generated CDMs.
%
% INPUT:
%   event_detection = [13xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km]'
%   cdm_list = (H objects) A list of all the CDM's generated [CDM]
%   action_list = [5xL] A matrix containing all the actions taken by the Decision model [--,--,--,days,--]'
%   total_cost = [1x1] An index showing the accumulated cost due to requests from the commercial SSA provider
%   t = [1x1] Realistic observation time [mjd2000]
%
%
% OUTPUT:
%   event_detection = [13xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km]'
%   cdm_list = (H objects) A list of all the CDM's generated [CDM]
%   action_list = [5xJ] A matrix containing all the actions taken by the Decision model plus the new actions [--,--,--,days,--]'
%
%
%
%   action_list matrix data:
%   row1 : CDM index in which the action is related to
%   row2 : Action taken by the decision model (0-No tasking requested, 1-High importance tasking requested, 2-Maneuver needed, 3-Contacting the secondary object operator needed)
%   row3 : Pc value
%   row4 : Time till conjunction [days]
%   row5 : Which conjunction event does this action correspond to
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   Currently the only decision variable is the Pc of an event.
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Header added
%
function [event_detection,cdm_list,action_list,decision_list]=Decision_model (event_detection,cdm_list,action_list,decision_list,total_cost,t)
global config;
global total_budget;
for i=1:size(event_detection,2) %First detecting if there were any failed tasking requests (No CDM generated for the event at expected time)
    if event_detection(9,i)>t && event_detection(11,i)==-1 % The case where the commercial SSA provider was unavialable
        %event_detection(7,i)=t+config.commercial_SSA_updateInterval;
        event_detection(7,i)=NaN;
        event_detection(8,i)=1;
        event_detection(11,i)=1;
        action=1;
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
        action_list(:,end+1)=[kl;action;-1;TimeToConjunction;event_number];
        
        
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
        value_of_collision=cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC/config.CC_normalizer;
        budget = total_budget - total_cost;
        Pc=cdm_list(i).Pc;
        TimeToConjunction=date2mjd2000(cdm_list(i).tca)-t;
        Possibility_of_contacting=0;
        if cdm_list(i).value2>0; Possibility_of_contacting=1;end

        %% Simple decision making
%{
        if Pc<config.yellow_event_Pc
            %event_detection(7,event_detection_index)=event_detection(7,event_detection_index);
            event_detection(8,event_detection_index)=0;
            action=0;
        elseif Pc<config.red_event_Pc
            event_detection(7,event_detection_index)=t+config.commercial_SSA_updateInterval;
            event_detection(8,event_detection_index)=1;
            action=1;
        elseif Pc>config.red_event_Pc
            if TimeToConjunction>config.red_mitigation_days % If there is more than 1 day till TCA, still just observe with high priority
                event_detection(7,event_detection_index)=t+config.commercial_SSA_updateInterval;
                event_detection(8,event_detection_index)=1;
                action=1;
            else    % if less than 1 day till TCA, take mitigation action
                event_detection(10,event_detection_index)=1;
                if Possibility_of_contacting==0
                    action=2;
                else
                    action=3;
                end
                
            end
        end
%}

        %% Sample

        %{
        if Pc<config.yellow_event_Pc % Green events
            if TimeToConjunction>config.TimeToConj_high % High number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION # Green event,High number to TCA, Low Value, High budget
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION # Green event,High number to TCA, Low Value, Medium budget
                    else % Low amount of budget available
                        % DECISION # Green event,High number to TCA, Low Value, Low budget
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            elseif TimeToConjunction>config.TimeToConj_low % Medium number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            else    % Low number of days to TCA
                if value_of_collision<config.value_low % Low collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            end
            %}


        %% Modified decision model
%{
        if Pc<config.yellow_event_Pc % Green events
            if TimeToConjunction>config.TimeToConj_high % High number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION # Green event,High number to TCA, Low Value, High budget
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION # Green event,High number to TCA, Low Value, Medium budget
                    else % Low amount of budget available
                        % DECISION # Green event,High number to TCA, Low Value, Low budget
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            elseif TimeToConjunction>config.TimeToConj_low % Medium number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            else    % Low number of days to TCA
                if value_of_collision<config.value_low % Low collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            end
        elseif Pc<config.red_event_Pc % Yellow events
            if TimeToConjunction>config.TimeToConj_high % High number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            elseif TimeToConjunction>config.TimeToConj_low % Medium number of days to TCA
                if value_of_collision<config.value_low % Low collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            else    % Low number of days to TCA
                if value_of_collision<config.value_low % Low collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value

                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            end
        elseif Pc>config.red_event_Pc % Red events
            if TimeToConjunction>config.TimeToConj_high % High number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            elseif TimeToConjunction>config.TimeToConj_low % Medium number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            else    % Low number of days to TCA
                if value_of_collision<config.value_low % Low collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                elseif value_of_collision<config.value_high % Medium collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                else % High collision value
                    if budget>total_budget*config.budget_high % High amount of budget available
                        % DECISION #
                    elseif budget>total_budget*config.budget_low % Medium amount of budget available
                        % DECISION #
                    else % Low amount of budget available
                        % DECISION #
                    end
                end
            end
        end
%}

        %% Summarized decision tree
        if ... % When to make maneuver
                (Pc>=config.red_event_Pc && TimeToConjunction<=config.TimeToConj_low) || ...
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision>=config.value_high)
            action = 2;
            action_det = "High Pc and medium to low time to TCA. A maneuver action is decided for the primary object (No time to contact the secondary object's owner";
            event_detection(10,event_detection_index)=1;
        elseif ... % When to contact the secondary object's owner
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision>=config.value_low)
            if Possibility_of_contacting == 1
                action = 3;
                action_det = "High Pc. The secondary object is an active payload and we are able to decide with them on a mitigation action";
                event_detection(10,event_detection_index)=1;
            else
                action = 2;
                action_det = "High Pc. The secondary object is NOT an active payload and we are unable to contact them. A maneuver action is decided for the primary object";
                event_detection(10,event_detection_index)=1;
            end
        elseif ... % When to request tasking
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision<=config.value_low) || ...
                (Pc>=config.red_event_Pc && TimeToConjunction>=config.TimeToConj_high && budget>=total_budget*config.budget_low) || ...
                (Pc<config.red_event_Pc && Pc>=config.yellow_event_Pc && TimeToConjunction>=config.TimeToConj_low && TimeToConjunction<=config.TimeToConj_high && value_of_collision>=config.value_high && budget>=total_budget*config.budget_low) || ...
                (Pc<config.red_event_Pc && Pc>=config.yellow_event_Pc && TimeToConjunction<=config.TimeToConj_low && value_of_collision>=config.value_low && value_of_collision<config.value_high && budget>=total_budget*config.budget_high) || ...
                (Pc<config.red_event_Pc && Pc>=config.yellow_event_Pc && TimeToConjunction<=config.TimeToConj_low && value_of_collision>=config.value_high && budget>=total_budget*config.budget_low) || ...
                (Pc<=config.yellow_event_Pc && TimeToConjunction<=config.TimeToConj_low && value_of_collision>=config.value_high && budget>=total_budget*config.budget_high)
            action = 1;
            action_det = "Tasking. Commercial SSA provider data requested.";
            event_detection(10,event_detection_index)=0;
            event_detection(8,event_detection_index)=1;
            %event_detection(7,event_detection_index)=t+config.commercial_SSA_updateInterval;
        else
            action = 0;
            action_det = "No action required. Waiting for further government SSA data to be available";
            event_detection(10,event_detection_index)=0;
            event_detection(8,event_detection_index)=0;
        end

        event_detection(7,event_detection_index)=NaN;

        %%
        event_number=event_detection_index;
        action_list(:,end+1)=[i;action;Pc;TimeToConjunction;event_number];





        if isempty(decision_list(end).action_number)
            act_ind=1;
        else
            act_ind=length(decision_list)+1;
        end
        decision_list(act_ind).action_number=act_ind;
        decision_list(act_ind).cdm = cdm_list(i);
        decision_list(act_ind).collision_label = event_number;
        decision_list(act_ind).cdm_number = cdm_list(i).Num;
        decision_list(act_ind).action = action_det;
        decision_list(act_ind).Pc = cdm_list(i).Pc;
        decision_list(act_ind).TimeToConjunction = TimeToConjunction;
        decision_list(act_ind).ValueOfCollision = cdm_list(i).value1+cdm_list(i).value2+cdm_list(i).CC/config.CC_normalizer;
        decision_list(act_ind).Contact_possibility = Possibility_of_contacting;
        decision_list(act_ind).available_budget = budget;


    end
end

