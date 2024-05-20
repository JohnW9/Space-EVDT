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

function [cdm_list,action_det]=Manual_process (event_detection,cdm_list,i, event_detection_index)
config = GetConfig;

TLE_input_mode=1;
if TLE_input_mode
    %Pc vs HBR simplified
    %if event_detection(15,event_detection_index) == 2 %secondary RCS large
        %if event_detection(16,event_detection_index) == 2 %secondary is a debris
            %use median value
            dim1 = 0.217; %average value following the distribution from debris_size distribution
            median_value = 3.91; %% TO CHANGE
            new_HBR = cdm_list(i).HBR-config.large_dim+median_value; % replace upper bound by median value
            [Pc,~,~,~] = Pc2D_Foster(cdm_list(i).r1',cdm_list(i).v1',cdm_list(i).cov1,cdm_list(i).r2',cdm_list(i).v2',cdm_list(i).cov2',new_HBR,1e-8,'circle');
            %if not then it's either rocket body or payload. Keep using upper bound for them 
            %cdm_list(i).Pc = Pc;
            if Pc < config.red_event_Pc
                action_det = "yellow Pc from MP";
            %end
        %end
    end
action_det = "placeholder" %for debugging

    %Space Weather Trade Space
    if cdm_list(i).Pc < config.red_event_Pc && cdm_list(i).Pc > config.red_event_Pc/10 %close to limit
           % if cdm_list(i).B_star > threshold
            %    action_det = "high"
           % end
        end
 
        %B_star

 %MTS

% Visualize the orbit and positions


 %if action_det == "red PC" % to change
     %compute the orbital parameters of the new orbit based on a maneuver at TCA-x
     r1_TCA = cdm_list(i).r1;
     v1_TCA = cdm_list(i).v1;
     [ropp,vopp] = opposite_pos_v(r1_TCA, v1_TCA);
     %propagate it forward to TCA and screen for conjunctions meanwhile
     [event_list,Relevant_object_list] = Event_detection (eos(eos_sat),space_cat,epoch,no_days,event_list);
 %end
    end
end

