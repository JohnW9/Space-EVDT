% FUNCTION NAME:
%   Manual_process
%
% DESCRIPTION:
%   This function simulates the manual process of NASA CARA. It includes Pc vs HBR, MTS and SWTS
%
% INPUT:
%
%
% OUTPUT:
%
%
%
%
%
% ASSUMPTIONS AND LIMITATIONS:
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   06/05/2024 - Jonathan Wei
%       * Header added

function []=Manual_process (event_detection,cdm_list,i, event_detection_index)
if TLE_input_mode
    %Pc vs HBR simplified
    if event_detection(15,event_detection_index) == 2 %secondary RCS large
        if event_detection(16,event_detection_index) == 2 %secondary is a debris
            %use median value
            [Pc,~,~,~] = Pc2D_Foster(cdm_list(i).r1,cdm_list(i).v1,cdm_list(i).cov1,cdm_list(i).r2,cdm_list(i).v2,cdm_list(i).cov2,cdm_list(i).HBR,1e-8,'circle');
            %if not then it's either rocket body or payload. Keep using upper bound for them  
        end
    end
end

