% FUNCTION NAME:
%   Valuing_model
%
% DESCRIPTION:
%   This is basically the Vulnerability model, outputting the monetized values of the
%   space objects in conjunction as the socio-economic impact of the conjunction event in case of collision.
%
% INPUT:
%   Primary_eos = (1 object)  Primary NASA satellite in conjunction [NASA_sat]
%   Secondary_object = (1 object) Secondary space object in conjunction with the NASA satellite [Space_object]
%
% OUTPUT:
%   value1 = [1x1] Monetized value of the primary NASA satellite
%   value2 = [1x1] Monetized value of the secondary object
%
% ASSUMPTIONS AND LIMITATIONS:
%   The values need to be normalized before summation.
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function [value1,value2]=Valuing_model(Primary_eos,Secondary_object)

if isempty(Primary_eos.value)
    Primary_eos=Valuing_NASA_EOS(Primary_eos);
end
value1=Primary_eos.value;
if isempty(Secondary_object.value)
    Secondary_object=Valuing_Secondary_obj(Secondary_object);
end
value2=Secondary_object.value;
