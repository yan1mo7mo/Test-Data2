function f=eq_Lorenz63LE(t,y)
sigma = 10;
rho = 28;
beta = 8/3;
Q=[ y(4), y(7), y(10)
    y(5), y(8), y(11)
    y(6), y(9), y(12) ];
f=zeros(12,1);
f(1)=sigma*(y(2)-y(1));
f(2)=-y(1)*y(3)+rho*y(1)-y(2);
f(3)=y(1)*y(2)-beta*y(3);
Jac=[ -sigma    sigma   0         
      rho-y(3)  -1      -y(1)   
      y(2)      y(1)    -beta ];
f(4:12)=Jac*Q;