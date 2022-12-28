function [X, Y, Z, Vx, Vy, Vz] = par2car_vect (a, e, i, raan, om, f)
%--------------------------------------------------------------------------------------------------------%
%
% 			USAGE: Conversion of Keplerian Classic Orbital Elements into geocentric-equatorial reference system OXYZ
%
% 			AUTHOR: Thameur Chebbi(PhD)		E-MAIL: chebbythamer@gmail.com
%
% 			DATE: 01,Oct,2020
%
% 			DESCIPTION:      This function is created to convert the classical 
%               		     orbital elements to cartesian position and velocity 
%		       		         parameters of any satellite orbit in the geocentric-equatorial
%                            reference system.
%
% 			INPUT:
% 			alt:    Altitude.....................(Km)							
% 			ecc:    Eccentricity											    
% 			inc:	Inclination..................(rad)							
% 			w:	    Argument of perigee..........(rad)	
% 			nu:	    Satellite position...........(rad)							
% 			RAAN:	Right Asc. of Ascending Node.(rad)							
%
% 			OUTPUT:
%			Position Components: 		
% 			[X Y Z]...(Km)
%
%			Velocity Components:
% 			[Vx Vy Vz]...(Km/s) 														
%
%
%%---------------------------- Constants ----------------------------------------------%
%mu_earth = astroConstants(13);
mu_earth = 3.986004330000000e+05;
%
%%--------------------------------------------------------------------------------------
p = a.*(1-e.^2);
r_0 = p ./ (1 + e .* cos(f));
%
%%--------------- Coordinates in the perifocal reference system Oxyz -----------------%
%
% position vector coordinates
x = r_0 .* cos(f);
y = r_0 .* sin(f);
%
%
% velocity vector coordinates
Vx_ = -(mu_earth./p).^(1/2) .* sin(f);
Vy_ = (mu_earth./p).^(1/2) .* (e + cos(f));
%
%
%%-------------- the geocentric-equatorial reference system OXYZ ---------------------%
%
% position vector components X, Y, and Z
X = (cos(raan) .* cos(om) - sin(raan) .* sin(om) .* cos(i)) .* x + (-cos(raan) .* sin(om) - sin(raan) .* cos(om) .* cos(i)) .* y;
Y = (sin(raan) .* cos(om) + cos(raan) .* sin(om) .* cos(i)) .* x + (-sin(raan) .* sin(om) + cos(raan) .* cos(om) .* cos(i)) .* y;
Z = (sin(om) .* sin(i)) .* x + (cos(om) .* sin(i)) .* y;
% velocity vector components X', Y', and Z'
Vx = (cos(raan) .* cos(om) - sin(raan) .* sin(om) .* cos(i)) .* Vx_ + (-cos(raan) .* sin(om) - sin(raan) .* cos(om) .* cos(i)) .* Vy_;
Vy = (sin(raan) .* cos(om) + cos(raan) .* sin(om) .* cos(i)) .* Vx_ + (-sin(raan) .* sin(om) + cos(raan) .* cos(om) .* cos(i)) .* Vy_;
Vz = (sin(om) .* sin(i)) .* Vx_ + (cos(om) .* sin(i)) .* Vy_;
