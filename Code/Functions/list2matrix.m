% FUNCTION NAME:
%   list2matrix
%
% DESCRIPTION:
%   This function takes the raw conjunction events list, and puts them in a 
%   chronologically sorted matrix instead of a Conjunctino_event object list.
%   
%
% INPUT:
%   event_list = (P objects) List of conjunction events detected by the program, not in a sorted way [Conjunction_event]
%   
% OUTPUT:
%   event_matrix = [5xP] Matrix containing the conjunction event details in a timely order. The matrix details
%                        are as follows:
%
%       Event matrix details:
%       row1: Conjunction event ID number (in chronological order)
%       row2: Time of Closest Approach (TCA) in [MJD2000]
%       row3: Primary satellite NORAD ID
%       row4: Secondary space object NORAD ID
%       row5: Miss distance in [km]
%
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function event_matrix = list2matrix (event_list)

event_matrix=zeros(5,size(event_list,2));
for l=1:size(event_list,2)
    % Takes 5 first rows
    event_matrix(1:5,l)=[event_list(l).id event_list(l).tca event_list(l).primary_id event_list(l).secondary_id event_list(l).mis_dist]';
end
% Sort events by occurance times
[~,tca_index_sort]=sort(event_matrix(2,:));
sorted_event_matrix=event_matrix(:,tca_index_sort);
sorted_event_matrix(1,:)=1:size(sorted_event_matrix,2);
event_matrix=sorted_event_matrix;



