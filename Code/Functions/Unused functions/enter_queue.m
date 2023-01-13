function list=enter_queue (list,entity)
if isempty(list)
    list{1}=entity;
else
    list{end+1}=entity;
end