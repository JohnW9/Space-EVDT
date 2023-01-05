function [event_detection,cdm_list,action_list]=Decision (event_detection,cdm_list,action_list,total_cost,t)

for i=1:size(event_detection,2)
    if event_detection(9,i)>t && event_detection(11,i)==-1 % The case where the commercial SSA provider was unavialable
        event_detection(7,i)=t+0.2;
        event_detection(8,i)=1;
        event_detection(11,i)=1;
        action=1;
        event_number=i;
        TimeToConjunction=event_detection(9,i)-t;
        for v=length(cdm_list):-1:1
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

for i=1:length(cdm_list)
    if cdm_list(i).read_status==1
        continue;
    else
        event_detection_index=find(event_detection(1,:)==cdm_list(i).label);
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
            if TimeToConjunction>1
                event_detection(7,event_detection_index)=t+0.2;
                event_detection(8,event_detection_index)=1;
                action=1;
            else
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

