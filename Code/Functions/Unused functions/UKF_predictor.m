%% Unscented Kalman Predictor
% t is amount of propagation time in days
% covariances should be in ECI
function [state_f, cov_f]  = UKF_predictor (state_i, cov_i, t)
%% Choosing sigma points
N = size(cov_i,1); % No. of dimensions
L = chol(cov_i,"lower"); % Cholesky decomposition
k = 3-N;
miu = state_i;
if size(miu,1)==1
    miu = miu';
end
x = miu*ones([1 2*N+1]) + [zeros([N,1]) sqrt(N+k)*L -sqrt(N+k)*L]; % Each column is a sigma point
%% Transforming and recombining
y = zeros([N,2*N+1]);
mean_sum = zeros([N,1]);
cov_sum = zeros([N,N]);
for i = 1:2*N+1
    x_i = x(:,i);
    y_i =  TwoBP_J2_analytic_car_state (x_i,t);
    y(:,i) = y_i;
    if i == 1
        alpha_i = k/(N+k);
    else
        alpha_i = 0.5/(N+k);
    end
    mean_sum = mean_sum + alpha_i*y_i;
end

for i = 1:2*N+1
    if i == 1
        alpha_i = k/(N+k);
    else
        alpha_i = 0.5/(N+k);
    end
    cov_sum = cov_sum + alpha_i * (y(:,i)-mean_sum) * (y(:,i)-mean_sum)';
end

state_f = mean_sum;
cov_f = cov_sum;

end

