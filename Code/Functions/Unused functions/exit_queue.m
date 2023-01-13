function [list,entity]=exit_queue(list)
if isempty(list)
    entity=[];
elseif length(list)==1
    entity=list{1};
    list={};
else
    entity=list{1};
    %list{1:end-1}=list{2:end};
    list=list(2:end);
    %list{end}={};
end