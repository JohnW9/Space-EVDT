% FUNCTION NAME:
%   read_real_CDM
%
% DESCRIPTION:
% 
% INPUT:
%
%    
%
% OUTPUT:
%  
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   22/5/2024 - Jonathan Wei
%       * Header added

function real_CDM = read_real_CDM(database1,database2)
    real_CDM = real_CDM();
    nb_col1 = size(database1,2);
    nb_col2 = size(database2,2);
    for current_col = 1:nb_col1
       real_CDM.Primary_ID = database1(1,current_col);
end



