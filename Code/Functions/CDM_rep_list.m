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
%

function cdm_rep_list = CDM_rep_list (event_detection,cdm_list)
config = GetConfig;
MaxPosRows = ceil(7/config.commercial_SSA_updateInterval_lower);
maximum_index = 0;
cdm_rep_list=cell(MaxPosRows,size(event_detection,2));
for i=1:size(event_detection,2)
    cdm_rep_list{1,i}=i;
    index=4;
    Pcmax=0;
    for j=1:length(cdm_list)
        if cdm_list(j).label==cdm_rep_list{1,i}
            index=index+1;
            cdm_rep_list{index,i}=cdm_list(j);
            if cdm_list(j).Pc>Pcmax
                Pcmax=cdm_list(j).Pc;
                index_of_max=index;
            end
            if maximum_index<index
                maximum_index = index;
            end
        end
    end
    cdm_rep_list{2,i}=Pcmax;
    cdm_rep_list{3,i}=index_of_max;
    cdm_rep_list{4,i}=index-4;
end
cdm_rep_list(maximum_index+1:end,:) = [];

