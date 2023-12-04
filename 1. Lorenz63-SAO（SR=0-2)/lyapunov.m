function [Texp,Lexp]=lyapunov(n,fcn,tstart,tstep,tend,ystart,output)
% Input parameters:
%   n - number of equation
%   fcn - ODE-system.                               
%   tstart - start values of independent value (time t)
%   tstep - step on t-variable for Gram-Schmidt renormalization procedure.
%   tend - finish value of time
%   pstart - start point of trajectory of ODE system
% Output parameters:
%   T - time values
%   Lexp - Lyapunov exponents to each time value.

n1=n; n2=n1*(n1+1);
Z=0;
%  Number of steps

nit = round((tend-tstart)/tstep);

% Memory allocation 

y=zeros(n2,1); cum=zeros(n1,1); y0=y;
gsc=cum; znorm=cum;

% Initial values

y(1:n)=ystart(:);

for i=1:n1   y((n1+1)*i)=1.0; end;

t=tstart;

% Main loop

for ITERLYAP=1:nit

% Solutuion of extended ODE system 
  [T,Y] = ode45(fcn,[t t+tstep],y);
  t=t+tstep;
  y=Y(size(Y,1),:);

  for i=1:n1 
      for j=1:n1  y0(n1*i+j)=y(n1*j+i); end;
  end;

%
%       construct new orthonormal basis by gram-schmidt
%

  znorm(1)=0.0;
  for j=1:n1  znorm(1)=znorm(1)+y0(n1*j+1)^2; end;

  znorm(1)=sqrt(znorm(1));

  for j=1:n1  y0(n1*j+1)=y0(n1*j+1)/znorm(1); end;

  for j=2:n1
      for k=1:(j-1)
          gsc(k)=0.0;
          for l=1:n1 gsc(k)=gsc(k)+y0(n1*l+j)*y0(n1*l+k); end;
      end;
 
      for k=1:n1
          for l=1:(j-1)
              y0(n1*k+j)=y0(n1*k+j)-gsc(l)*y0(n1*k+l);
          end;
      end;

      znorm(j)=0.0;
      for k=1:n1 znorm(j)=znorm(j)+y0(n1*k+j)^2; end;
      znorm(j)=sqrt(znorm(j));

      for k=1:n1 y0(n1*k+j)=y0(n1*k+j)/znorm(j); end;
  end;

%
%       update running vector magnitudes
%

  for k=1:n1 cum(k)=cum(k)+log(znorm(k)); end;

%
%       normalize exponent
%

  for k=1:n1 
      lp(k)=cum(k)/(t-tstart); 
  end;

% Output modification

  if ITERLYAP==1
     Lexp=lp;
     Texp=t;
  else
     Lexp=[Lexp; lp];
     Texp=[Texp; t];
  end;
  if(mod(ITERLYAP,output)==0)
    fprintf('t=%6.4f',t);
    for k=1:n1 
        fprintf(' %10.6f',lp(k)); 
    end;
    fprintf('\n');
  end
  for i=1:n1 
      for j=1:n1
          y(n1*j+i)=y0(n1*i+j);
      end;
  end;

end;