function [prediction] = ESN(param,data,inSize,outSize,train_r_step_cut,train_r_step_length,test_step_length,len_washout)
inSize   = inSize;
outSize  = outSize;
data=data(train_r_step_cut+1:end,1:3);
trainLen = train_r_step_length;
predictionlen=test_step_length;
initLen=len_washout;

IS=param(1);       %输入尺度——input scale
SR=param(2);       %谱半径——spectral radius
gamma=param(3);    %漏积分——leakage rate
resSize=param(4);  %储备池大小——reservoir size
resSize=round(resSize);
degree=param(5);   %储备池中相连接的神经元数目average indegree

beta=1e-8;     %正则化因子——output regularization factor
rand( 'seed', 42 );
Win = IS*(-1 + 2*rand(resSize,1+inSize));%输入矩阵Win服从【-IS,IS】的均匀分布，负责调节输入信号的尺度。由此产生的矩阵Win将有resSize的行和inSize的列。
                                       %矩阵中的每个元素将是一个介于-1和1之间的随机值，因为标量值-1 + 2*rand(resSize,inSize)将生成一个介于0和1之间
                                       %的随机值矩阵，然后将其缩放并移到-1到1的范围内。
sparsity = degree/resSize;
W= sprand(resSize,resSize,sparsity);%得到的矩阵W将有resSize的行和resSize的列，稀疏度为sparsity。
                                    %矩阵的稀疏性被定义为零元素的数量与矩阵中元素总数的比率。
e = max(abs(eigs(W)));
Wres = (W./e).*SR;


% allocated memory for the design (collected states) matrix【为设计(收集状态)矩阵分配内存
X = zeros(1+inSize+resSize,trainLen-initLen);

% set the corresponding target matrix directly【直接设置相应的目标矩阵】
%Yt=data(initLen+2:trainLen+1)';%原程序
Yt=data(initLen+1:trainLen,1:3)';

% run the reservoir with the data and collect X【使用数据运行储层并收集X】
x = zeros(resSize,1);
for t = 1:trainLen-1
	u = data(t,1:outSize)';
	x = (1-gamma)*x + gamma*tanh( Win*[vertcat(1,u)] + Wres*x);
	if t >=initLen
		X(:,t-initLen+1) = [vertcat(1,u,x)];
    end 
end
Wout = ((X*X' + beta*eye(1+inSize+resSize)) \ (X*Yt'))'; 

Y_verification = zeros(predictionlen,outSize);
u=data(trainLen,1:outSize)';

for t = 1:predictionlen
    x = (1-gamma)*x + gamma*tanh( Win*[vertcat(1,u)] + Wres*x);
    y = Wout*[vertcat(1,u,x)];
    Y_verification(t,1:outSize)=y';
    u = y;
end

y_true = data(trainLen+1:trainLen+predictionlen,1:outSize);%这个对比是从训练结束后，输入第trainLen+1为第一个数，预测trainLen+2，然后一直预测到trainLen+errorLen+1，然后计算RMSE
y_pred = Y_verification;

prediction=y_pred;
end