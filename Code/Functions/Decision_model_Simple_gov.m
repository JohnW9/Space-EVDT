function [event_detection,cdm_list,decision_list,operation_cost]=Decision_model_Simple_gov (event_detection,cdm_list,decision_list,total_cost,t,total_budget,operation_cost)

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
        elseif Pc<=config.yellow_event_Pc && TimeToConjunction<=config.TimeToConj_low
            action_det = 2;
            event_detection(10,event_detection_index)=1;
        else
            action_det = 3;
            event_detection(10,event_detection_index)=0;
            event_detection(8,event_detection_index)=0;
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
% 2 = Drop
% 3 = Nothing