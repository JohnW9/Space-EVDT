function t_candidate = time_window_overlap_finder(t_list1,t_list2)

jk = 0;
t_candidate = NaN (max([length(t_list1) length(t_list2)]),2);

for i = 1:size(t_list1,1)

    j0 = find(t_list2(:,2)<=t_list1(i,1));
    if isempty(j0); j0=1;end
    jf = find(t_list2(:,1)>=t_list1(i,2));
    if isempty(jf); jf=size(t_list2,1);end

    for j = j0:jf
        if max([t_list1(i,1) t_list2(j,1)])<=min([t_list1(i,2) t_list2(j,2)])
            jk = jk+1;
            %t_candidate(jk) = (max([t_list1(i,1) t_list2(j,1)]) + min([t_list1(i,2) t_list2(j,2)]))/2;
            t_candidate(jk,1:2) = [max([t_list1(i,1) t_list2(j,1)]) , min([t_list1(i,2) t_list2(j,2)])];
        end
    end
end

t_candidate(jk+1:end,:) = [];