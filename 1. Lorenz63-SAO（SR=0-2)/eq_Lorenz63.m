function [dxdt] = eq_Lorenz63(t,x,sigma,rho,beta)
% Lorenz63 model
% t: time
% x: state vector (3 x 1)
% sigma, rho, beta: model parameters
% dx/dt = sigma*(y - x)
% dy/dt = x*(rho - z) - y
% dz/dt = x*y - beta*z
dxdt = [sigma*(x(2)-x(1)); x(1)*(rho-x(3))-x(2); x(1)*x(2)-beta*x(3)];
end