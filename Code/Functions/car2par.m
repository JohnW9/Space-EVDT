function state_kep = car2par(state_car)
%% Orbital mechanics course A.Y. 2020/2021
% Developed by: Group 37
% Sina Es haghi       10693213
% Giulia Sala         10582449
% Valerio Santolini   10568153
% Pietro Zorzi        10607053
%
% PROTOTYPE:
% [a_or_kep, e_or_hh, i, OM, om, th, hh] = car2par(rr, vv, mu)
%% This function will compute the keplerian parameters from the cartesian ones in the ECI reference frame
% Inputs:
% state [6x1] = [r;v]

% Outputs:
% kep [6x1] Keplerian parameters [km;-;rad;rad;rad;rad] `

%mu=astroConstants(13);
mu= 3.986004330000000e+05;
state_car=state_car';
rr=state_car(1:3);
vv=state_car(4:6);
r=norm(rr);
v=norm(vv);
E=0.5.*(v.^2)-mu./r;
a=(-0.5).*mu/E;
hh=cross(rr,vv);
h=norm(hh);
ee=cross(vv,hh)./mu - rr./r;
e=norm(ee);
i=acos(hh(3)./h);
NN=cross([0,0,1],hh);
if NN(:)==0
    NN=[0 0 0];
else
NN=(cross([0,0,1],hh))./(norm(cross([0,0,1],hh)));
end
if NN(2)>0
    OM=acos(NN(1));
else
    OM=2.*pi-acos(NN(1));
end
if ee(3)>0
    om=acos(dot(NN,ee)./e);
else
    om=2.*pi-acos(dot(NN,ee)./e);
end
vr=dot(vv,rr)./r;
if vr>0
    %th=acos(dot(rr,ee)./(r.*e));
    th=acos(dot(rr,ee)/(r*e));
%     if dot(rr,ee)./(r.*e)==1
%         th=0;
%     end
else
    %th=2.*pi-acos(dot(rr,ee)./(r.*e));
    th=2.*pi-acos(dot(rr,ee)/(r*e));
%     if dot(rr,ee)./(r.*e)==1
%         th=0;
%     end
end
a=real(a);
e=real(e);
i=real(i);
OM=real(OM);
om=real(om);
th=real(th);
state_kep=[a;e;i;OM;om;th];
% switch nargout
%     case 1
%         a_or_kep=[a e i OM om th]';
%     case 2
%         a_or_kep=[a e i OM om th]';
%         e_or_hh=hh';
%     otherwise
%         a_or_kep=a;
%         e_or_hh=e;
% end
return