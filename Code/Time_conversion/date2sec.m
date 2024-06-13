% FUNCTION NAME:
%   date2sec
%
% DESCRIPTION:
%   Converts the data (CDM format) into number of second
%
% INPUT:
%   date = [1x6] date int the format [year month day hour minute second]
%
% OUTPUT:
%   seconds = [sec] the input date in second format
%
%
% ASSUMPTIONS AND LIMITATIONS:
%   We ignore the year, as the year is the same in the database of all CDMs
%   and this allows us to have smaller numbers that are easier to handle
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   27/05/2024 - Jonathan Wei
%       * Adding header

function seconds = date2sec(date)
    seconds = date(1)*12*30*24*3600 + date(2)*30*24*3600 + date(3)*24*3600 + date(4)*60 + date(5);