% FUNCTION NAME:
%   Manual_process_TLE
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
% ASSUMPTIONS AND LIMITATIONS:
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   06/05/2024 - Jonathan Wei
%       * Header added

function [cdm_list,action_det]=Manual_process_TLE (event_detection,cdm_list,i,event_detection_index)
config = GetConfig;


    %Pc vs HBR simplified
    if event_detection(15,event_detection_index) == 2 %secondary RCS large
        if event_detection(16,event_detection_index) == 2 %secondary is a debris

            average_value = 1.5349; %from debris_size_distribution.m
            new_HBR = (cdm_list(i).HBR-config.large_dim+average_value)*1e-3; % replace upper bound by median value
            %new_HBR  in [km]

            %% Conversion to ECI at TCA
            % Object 1
            [T1_rsw2eci,~] = ECI2RSW(cdm_list(i).r1,cdm_list(i).v1); % Notations taken from chen's book
            J1_rsw2eci=[T1_rsw2eci zeros(3);zeros(3) T1_rsw2eci];
            P1 = J1_rsw2eci * cdm_list(i).cov1 * J1_rsw2eci';
            
            % Object 2
            [T2_rsw2eci,~] = ECI2RSW(cdm_list(i).r2,cdm_list(i).v2);
            J2_rsw2eci=[T2_rsw2eci zeros(3);zeros(3) T2_rsw2eci];
            P2 = J2_rsw2eci * cdm_list(i).cov2 * J2_rsw2eci';
            
            %old_Pc = cdm_list(i).Pc*1e3;

            [new_Pc,~,~,~] = Pc2D_Foster(cdm_list(i).r1',cdm_list(i).v1',P1,cdm_list(i).r2',cdm_list(i).v2',P2,new_HBR,1e-8,'circle');
            
            %cdm_list(i).Pc = Pc;
            if new_Pc < config.red_event_Pc
                action_det = "yellow Pc from Pc vs HBR";
            else
                action_det = "red Pc";
            end
        else
            action_det = "red Pc"; %if rocket body or payload. Keep using upper bound
        end
    else
        action_det = "red Pc";
    end

 

 %MTS - TODO
%{
% Visualize the orbit and positions


 if action_det == "red PC" % to change
     %compute the orbital parameters of the new orbit based on a maneuver at TCA-x
     r1_TCA = cdm_list(i).r1;
     v1_TCA = cdm_list(i).v1;
     %propagate it forward to TCA and screen for conjunctions meanwhile
     epoch=event_detection(14,event_detection_index); %TCA in [mjd2000]
     
     [event_list,Relevant_object_list] = Event_detection_MTS(orbital_elements,cdm_list,cdm_index,space_cat,epoch,no_days,event_list);
 end
%}
end

