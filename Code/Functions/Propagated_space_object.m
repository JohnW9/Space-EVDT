classdef Propagated_space_object
    properties
        name        % Name of the object
        id          % NORAD ID
        epoch       % Epoch in mjd2000
        final_time  % Final time in mjd2000
        timestep    % time step [s]
        type        % Space object tupe (PAYLOAD/ROCKET BODY/DEBRIS)
        RCS         % Radar Cross Section category (LARGE/MEDIUM/SMALL)
        B_star      % B* value for SWTS
        %%Time ticks
        t           % Time tick N*[mjd2000]
        %%ECI
        rx          % Cartesian rx N*[km]
        ry          % Cartesian ry N*[km]
        rz          % Cartesian rz N*[km]
        vx          % Cartesian vx N*[km/s]
        vy          % Cartesian vy N*[km/s]
        vz          % Cartesian vz N*[km/s]
        %%Keplerian
        a           % Semi-major axis [km]
        e           % Eccentricity
        i           % Inclination [rad]
        raan        % Right ascension of ascending node [rad]
        om          % Argument of perigee [rad]
        f           % True anomaly [rad]
        %%Mean Keplerian
        ma          % Mean Semi-major axis [km]
        me          % Mean Eccentricity
        mi          % Mean Inclination [rad]
        mraan       % Mean Right ascension of ascending node [rad]
        mom         % Mean Argument of perigee [rad]
        M           % Mean anomaly [rad]
    end
end