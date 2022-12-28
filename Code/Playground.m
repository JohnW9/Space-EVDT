%% Playground

clc;
clear;

syms a1 e1 i1 raan1 w1 f1;
syms a2 e2 i2 raan2 w2 f2;

R3=@(x) [cos(x) sin(x) 0;...
        -sin(x) cos(x) 0;...
         0      0      1];
R1=@(x) [1      0      0     ;...
         0      cos(x) sin(x);...
         0     -sin(x) cos(x)];

T_rsw2eci = @(raan,i,w,f) R3(-raan)*R1(-i)*R3(-(w+f));
T_eci2rsw = @(raan,i,w,f) R3(w+f)*R1(i)*R3(raan);

r1 = a1*(1-e1^2)/(1+e1*cos(f1));

r2 = a2*(1-e2^2)/(1+e2*cos(f2));

r1_rsw1 = [r1;0;0];
r2_rsw1 = T_eci2rsw(raan1,i1,w1,f1)*T_rsw2eci(raan2,i2,w2,f2)*[r2;0;0];

x_rel_rsw1=r2_rsw1(1)-r1_rsw1(1);
y_rel_rsw1=r2_rsw1(2)-r1_rsw1(2);
z_rel_rsw1=r2_rsw1(3)-r1_rsw1(3);


x_rel_rsw_func = matlabFunction(x_rel_rsw1,'Vars',[a1 e1 i1 raan1 w1 f1 a2 e2 i2 raan2 w2 f2]);
y_rel_rsw_func = matlabFunction(y_rel_rsw1,'Vars',[a1 e1 i1 raan1 w1 f1 a2 e2 i2 raan2 w2 f2]);
z_rel_rsw_func = matlabFunction(z_rel_rsw1,'Vars',[a1 e1 i1 raan1 w1 f1 a2 e2 i2 raan2 w2 f2]);

%%

origin=[0,0,0];
s1=10; s2=20; s3=5;
semi_axes=[s1,s2,s3];

l=1000;
x_var=zeros(1,l);
y_var=zeros(1,l);
z_var=zeros(1,l);

ind_in=0;
outer_in=0;

inner=zeros(3,l);
outer=zeros(3,l);

for n=1:l
    randomvars=[s1 s2 s3].*(rand(1,3).*2-[1 1 1]);
    x_var(n)=randomvars(1);
    y_var(n)=randomvars(2);
    z_var(n)=randomvars(3);
    if randomvars(1)^2/s1^2+randomvars(2)^2/s2^2+randomvars(3)^2/s3^2<1
        ind_in=ind_in+1;
        inner(:,ind_in)=randomvars';
    elseif randomvars(1)^2/s1^2+randomvars(2)^2/s2^2+randomvars(3)^2/s3^2>1
        outer_in=outer_in+1;
        outer(:,outer_in)=randomvars';
    end
end
inner(:,ind_in+1:end)=[];
outer(:,outer_in+1:end)=[];


[X,Y,Z]=ellipsoid(origin(1),origin(2),origin(3),semi_axes(1),semi_axes(2),semi_axes(3));

figure()
hold on
plot3(inner(1,:),inner(2,:),inner(3,:),'ob');
plot3(outer(1,:),outer(2,:),outer(3,:),'*r');
surf(X,Y,Z,'LineStyle','none');
alpha 0.2;
view(3);
axis equal