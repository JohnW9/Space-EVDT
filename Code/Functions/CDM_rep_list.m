function cdm_rep_list = CDM_rep_list (event_detection,cdm_list)
cdm_rep_list=cell(1,size(event_detection,2));
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
        end
    end
    cdm_rep_list{2,i}=Pcmax;
    cdm_rep_list{3,i}=index_of_max;
    cdm_rep_list{4,i}=index;
end
% row1: Event number
% row2: Maximum Pc over the generated Pcs
% row3: The index of the CDM with the maximum Pc within the list column
% row4: Total number of CDMs generated for that conjunction event
% row5-end: CDMs generated in the order of time
