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
function [event_detection,cdm_list,action_list]=Decision_model (event_detection,cdm_list,action_list,total_cost,t)

for i=1:size(event_detection,2) %First detecting if there were any failed tasking requests (No CDM generated for the event at expected time)
    if event_detection(9,i)>t && event_detection(11,i)==-1 % The case where the commercial SSA provider was unavialable
        event_detection(7,i)=t+0.2;
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
    end
end

for i=1:length(cdm_list) % loops through all the generated CDMs
    if cdm_list(i).read_status==1 % discards read CDMs
        continue;
    else
        event_detection_index=find(event_detection(1,:)==cdm_list(i).label); % since the event_detection matrix has columns in the chronological order
        cdm_list(i).read_status=1;
        value_of_collision=cdm_list(i).value1+cdm_list(i).value2;
        %CC=cdm_list(i).CC;
        catas_flag=cdm_list(i).catas_flag;
        Pc=cdm_list(i).Pc;
        TimeToConjunction=date2mjd2000(cdm_list(i).tca)-t;
        Possibility_of_contacting=0;
        if cdm_list(i).value2>0; Possibility_of_contacting=1;end

        %% Simple decision making

        if Pc<1e-7
            %event_detection(7,event_detection_index)=event_detection(7,event_detection_index);
            event_detection(8,event_detection_index)=0;
            action=0;
        elseif Pc<1e-4
            event_detection(7,event_detection_index)=t+0.2;
            event_detection(8,event_detection_index)=1;
            action=1;
        elseif Pc>1e-4
            if TimeToConjunction>1 % If there is more than 1 day till TCA, still just observe with high priority
                event_detection(7,event_detection_index)=t+0.2;
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
        event_number=event_detection_index;
        action_list(:,end+1)=[i;action;Pc;TimeToConjunction;event_number];
    end
end

