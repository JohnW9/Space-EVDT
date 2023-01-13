% FUNCTION NAME:
%   M2f
%
% DESCRIPTION:
%   This function converts an array of Mean anomalies to True anomalies using the Newton method.
%   
%
% INPUT:
%   M = [N] Array of Mean anomalies [rad]
%   e = [1x1] or [N] Eccentricity
%   tol = [1x1] Accepted tolerance for values of true anomaly [rad]
%   
% OUTPUT:
%   f = [N] Array of True anomalies [rad]
%   E_out = [N] Array of Eccentric anomalies [rad]
%
% ASSUMPTIONS AND LIMITATIONS:
% If the value doesn't converge before 10 iterations, the function displays an error.
%
%
% REVISION HISTORY:
%   Dates in DD/MM/YYYY
%
%   11/1/2023 - Sina Es haghi
%       * Adding header
%
function [f,E_out] = M2f(M,e,tol)

max_iter=10;

%% M2E
if nargin == 2
    tol=1e-8;
end
func  = @(E) E - e.* sin(E) - M;
dfunc = @(E) 1 - e.* cos(E);

Ei=M;
max_tol=max(abs(func(Ei)));

iter = 0;

while max_tol>tol && iter<max_iter

    Ef=Ei-func(Ei)./dfunc(Ei);
    max_tol=max(abs(func(Ef)));
    Ei=Ef;
    iter=iter+1;
end

if iter == max_iter
    disp('Newton method failed');
end

E=Ei;

%% E2f
sqre=sqrt((1+e)./(1-e));
f  = 2 .* atan( tan(E./2) .* sqre);

if nargout>1
    E_out=E;
end

end