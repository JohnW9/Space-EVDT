function [r_rel, s_rel , w_rel] = Element_rel_distance_rsw (Prop_obj1,Prop_obj2)

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

r_rel = (a1.*(e1.^2-1.0))./(e1.*cos(f1)+1.0)-(a2.*(e2.^2-1.0).*((cos(f1+w1).*sin(raan1)+sin(f1+w1).*cos(i1).*cos(raan1)).*(cos(f2+w2).*sin(raan2)+sin(f2+w2).*cos(i2).*cos(raan2))+(cos(f1+w1).*cos(raan1)-sin(f1+w1).*cos(i1).*sin(raan1)).*(cos(f2+w2).*cos(raan2)-sin(f2+w2).*cos(i2).*sin(raan2))+sin(f1+w1).*sin(f2+w2).*sin(i1).*sin(i2)))./(e2.*cos(f2)+1.0);

s_rel = (a2.*(e2.^2-1.0).*((sin(f1+w1).*cos(raan1)+cos(f1+w1).*cos(i1).*sin(raan1)).*(cos(f2+w2).*cos(raan2)-sin(f2+w2).*cos(i2).*sin(raan2))+(sin(f1+w1).*sin(raan1)-cos(f1+w1).*cos(i1).*cos(raan1)).*(cos(f2+w2).*sin(raan2)+sin(f2+w2).*cos(i2).*cos(raan2))-cos(f1+w1).*sin(f2+w2).*sin(i1).*sin(i2)))./(e2.*cos(f2)+1.0);

w_rel = -(a2.*(e2.^2-1.0).*(-cos(raan1).*sin(i1).*(cos(f2+w2).*sin(raan2)+sin(f2+w2).*cos(i2).*cos(raan2))+sin(i1).*sin(raan1).*(cos(f2+w2).*cos(raan2)-sin(f2+w2).*cos(i2).*sin(raan2))+sin(f2+w2).*cos(i1).*sin(i2)))./(e2.*cos(f2)+1.0);




