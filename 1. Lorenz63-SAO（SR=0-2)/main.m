clc
clear
close all
 tic
repeat_num=15;
take_num=10;
filename = ['opt_SAO_Lorenz63' datestr(now,30) '_' num2str(randi(999)) '.mat'];
%一次优化参数，寻找
[Best_pos,Best_score,SAO_curve]=SAO(repeat_num,take_num);
figure(1)
plot(SAO_curve,'LineWidth',3)
xlabel('Iteration');
ylabel('Fitness');

save(filename)
if ~ispc
    exit;
end
train_r_step_cut = 10000;%截断初始自由演化阶段之后的时间步数，Reservoir 内部状态开始被记录，即热身期长度。
train_r_step_length = 5300;
test_step_length = 1250;
len_washout = 300;%清洗期长度，在这段时间里，网络的内部状态被忽略，以便使网络适应新的输入模式。
inSize=3;
outSize=3;
tmax_timeseries_train = (train_r_step_cut + train_r_step_length + test_step_length)*0.02; %time, for timeseries
traindata=xlsread('1.1lorenz63预测结果记录opt_Lorenz6320230628T163719_343.xlsx','traindata');
lyap_time =xlsread('1.1lorenz63预测结果记录opt_Lorenz6320230628T163719_343.xlsx','lyap_time');
upred_MPA=xlsread('1.1lorenz63预测结果记录opt_Lorenz6320230628T163719_343.xlsx','upred');
utrue=xlsread('1.1lorenz63预测结果记录opt_Lorenz6320230628T163719_343.xlsx','utrue');
prediction=ESN(Best_pos,traindata,inSize,outSize,train_r_step_cut,train_r_step_length,test_step_length,len_washout);

upred_SAO=prediction;
figure(2)
subplot(3,1,1)
plot(lyap_time,utrue(:,1))
hold on
plot(lyap_time,upred_SAO(:,1))
legend('utrue','upred-SAO');
ylabel('x');
title('Lorenz63长期预报结果图')
subplot(3,1,2)
plot(lyap_time,utrue(:,2))
hold on
plot(lyap_time,upred_SAO(:,2))
legend('utrue','upred-SAO');
ylabel('y');
subplot(3,1,3)
plot(lyap_time,utrue(:,3))
hold on
plot(lyap_time,upred_SAO(:,3))
legend('utrue','upred-SAO');
ylabel('z');
xlabel('Time ');
figure(3)
subplot(3,1,1)
plot(lyap_time,utrue(:,1))
hold on
plot(lyap_time,upred_MPA(:,1))
hold on
plot(lyap_time,upred_SAO(:,1))
legend('utrue','upred-MPA','upred-SAO');
ylabel('x');
title('Lorenz63长期预报结果图')
subplot(3,1,2)
plot(lyap_time,utrue(:,2))
hold on
plot(lyap_time,upred_MPA(:,2))
hold on
plot(lyap_time,upred_SAO(:,2))
legend('utrue','upred-MPA','upred-SAO');
ylabel('y');
subplot(3,1,3)
plot(lyap_time,utrue(:,3))
hold on
plot(lyap_time,upred_MPA(:,3))
hold on
plot(lyap_time,upred_SAO(:,3))
legend('utrue','upred-MPA','upred-SAO');
ylabel('z');
xlabel('Time ');

toc