% FUNCTION NAME:
%debris_size_distribution
% Source: ESA's ANNUAL SPACE ENVIRONMENT REPORT
load census;
x1 = 0.1;
y1 = 10^(4.2);
x2= 10^(-0.286);
y2 = 10^(3.7);
x3=1;
y3=10^(3.4);
x4=2;
y4=10^3.2;
x5=10^0.724;
y5=10^2;
x6=10;
y6=10;
average_debris_diameter=(x3*y3+x4*y4+x5*y5+x6*y6)/(y3+y4+5+x6)
x=[x1,x2,x3,x4,x5,x6];
y=[y1,y2,y3,y4,y5,y6];
z=[0:0.1:1];
r= [0.1,0.5,0.8,1,2,3,4,5,6,7,8,9,10];
s= 1600*1./r;
%{
for i = 1:length(r)
   point=1600*log(r(i))+3680;
   cdf(end+1) = point;
end

for j = 0:0.1:1
    point2=exp((j-3680)/1600);
    cdf_inv(end+1) = point2;
end
%}


%cdf_inv = 40./gsqrt(16000-r);
%t=18000*exp(-r);
%f = fit(x, y, 'exp1');
% Define the model function
%model = fittype(@(a, b, x) a ./ x + b, 'independent', 'x', 'dependent', 'y');
%use the manually fitted model, we know b=0 in reality and the value don't
%go to inf at 0

% Fit the model to the data
%fitted_model = fit(x', y', model);

% Plot the graph
%figure;
plot(x, y, 'b-x', 'LineWidth', 1.5, 'MarkerSize', 8); % Plot y1
hold on;
%plot(r,s,"r-o");

%plot(fitted_model, 'r-');
%plot(r,cdf, "g-o")
hold off; % Release the current plot
%plot(z,cdf_inv, "g-x")



xlabel('Debris Diameter [m]');
ylabel('Estimated nb of objects');
title('Debris Size Density Distribution');
grid on;
