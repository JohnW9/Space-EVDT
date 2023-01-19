% FUNCTION NAME:
%   GetConfig
%
% DESCRIPTION:
%   Setting the tunable parameters of the program using global variables.
%   
%
% INPUT:
%   
% OUTPUT:
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   15/1/2023 - Sina Es haghi
%       * Initial implementation
%
function GetConfig

global config;


%% Conjunction screening volume
config.conjunction_box = [2,25,25];                        % Conjunction box dimensions in RSW directions [km,km,km]
config.moid_distance = 300;                                % MOID threshold for finding relevant objects [km]

%% Propagation properties
config.timestep = 15;                                      % Propagation timestep [sec]
config.cycle_days = 5;                                     % No. of propagation date cycle limiter [days] (This is to avoid RAM overflow)
config.relevent_SO_frequency = 15;                         % Time period for relevant object update [days] (Again uses the MOID function)

%% MOID calculation
config.FirstFilter = config.conjunction_box(1);            % Apogee and Perigee filtering to find the relevant objects efficiently [km] (Only works with secular J2 propagator)
config.Parallel_max_iter = 20;                             % Maximum number of iterations for parallel tuning

%% Mean to True anomaly converter
config.tol = 1e-8;                                         % Function tolerance [rad]
config.maxIter = 10;                                       % Maximum number of iterations for Newton method

%% Conjunction screening
config.screeningBoxMultiplier = ceil(config.timestep/3);   % Conjunction screening volume multiplier
config.fine_prop_timestep = 1;                             % Fine propagation timestep in enlarged screening volume [sec]
config.superfine_prop_timestep = 0.01;                     % Super fine propagation timestep to find the exact time of TCA and the miss distance [sec]
% To add the possibility to switch between box and ellipsoid

%% Conjunction Assessment and Risk Analysis process
config.detection_time = 7;                                 % Number of days prior to an event's TCA when the event is detected by the SSA provider [days]
config.dt_default = 1;                                     % Process simulation default timestep [days] (discrete event simulation fixed timestep)

%% Technology model
config.government_SSA_updateInterval = 1;                  % The minimum time interval between two consecutive observations of the government SSA provider for the same event [days] (Assuming the 2 conjucting space objects are observable at the same time)
config.government_SSA_cov = ...                            % Covariance matrix provided by the government SSA provider [units in km^2 and km^2/s^2]
    diag([0.01^2 0.01^2 0.01^2 0.001^2 0.001^2 0.001^2]);  

config.commercial_SSA_cost = 1;                            % Cost of requesting an observation by the commercial SSA provider [k$]
config.commercial_SSA_availability = 0.8;                  % Availability of commercial SSA data when requested
config.commercial_SSA_updateInterval = 0.2;                % The minimum time interval between two consecutive observations of the commercial SSA provider for the same event [days] (Assuming the 2 conjucting space objects are observable at the same time)
config.commercial_SSA_cov = ...                            % Covariance matrix provided by the commercial SSA provider [units in km^2 and km^2/s^2]
    diag([0.001^2 0.001^2 0.001^2 0.0001^2 0.0001^2 0.0001^2]);  

%% Size and Mass estimation for CDM generation (since RCS values are unavailable)
config.small_dim = 0.1;                                    % Maximum surface dimension of a small RCS object [m]
config.small_mass = 10;                                    % Mass of a small RCS object [kg]

config.medium_dim = 1;                                     % Maximum surface dimension of a medium RCS object [m]
config.medium_mass = 100;                                  % Mass of a medium RCS object [kg]

config.large_dim = 10;                                     % Maximum surface dimension of a large RCS object [m]
config.large_mass = 500;                                   % Mass of a large RCS object [kg]

config.HBRType = 'circle';                                 % Hard Body Radius type input for Pc calculation (Choose between 'circle', 'square', 'squareEquArea')

%% Vulnerability model (Secondary object properties, in case the object is a Payload)
config.small_value = 0.01;                                 % Monetized value of small RCS payload [same units as the NASA EOS values]
config.medium_value = 0.1;                                 % Monetized value of medium RCS payload [same units as the NASA EOS values]
config.large_value =1;                                     % Monetized value of large RCS payload [same units as the NASA EOS values]

%% Decision making model
config.red_event_Pc = 1e-4;                                % Red category Pc threshold
config.yellow_event_Pc = 1e-7;                             % Yellow category Pc theshold
config.red_mitigation_days = 1;                            % Number of days before TCA to take mitigation action [days]

