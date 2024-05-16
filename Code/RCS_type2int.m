% FUNCTION NAME:
%   RCS_type2int
%
% DESCRIPTION:
%   This function converts RCS (SMALL, MEDIUM, LARGE) & secondary object
%   type to an integer value. This is necessary during the list2matrix
%   conversion.
%   
%
% INPUT:
%   RCS = (string) Hard body radius category of the secondary object (SMALL, MEDIUM, LARGE)
%   type = (string) Secondary object type (PAYLOAD/ROCKET BODY/DEBRIS)
%
% OUTPUT:
%   RCS = (int) Integer indicating RCS category
%   type = (int) Integer indicating secondary object type
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   15/05/2024 - Jonathan Wei
%

function [RCS, type] = RCS_type2int(RCS,type)

if RCS == "SMALL"
    RCS = 0;
elseif RCS == "MEDIUM"
    RCS = 1;
elseif RCS == "LARGE"
    RCS = 2;
else
    RCS = 3;
end

if type == "PAYLOAD"
    type = 0;
elseif type == "ROCKET BODY"
    type = 1;
elseif type == "DEBRIS"
    type = 2;
else
    type = 3;
end
