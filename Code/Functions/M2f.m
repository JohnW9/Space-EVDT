%% Vectorized Newton raphson for M2E

function [f,E_out] = M2f(M,e,tol,E0)

max_iter=10;

%% M2E
if nargin == 2
    tol=1e-8;
    E0=M;
elseif nargin == 3
    E0=M;
end

func  = @(E) E - e.* sin(E) - M;
dfunc = @(E) 1 - e.* cos(E);

Ei=E0;
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