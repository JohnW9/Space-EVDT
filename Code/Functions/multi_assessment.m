%% Function to do the entire assessment process in monte carlo way and by using a custom decision component and providing results in averaged way
function [no_cdms_average,events_red_average,events_yellow_average,dropped_event_average,operation_cost_average, cdm_list,cdm_rep_list,operation_cost] = multi_assessment(event_list,MC,space_cat,sats,epoch,no_days,func)
end_date = mjd20002date(date2mjd2000(epoch)+no_days);
config = GetConfig;

space_cat_ids=zeros(1,length(space_cat)); % Need to store the NORAD IDs in a matrix to ease computation efforts
for j=1:length(space_cat)
    space_cat_ids(j)=space_cat(j).id;
end

event_matrix = list2matrix (event_list);
MC_cdm_list = cell(MC,1);
%MC_event_detection = cell(MC,1);
MC_total_cost = cell(MC,1);
MC_decision_list = cell(MC,1);
MC_cdm_rep_list = cell(MC,1);
MC_operation_cost = cell(MC,1);
WaitBar_Assess = waitbar(0,'Starting Monte Carlo simulation...');
%parfor ind = 1:MC
for ind = 1:MC
    cdm_list=CDM;
    decision_list=Decision_action;
    event_detection=zeros(14,1);
    event_detection(1)=NaN;
    total_cost=0;
    %[cdm_list,event_detection,total_cost,decision_list]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,accelerator,cdm_list,decision_list,event_detection,total_cost,total_budget);
    if nargin<7
        [cdm_list,event_detection,total_cost,decision_list,operational_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,sats,0,cdm_list,decision_list,event_detection,total_cost,inf);
    else
        [cdm_list,event_detection,total_cost,decision_list,operational_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,sats,0,cdm_list,decision_list,event_detection,total_cost,inf,func);
    end
    cdm_rep_list = CDM_rep_list (event_detection,cdm_list);

    MC_cdm_list{ind} = cdm_list;
    %MC_event_detection{ind} = event_detection;
    MC_total_cost{ind} = total_cost;
    MC_decision_list{ind} = decision_list;
    MC_cdm_rep_list{ind} = cdm_rep_list;
    MC_operation_cost{ind} = operational_cost;

    waitbar(ind/MC,WaitBar_Assess,['Simulation ' num2str(ind) ' out of ' num2str(MC) ' completed']);
end
close(WaitBar_Assess);
cdm_list = MC_cdm_list;
cdm_rep_list = MC_cdm_rep_list;
%event_detection = MC_event_detection;
total_cost = MC_total_cost;
decision_list = MC_decision_list;
operation_cost = MC_operation_cost;


operation_cost_average = 0;
no_cdms_average = 0; 
events_red_average = 0;
events_yellow_average = 0;
dropped_event_average = 0;



for i = 1:length(MC_cdm_list)
    %
    operation_cost_average = operation_cost_average+MC_operation_cost{i};
    no_cdms_average = no_cdms_average + length(MC_cdm_list{i});
    %
    temp_red = 0;
    temp_yellow = 0;
    temp_rep_list = MC_cdm_rep_list{i};
    for j = 1:size(temp_rep_list,2)
        if temp_rep_list{2,j} >= config.red_event_Pc
            temp_red = temp_red+1;
        elseif temp_rep_list{2,j} >= config.yellow_event_Pc
            temp_yellow = temp_yellow+1;
        end
    end
    events_red_average = events_red_average+temp_red;
    events_yellow_average = events_yellow_average+temp_yellow;
    %
    temp_drop = 0;
    temp_decision_list = MC_decision_list{i};
    for k =1:length(temp_decision_list)
        try
            if temp_decision_list(k).action == 2
                temp_drop = temp_drop+1;
            end
        catch
            break
        end
    end

    dropped_event_average = dropped_event_average+temp_drop;
       

end

operation_cost_average = operation_cost_average/length(MC_cdm_list);
no_cdms_average = no_cdms_average/length(MC_cdm_list);
events_red_average = events_red_average/length(MC_cdm_list);
events_yellow_average = events_yellow_average/length(MC_cdm_list);
dropped_event_average = dropped_event_average/length(MC_cdm_list);



end
