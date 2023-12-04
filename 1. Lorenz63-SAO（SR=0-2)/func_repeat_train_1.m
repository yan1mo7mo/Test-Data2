function mean_mae = func_repeat_train_1(hyperpara_set,repeat_num,take_num)


mae_set = zeros(repeat_num,1);
parfor repeat_i = 1:repeat_num
    %在使用普通的for循环时，由于没有进行并行计算，每次循环都必须等待上一次循环结束，所以循环速度较慢。
    % 而使用parfor循环则可以充分利用多核CPU的计算能力，提高程序的运行效率
    rng('default') 
    rng(repeat_i*20000 + (now*1000-floor(now*1000))*100000)
    [mae,traindata]=func_train_1(hyperpara_set); 
    mae_set(repeat_i) = mae; 
end

mae_set = sort(mae_set);
mae_set = mae_set(1:take_num);

mean_mae = mean(mae_set);
fprintf('\nmean mae is %f\n',mean_mae)

end

