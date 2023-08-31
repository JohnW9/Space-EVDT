% FUNCTION NAME:
%   Valuing_Secondary_obj
%
% DESCRIPTION:
%   As part of the vulnerability model, this function gives a monetized
%   value to the secondary space object in conjunction with the NASA satellite.
%   The value is given based upon the RCS size of the object and if the object is a payload
%
% INPUT:
%   obj = (1 object) Secondary space object in conjunction with the NASA satellite [Space_object]
%
% OUTPUT:
%   obj = (1 object) Secondary space object in conjunction with the NASA satellite, with added value [Space_object]
%
% ASSUMPTIONS AND LIMITATIONS:
%   Only giving a value to the object if it is a PAYLOAD.
%   Value is based on RCS size (So only 3 values are considered currently)
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function obj = Valuing_Secondary_obj (obj)
config = GetConfig;

if strcmp(obj.type,'PAYLOAD')
    if strcmp(obj.RCS,'SMALL') 
        value=config.small_value;
    elseif strcmp(obj.RCS,'MEDIUM')
        value=config.medium_value;
    else
        value=config.large_value;
    end
else
    value = 0;
end
obj.value=value;