function [cdm_list,event_detection,action_list,total_cost]=CARA_process (event_matrix,epoch,end_date,space_cat,space_cat_ids,eos,detection_date)


if nargin~=7
    detection_date=7;
end
% Event detection matrix (event_detection) details:
% row1: Conjunction event ID number (in chronological order)
% row2: Time of detection in [MJD2000]
% row3: Primary satellite NORAD ID
% row4: Secondary space object NORAD ID
% row5: Miss distance in [km]
% row6: Number of times the cdm is generated for the event
% row7: Next expected conjunction update
% row8: Type of SSA used
% row9: TCA
% row10: Mitigation status
% row11: Request status

ti=date2mjd2000(epoch);
tf=date2mjd2000(end_date);

det_matrix=event_matrix(1:5,:);
det_matrix(2,:)=det_matrix(2,:)-detection_date;

dt=1; % Days

t=ti;

total_cost=0;
ind_det=0;
ind_cdm=0;

cdm_list=CDM;
action_list=[];

event_detection=zeros(11,1);
event_detection(1)=NaN;

while t<=tf
    
    for i=1:size(det_matrix,2)
        if det_matrix(2,i)<=t
            if isnan(event_detection(1)) || isempty(find(event_detection(1,:)==det_matrix(1,i)))
                ind_det=ind_det+1;
                event_detection(1:5,ind_det)=det_matrix(:,i);
                event_detection(6,ind_det)=0;
                event_detection(7,ind_det)=t;
                event_detection(8,ind_det)=0;
                event_detection(9,ind_det)=event_matrix(2,i);
                event_detection(10,ind_det)=0;
                event_detection(11,ind_det)=0;
            end
        end
    end

    for j=1:size(event_detection,2)
        
        
        if event_detection(10,j)~=0
            continue;
        elseif event_detection(9,j)<t 
            event_detection(10,j)= -1;
        elseif event_detection(7,j)<=t
            [event_detection(:,j),conjunction_data,cost] = Technology_model (event_detection(:,j),t,space_cat,space_cat_ids);
            if event_detection(11,j)==-1
                continue;
            end
            cdm = CDM_generator (event_detection(:,j),conjunction_data,t,space_cat,space_cat_ids,eos);
            ind_cdm=ind_cdm+1;
            cdm_list(ind_cdm)=cdm;
            total_cost=total_cost+cost;
        end

    end

    [event_detection,cdm_list,action_list]=Decision (event_detection,cdm_list,action_list,total_cost,t);

    % Find minimum dt
    min_dt=1;
    for l=1:size(event_detection,2)
        delta=event_detection(7,l)-t;
        if delta>0 && delta<min_dt
            min_dt=delta;
        end
    end
    dt=min([1 min_dt]);
    t=t+dt;
end

disp('done');