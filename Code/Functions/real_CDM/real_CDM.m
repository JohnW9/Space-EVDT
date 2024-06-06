%to be used with realistic CDMs
classdef real_CDM
    properties
        Primary_ID
        Secondary_ID
        Creation_time
        Creation_time_sec                   % CDM creation time in seconds (without counting the year)
        TCA                                 
        TCA_sec                             % TCA time in seconds (without counting the year)
        Creat_t_to_TCA                      % Difference between TCA and creation time (given in days)
        Drag_primary
        Drag_secondary
        Pc
        HBR
        Event_number
        Bcoef_primary                       % ballistic coefficient
        Bcoef_secondary

        WRMS_primary                        % weighted RMS value
        WRMS_secondary
        r_vel                               % relative velocity value
        EDR_primary                         % Energy Dissipation Rate
        EDR_secondary
        SRP_primary                         % Solar Radiation Pressure
        SRP_secondary
        Lun_Sol_primary                     % Lunar/Solar effects
        Lun_Sol_secondary
        Earth_Tides_primary
        Earth_Tides_secondary
        LUPI_primary
        LUPI_secondary
        DC_span_primary                     % Differential Correction span
        DC_span_secondary
        DC_residuals_primary
        DC_residuals_secondary

        X_ECI_primary
        Y_ECI_primary
        Z_ECI_primary
        X_DOT_ECI_primary
        Y_DOT_ECI_primary
        Z_DOT_ECI_primary

        X_ECI_secondary
        Y_ECI_secondary
        Z_ECI_secondary
        X_DOT_ECI_secondary
        Y_DOT_ECI_secondary
        Z_DOT_ECI_secondary

        CovUU_primary
        CovUV_primary
        CovUW_primary
        CovVV_primary
        CovVW_primary
        CovWW_primary

        CovUU_secondary
        CovUV_secondary
        CovUW_secondary
        CovVV_secondary
        CovVW_secondary
        CovWW_secondary
      

    end
end