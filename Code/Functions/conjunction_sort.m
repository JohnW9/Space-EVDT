% FUNCTION NAME:
%   conjunction_sort
%
% DESCRIPTION:
%   This function regroups real_CDMs into conjunction events (each event
%   can contain multiple CDMs), then sorts the CDMs within each conjunction
%   chornologically.
%
% INPUT:
%
%
% OUTPUT:
%
%
% ASSUMPTIONS AND LIMITATIONS:
% 
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   29/5/2024 - Jonathan Wei
%       * Header added
%
%


function sorted_conj_list = conjunction_sort(real_CDM_list)

conjunction = real_CDM.empty; % temporary list of 1 single conjunction (can contain several CDMs)
conjunction_list = {}; %cell array of conjunctions
current_index = 1;

for i=1:length(real_CDM_list) % loops through all the generated CDMs

        %% Regroup the CDMs by conjunction
        if real_CDM_list(i).Event_number == current_index
            conjunction(end+1) = real_CDM_list(i); %#ok<AGROW>
        else
            conjunction_list{end+1} = conjunction; %#ok<AGROW>
            conjunction = real_CDM.empty;
            conjunction(end+1) = real_CDM_list(i); %#ok<AGROW> %don't forget to add the current element
            current_index = current_index+1;

            if i == length(real_CDM_list) %handling the last element of the list
                conjunction_list{end+1} = conjunction; %#ok<AGROW>
            end
        end
end

sorted_conj_list = cell(1,length(conjunction_list)); %empty cell array for sorted conjunctions


for j=1:length(conjunction_list)

        for current_cdm_index = 1:length(conjunction_list{j})
            conjunction_list{j}(current_cdm_index).Creation_time_sec = date2sec(conjunction_list{j}(current_cdm_index).Creation_time); %#ok<AGROW>

            conjunction_list{j}(current_cdm_index).TCA_sec = date2sec(conjunction_list{j}(current_cdm_index).TCA); %#ok<AGROW>
            %save the second format in the real_cdm themselves
        end
end

%sort the CDMs within each conjunction
for h=1:length(conjunction_list)
    current_conjunction_list = conjunction_list{h};
    Creation_t_list = [current_conjunction_list.Creation_time_sec];
    [~, ind] = sort([Creation_t_list]); %#ok<NBRAK2>
    sorted_current_conj_list = current_conjunction_list(ind);
    sorted_conj_list{h} = sorted_current_conj_list;
end