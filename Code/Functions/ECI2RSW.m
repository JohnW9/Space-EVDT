function [T_rsw2eci,T_eci2rsw] = ECI2RSW(r,v)
if size(r,1)==1; r=r'; end
if size(v,1)==1; v=v'; end
R=r/norm(r);
W=cross(r,v)/norm(cross(r,v));
S=cross(W,R);
T_rsw2eci=[R S W];
T_eci2rsw=T_rsw2eci';
end

