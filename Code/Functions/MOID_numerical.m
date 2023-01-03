function moid = MOID_numerical (Primary, object2,distance)
%% Input setting
if nargin<3
    flag1=0;
else
    flag1=1;
end
%% Rotating the second orbit to the desired reference frame (where i1=0 raan1=0)
R3=[cos(Primary.raan) sin(Primary.raan) 0;...
    -sin(Primary.raan) cos(Primary.raan) 0;...
    0                 0                 1];
R2=[1  0              0;...
    0  cos(Primary.i) sin(Primary.i);...
    0 -sin(Primary.i) cos(Primary.i)];
R1=[cos(Primary.om) sin(Primary.om) 0;...
    -sin(Primary.om) cos(Primary.om) 0;...
    0                 0             1];

R_eci2perifocal=R1*R2*R3;
%% Test
statecar_Primary=par2car([Primary.a Primary.e Primary.i Primary.raan Primary.om M2f(Primary.M,Primary.e)]');
statecar_rotated_Primary=[R_eci2perifocal zeros(3); zeros(3) R_eci2perifocal]*statecar_Primary;
if statecar_rotated_Primary(3)>1e-6
    error("Matrix rotation in MOID is wrong");
end
%%
statecar=par2car([object2.a object2.e object2.i object2.raan object2.om M2f(object2.M,object2.e)]');
statecar_rotated=[R_eci2perifocal zeros(3); zeros(3) R_eci2perifocal]*statecar;
kep = car2par(statecar_rotated);
%% Defining the elements

aA=Primary.a;
eA=Primary.e;

aB=kep(1);
eB=kep(2);
iB=kep(3);
raanB=kep(4);
omB=kep(5);
%% Scanning the orbits
rB=@(v) aB.*(1-eB.^2)./(1+eB.*cos(v));

xB=@(v) rB(v).*(cos(raanB).*cos(omB+v)-sin(raanB).*sin(omB+v).*cos(iB));
yB=@(v) rB(v).*(sin(raanB).*cos(omB+v)+cos(raanB).*sin(omB+v).*cos(iB));
zB=@(v) rB(v).*sin(omB+v).*sin(iB);

rhoB=@(v) sqrt(xB(v).^2+yB(v).^2);

cosL=@(v) xB(v)./rhoB(v);
sinL=@(v) yB(v)./rhoB(v);

rA=@(v) aA.*(1-eA.^2)./(1+eA.*cosL(v));

xA=@(v) rA(v).*cosL(v);
yA=@(v) rA(v).*sinL(v);

D2=@(v) zB(v).^2+(rhoB(v)-rA(v)).^2; % Removing the square

v=0:0.12:2*pi;
D2s = D2(v);
[minD2,index] = min(D2s);

if flag1==1
    if minD2<distance^2
        moid=sqrt(minD2);
        return;
    end
end

%% Parallel Tuning

vmin=v(index);
vminA=vmin;
vminB=vmin;
stepsize=0.06; %[rad]
while stepsize>1e-9

    A=[vminA-stepsize vminA vminA+stepsize];

    B=[vminB-stepsize vminB vminB+stepsize];

    %rA=@(x) [xA(x);yA(x);0];

    %rB=@(x) [xB(x);yB(x);zB(x)];

    %D2_par=zeros(3);

    % for a=1:3
    %     for b=1:3
    %         %D_par(a,b)=norm(rA(A(a))-rB(B(b)));
    %         D2_par(a,b)=(xA(A(a))-xB(B(b))).^2+(yA(A(a))-yB(B(b))).^2+zB(B(b)).^2;
    %     end
    % end

    D2_par=[ (xA(A(1))-xB(B(1))).^2+(yA(A(1))-yB(B(1))).^2+zB(B(1)).^2 , (xA(A(1))-xB(B(2))).^2+(yA(A(1))-yB(B(2))).^2+zB(B(2)).^2 , (xA(A(1))-xB(B(3))).^2+(yA(A(1))-yB(B(3))).^2+zB(B(3)).^2;...
        (xA(A(2))-xB(B(1))).^2+(yA(A(2))-yB(B(1))).^2+zB(B(1)).^2 , (xA(A(2))-xB(B(2))).^2+(yA(A(2))-yB(B(2))).^2+zB(B(2)).^2 , (xA(A(2))-xB(B(3))).^2+(yA(A(2))-yB(B(3))).^2+zB(B(3)).^2;...
        (xA(A(3))-xB(B(1))).^2+(yA(A(3))-yB(B(1))).^2+zB(B(1)).^2 , (xA(A(3))-xB(B(2))).^2+(yA(A(3))-yB(B(2))).^2+zB(B(2)).^2 , (xA(A(3))-xB(B(3))).^2+(yA(A(3))-yB(B(3))).^2+zB(B(3)).^2];


    min_D2_par=min(D2_par,[],"all");
    [a_min,b_min]=find(D2_par==min_D2_par);

    %%ADDITIAL EXIT POINT BY ME
    if abs(minD2-min_D2_par)<1 % Tolerance of 1 km
        minD2=min_D2_par;
        break;
    end

    if min_D2_par>(minD2+1e-6)
        error('Error in calculating MOID');
    else
        minD2=min_D2_par;
    end



    %if a_min==2 && b_min==2
    if ismember(2,a_min) && ismember(2,b_min)
        stepsize=stepsize*0.15;
    else
        vminA=A(a_min);
        vminB=B(b_min);
    end
end
moid=sqrt(minD2);