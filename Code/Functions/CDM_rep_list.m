% FUNCTION NAME:
%   CDM_rep_list
%
% DESCRIPTION:
%   This function is a post processing tool to sum up the CDMs related
%   to each specific conjunction event, along with some basic data
%
% INPUT:
%   event_detection = [14xP] A matrix with each column corresponding to conjunctions detected, in the
%                            chronological order. Containing important space object informations. 
%                            [--,mjd2000,--,--,km,--,mjd2000,--,mjd2000,--,--,mjd2000,km,mjd2000]'
%   cdm_list = (Q objects) List of all CDMs generated in the chronological order [CDM]
%
% OUTPUT:
%   cdm_rep_list = [SxP] A cell matrix with each column representing a single conjunction event 
%                        in an ascending chronological order, and rows containing the CDMs 
%                        corresponding to that conjunction event.
%
%
%     cdm_rep_list cell matrix column details:
%      row1: Event number
%      row2: Maximum Pc between the generated CDMs
%      row3: The index of the CDM with the maximum Pc within the list column
%      row4: Total number of CDMs generated for that conjunction event
%      row5-end: CDMs generated in the a chronological order
%
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   13/1/2023 - Sina Es haghi
%       * Adding header
%   12/5/2023 - Sina Es haghi
%       * Change the calculation method, much faster
%

function cdm_rep_list = CDM_rep_list (event_detection,cdm_list)
cdm_rep_list=cell(1,size(event_detection,2));

for m=1:size(event_detection,2)
    cdm_rep_list{1,m} = m;
    cdm_rep_list{2,m} = 0;
    cdm_rep_list{3,m} = 0;
    cdm_rep_list{4,m} = 0;
end

%%
for i=1:length(cdm_list)
    event_no = cdm_list(i).label;
    no_cdms = cdm_rep_list{4,event_no}+1;
    cdm_rep_list{4+no_cdms,event_no} = cdm_list(i);
    cdm_rep_list{4,event_no} = no_cdms;
end

for j=1:size(cdm_rep_list,2)
    max_Pc = 0;
    max_Pc_index = 0;
    for k = 5:cdm_rep_list{4,j}+4
        cdm = cdm_rep_list{k,j};
        if cdm.Pc>max_Pc
            max_Pc = cdm.Pc;
            max_Pc_index = k;
        end
    end
    cdm_rep_list{2,j} = max_Pc;
    cdm_rep_list{3,j} = max_Pc_index;
end
