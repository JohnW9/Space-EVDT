%% True to Mean anomaly converter
% All radians
function M=f2M (f,e)
E=2.*atan(tan(f./2).*sqrt((1-e)./(1+e)));
M=E-e.*sin(E);
M=mod(M,2*pi);
end