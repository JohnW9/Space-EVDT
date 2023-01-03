function event_matrix = list2matrix (event_list,space_cat,space_cat_ids,accelerator)
if nargin==3
    accelerator=0;
end

event_matrix=zeros(18,size(event_list,2));
temp_objects(2)=Space_object;
for l=1:size(event_list,2)
    % Takes 6 first rows
    event_matrix(1:6,l)=[event_list(l).id event_list(l).tca event_list(l).primary_id event_list(l).secondary_id event_list(l).mis_dist event_list(l).status]';
    obj1_index = find(space_cat_ids==event_matrix(3,l));
    obj2_index = find(space_cat_ids==event_matrix(4,l));
    temp_objects(1)=space_cat(obj1_index);
    temp_objects(2)=space_cat(obj2_index);
    temp_objects(1) = TwoBP_J2_analytic (temp_objects(1),event_matrix(2,l),'mjd2000');
    temp_objects(2) = TwoBP_J2_analytic (temp_objects(2),event_matrix(2,l),'mjd2000');
    % Rest of the rows
    event_matrix(7:18,l)=[temp_objects(1).a temp_objects(1).e temp_objects(1).i temp_objects(1).raan temp_objects(1).om temp_objects(1).M ...
                          temp_objects(2).a temp_objects(2).e temp_objects(2).i temp_objects(2).raan temp_objects(2).om temp_objects(2).M]';
end
% Sort events by occurance times
[~,tca_index_sort]=sort(event_matrix(2,:));
sorted_event_matrix=event_matrix(:,tca_index_sort);
sorted_event_matrix(1,:)=1:size(sorted_event_matrix,2);
event_matrix=sorted_event_matrix;


% Event matrix details:
% row1: Conjunction event ID number (in chronological order)
% row2: Time of Closest Approach (TCA) in [MJD2000]
% row3: Primary satellite NORAD ID
% row4: Secondary space object NORAD ID
% row5: Miss distance in [km]
% row6: Risk mitigation status (1 asserts the risk is mitigated, 0 asserts the risk is not mitigated)
% row7-12: Orbital elements of the Primary satellite at TCA in [a:km e:-- i:rad raan:rad aop:rad M:rad]
% row13-18: Orbital elements of the Secondary space object at TCA in [a:km e:-- i:rad raan:rad aop:rad M:rad]

%% Stochastic events
modified_event_matrix = Stochastic_event_matrix (event_matrix,accelerator);
event_matrix=modified_event_matrix;