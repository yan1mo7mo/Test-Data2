clc
clear 
close all
sigma = 10;
rho = 28;
beta = 8/3;
train_r_step_cut = 10000;%截断初始自由演化阶段之后的时间步数，Reservoir 内部状态开始被记录，即热身期长度。
train_r_step_length = 9600;%用于训练的时间步数的长度，Reservoir 输出被用于训练的时间序列长度。
%train_r_step_length = 115480500;
validate_r_step_length=2250;
len_washout = 300;
tmax_timeseries_train = (train_r_step_cut + train_r_step_length + validate_r_step_length)*0.01;
x0 = randn(3,1);
[t,ts_train] = ode4(@(t,x) eq_Lorenz63(t,x,sigma,rho,beta),...
            0:0.01:tmax_timeseries_train,x0);
ts = t;
[T,RES]=lyapunov(3,'eq_Lorenz63LE',0,0.01,tmax_timeseries_train,x0,1);
lyapunov_RES=RES(end,1:3);
[lorenz_maxlyap,~]=max(lyapunov_RES);


%lyap_time = (predict_ts - predict_ts(1))*(1/lorenz_maxlyap);
%lyap_time = (predict_ts - predict_ts(1))*lorenz_maxlyap;
%lyap_time=predict_ts - predict_ts(1);

lyap_time = (1:1:validate_r_step_length)*0.01*lorenz_maxlyap;
%lyap_time = (1:1:validate_r_step_length)*0.01;
utrue=ts_train(train_r_step_cut+train_r_step_length+1:train_r_step_cut+train_r_step_length+validate_r_step_length,1:3);
figure(1)
subplot(3,1,1)
plot(lyap_time,utrue(:,1))
ylabel('x');
subplot(3,1,2)
plot(lyap_time,utrue(:,2))
ylabel('y');
subplot(3,1,3)
plot(lyap_time,utrue(:,3))
legend('utrue');
ylabel('z');
xlabel('Time ');
