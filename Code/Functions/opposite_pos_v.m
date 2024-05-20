% FUNCTION NAME:
%   opposite_pos_v
%
% DESCRIPTION:
%   Given a position and velocity vector in the ECI frame, this function
%   computes the opposite position and velocity wrt the same orbit.
%   
%
% INPUT:
%   r1 = [3x1] The position vector of the space object in ECI [km;km;km]
%   v1 = [3x1] The velocity vector of the space object in ECI [km/s;km/s;km/s]
%   
% OUTPUT:
%   ropp_ECI = The opposite position vector in ECI
%   vopp_ECI = The opposite velocity vector in ECI
%
% ASSUMPTIONS AND LIMITATIONS:
%
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   20/5/2024 - Jonathan
%       * Adding header
%


function [ropp_ECI, vopp_ECI] = opposite_pos_v(r1, v1)

 
    mu= 3.986004330000000e+05; % Earth's gravitational parameter, km^3/s^2

    % Calculate specific angular momentum
    h = cross(r1, v1);
    h_norm = norm(h);

    % Calculate eccentricity vector
    e = (1/mu) * ((norm(v1)^2 - mu/norm(r1)) * r1 - dot(r1, v1) * v1);
    e_norm = norm(e);

    % Calculate semi-major axis
    a = h_norm^2 / (mu * (1 - e_norm^2));

    % Calculate inclination
    i = acos(h(3) / h_norm);

    % Calculate right ascension of ascending node (RAAN)
    n = cross([0 0 1], h);
    n_norm = norm(n);
    if n_norm ~= 0
        Omega = acos(n(1) / n_norm);
        if n(2) < 0
            Omega = 2*pi - Omega;
        end
    else
        Omega = 0;
    end

    % Calculate argument of periapsis
    if e_norm ~= 0
        omega = acos(dot(n, e) / (n_norm * e_norm));
        if e(3) < 0
            omega = 2*pi - omega;
        end
    else
        omega = 0;
    end

    % Calculate true anomaly
    nu1 = acos(dot(e, r1) / (e_norm * norm(r1)));
    if dot(r1, v1) < 0
        nu1 = 2*pi - nu1;
    end

    % Opposite true anomaly
    nu2 = mod(nu1 + pi, 2*pi);

    % Compute position vector in perifocal frame
    r2_perifocal = (a * (1 - e_norm^2)) / (1 + e_norm * cos(nu2)) * [cos(nu2); sin(nu2); 0];

    % Compute velocity vector in perifocal frame
    p = a * (1 - e_norm^2);
    v2_perifocal = sqrt(mu / p) * [-sin(nu2); e_norm + cos(nu2); 0];

    % Transformation matrix from perifocal to ECI
    Q = [cos(Omega)*cos(omega) - sin(Omega)*sin(omega)*cos(i), -cos(Omega)*sin(omega) - sin(Omega)*cos(omega)*cos(i), sin(Omega)*sin(i);
         sin(Omega)*cos(omega) + cos(Omega)*sin(omega)*cos(i), -sin(Omega)*sin(omega) + cos(Omega)*cos(omega)*cos(i), -cos(Omega)*sin(i);
         sin(omega)*sin(i), cos(omega)*sin(i), cos(i)];

    % Transform to ECI frame
    ropp_ECI = Q * r2_perifocal;
    vopp_ECI = Q * v2_perifocal;

    % Display results
    disp('Opposite Position Vector (ECI):');
    disp(ropp_ECI);

    disp('Opposite Velocity Vector (ECI):');
    disp(vopp_ECI);

    % Plot the orbit
    figure;
    hold on;
    grid on;
    axis equal;

    % Generate points along the orbit
    theta = linspace(0, 2*pi, 1000);
    r_orbit = (a * (1 - e_norm^2)) ./ (1 + e_norm * cos(theta));
    r_orbit_perifocal = [r_orbit .* cos(theta); r_orbit .* sin(theta); zeros(1, length(theta))];

    % Transform orbit points to ECI frame
    r_orbit_ECI = Q * r_orbit_perifocal;

    % Plot the orbit
    plot3(r_orbit_ECI(1, :), r_orbit_ECI(2, :), r_orbit_ECI(3, :), 'b');

    % Plot the given and computed positions
    plot3(r1(1), r1(2), r1(3), 'ro', 'MarkerSize', 10, 'DisplayName', 'Given Position');
    plot3(ropp_ECI(1), ropp_ECI(2), ropp_ECI(3), 'go', 'MarkerSize', 10, 'DisplayName', 'Opposite Position');

    % Add labels and legend
    xlabel('X (km)');
    ylabel('Y (km)');
    zlabel('Z (km)');
    title('Orbital Visualization');
    legend;

    hold off;
end