function obj = Secondary_value (obj)

if strcmp(obj.type,'PAYLOAD')
    if strcmp(obj.RCS,'SMALL') 
        value=0.01;
    elseif strcmp(obj.RCS,'MEDIUM')
        value=0.1;
    else
        value=1;
    end
else
    value = 0;
end
obj.value=value;