% FUNCTION NAME:
%   s2date
%
% DESCRIPTION:
%   This function transformes a number of seconds into a date format.
%
% INPUT:
%   epoch_sec: time in [seconds]
%   
% OUTPUT:
%   epoch: time in format [Y,M,D,H,MN,S]
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   10/6/2024 - Jonathan Wei
%       * Adding header
%

function epoch = s2date(epoch_sec)
    epoch_day = epoch_sec/(60*60*24);
    epoch = datevec(epoch_day);
end