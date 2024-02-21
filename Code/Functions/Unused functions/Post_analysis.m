%% Post analysis script for AeroConf 2024

addpath('Functions\');
addpath('Functions\NASA\');
addpath('Functions\');
addpath('Time_conversion\');
addpath("Data\");

%% Loading data from same satellite in 550 km but from 2005, 2015, 2023, 6 months simulation

event_list2023 = load('Data\ArbitrarySat_2023_550km_6Months_1950s.mat','event_list');

%% Finding events related to Landsat 7

landsat7_list(length(event_list)) = Conjunction_event;
i = 0;
for j=1:length(event_list)
    if event_list(j).primary_id == 25682
        i=i+1;
        landsat7_list(i)=event_list(j);
    end
end
landsat7_list(i+1:end)=[];

%% Finding event lists with miss distance less than 1 km

low_mis_dist_list(length(event_list)) = Conjunction_event;
i = 0;
for j=1:length(event_list)
    if event_list(j).mis_dist < 1
        i=i+1;
        low_mis_dist_list(i)=event_list(j);
    end
end
low_mis_dist_list(i+1:end)=[];

%% Finding events related to starlink
starlink_list(length(event_list)) = Conjunction_event;
f=0;
for i = 1:length(event_list)
    for k = 1:length(space_cat)
        if event_list(i).secondary_id == space_cat(k).id && contains(space_cat(k).name,'starlink','IgnoreCase',true)
            f=f+1;
            starlink_list(f)=event_list(i);
        elseif event_list(i).secondary_id == space_cat(k).id
            break
        end
    end
end
starlink_list(f+1:end) = [];

%% Average over Monte Carlo simulation

operation_cost_average = 0;
no_cdms_average = 0; 
events_red_average = 0;
events_yellow_average = 0;
events_green_average = 0;
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
        if temp_decision_list(k).action == 2
            temp_drop = temp_drop+1;
        end
    end

    dropped_event_average = dropped_event_average+temp_drop;
       

end

operation_cost_average = operation_cost_average/length(MC_cdm_list);
no_cdms_average = no_cdms_average/length(MC_cdm_list);
events_red_average = events_red_average/length(MC_cdm_list);
events_yellow_average = events_yellow_average/length(MC_cdm_list);
dropped_event_average = dropped_event_average/length(MC_cdm_list);
