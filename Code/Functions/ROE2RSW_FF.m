function [r_rel, s_rel , w_rel] = ROE2RSW_FF (Prop_obj1,Prop_obj2)

a1=Prop_obj1.ma;
e1=Prop_obj1.me;
i1=Prop_obj1.mi;
raan1=Prop_obj1.mraan;
w1=Prop_obj1.mom;
M1=Prop_obj1.M;

a2=Prop_obj2.ma;
e2=Prop_obj2.me;
i2=Prop_obj2.mi;
raan2=Prop_obj2.mraan;
w2=Prop_obj2.mom;
M2=Prop_obj2.M;

f1=M2f(M1,e1);
f2=M2f(M2,e2);

ex1=e1.*cos(w1);
ey1=e1.*sin(w1);
u1=w1+f1;

ex2=e2.*cos(w2);
ey2=e2.*sin(w2);
u2=w2+f2;

da=a2-a1;
dex=ex2-ex1;
dey=ey2-ey1;
di=i2-i1;
draan=raan2-raan1;
du=u2-u1;

%% Assuming distance<<r_target  in LVLH frame

dx = a1.*(1-(ex1.*cos(u1)+ey1.*sin(u1))).*(du+draan.*cos(i1)+2.*(ex1.*cos(u1)+ey1.*sin(u1)).*du+2.*(dex.*sin(u1)-dey.*cos(u1)));
dy = a1.*(1-(ex1.*cos(u1)+ey1.*sin(u1))).*((draan.*sin(i1).*cos(u1)-di.*sin(u1))+(ey1.*di-ex1.*draan.*sin(i1)));
dz = da.*(ex1.*cos(u1)+ey1.*sin(u1)-1)+a1.*(ey1.*cos(u1)-ex1.*sin(u1)).*du+a1.*(dex.*cos(u1)+dey.*sin(u1));

%% Convert to RSW

r_rel=-dz;
s_rel=dx;
w_rel=-dy;
