function CARA_process (event_matrix,epoch,end_date)

% Event detection matrix (event_detection) details:
% row1: Conjunction event ID number (in chronological order)
% row2: Time of Closest Approach (TCA) in [MJD2000]
% row3: Primary satellite NORAD ID
% row4: Secondary space object NORAD ID
% row5: Miss distance in [km]
% row6: Number of times the cdm is generated for the event
% row7: Next expected conjunction update
% row8: Type of SSA used


ti=date2mjd2000(epoch);
tf=date2mjd2000(end_date);

det_matrix=event_matrix(1:5,:);
det_matrix(2,:)=det_matrix(2,:)-7;

dt=1; % Days

t=ti;

ind_det=0;

while t<=tf
    
    for i=1:size(det_matrix,2)
        if det_matrix(2,i)<t
            if isempty(event_detection) || isempty(find(event_detection(1,:)==det_matrix(1,i)))
                ind_det=ind_det+1;
                event_detection(1:5,ind_det)=det_matrix(:,i);
                event_detection(6:ind_det)=0;
                event_detection(7:ind_det)=NaN;
                event_detection(8:ind_det)=0;
            end
        end
    end

    for j=1:size(det_matrix,2)
        if event_detection(6:j)==0
            
        elseif event_detection(7:j)==t
            
        end

    end
end