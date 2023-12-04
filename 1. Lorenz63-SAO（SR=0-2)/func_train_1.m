function [mae,ts_train]= func_train_1(hyperpara_set)
inSize   = 3;
outSize  = 3;
IS=hyperpara_set(1,1);       %输入尺度——input scale
SR=hyperpara_set(1,2);       %谱半径——spectral radius
gamma=hyperpara_set(1,3);    %漏积分——leakage rate
resSize=hyperpara_set(1,4);  %储备池大小——reservoir size
resSize=round(resSize);
degree=hyperpara_set(1,5);   %储备池中相连接的神经元数目average indegree

rand( 'seed', 42 );

sigma_lorenz6 = 10;
rho_lorenz6 = 28;
beta_lorenz63 = 8/3;

%其中，热身期是为了让 Reservoir 的内部状态逐渐趋近于稳定并能够产生有用的信号，用于之后的训练和验证。
%清洗期是为了清除热身期中的噪声，并确保 Reservoir 能够适应新的输入信号。
%训练期和验证期则是将 Reservoir 在已知输入情况下产生的输出与期望输出进行比较，以优化输出层参数。
%加上额外的缓冲区时间，可以使计算更加准确和可靠。
train_r_step_cut = 10000;%截断初始自由演化阶段之后的时间步数，Reservoir 内部状态开始被记录，即热身期长度。
train_r_step_length = 5300;%用于训练的时间步数的长度，Reservoir 输出被用于训练的时间序列长度。
%validate_r_step_length = 1250;%用于验证的时间步数的长度，Reservoir 输出被用于验证的时间序列长度。
validate_r_step_length = 1000;
len_washout = 300;%清洗期长度，在这段时间里，网络的内部状态被忽略，以便使网络适应新的输入模式。

tmax_timeseries_train = (train_r_step_cut + train_r_step_length + validate_r_step_length)*0.02; %time, for timeseries
%% preparing training data

train_data_length = train_r_step_length + validate_r_step_length;
train_data = zeros(train_data_length,inSize); % data that goes into reservior_training
ts_train = NaN;
while  sum(sum(isnan(ts_train))) 
    x0 = randn(3,1);
    [t,ts_train] = ode4(@(t,x) eq_Lorenz63(t,x,sigma_lorenz6,rho_lorenz6,beta_lorenz63),...
            0:0.02:tmax_timeseries_train,x0);
end
%% train
[mae] = op_ESN(hyperpara_set,ts_train,inSize,outSize,train_r_step_cut,train_r_step_length,validate_r_step_length,len_washout);
disp( ['mae = ', num2str(mae)] );