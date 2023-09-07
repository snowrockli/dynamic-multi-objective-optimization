function result=pop_neural_network(xx,p,ODt,environment,i,t_e,num_station,pop_num)
    %=============输入：OD需求=======================
    input_1=ODt(:,:,environment(1:t_e)==i);%到目前所有时间的OD需求
    if isempty(input_1)==1
        input_1=ODt(:,:,t_e);
    end
    input=reshape(input_1,num_station^2,size(input_1,3));
    %==============输出：初始种群=====================
    output_1=xx(:,:,environment(1:t_e)==i);%到目前所有的种群
    if isempty(output_1)==1
        output_1=xx(:,:,t_e);
    end
    output=reshape(output_1,pop_num*p.V,size(output_1,3));
    

    net{i}=newff(input,output,5,{'logsig','purelin','traingd'});%隐含层神经元数量太多会内存溢出
    net{i}.trainParam.goal = 1e-5;
    net{i}.trainParam.epochs = 500;
    net{i}.trainParam.lr = 0.05;
    net{i}.trainParam.showWindow = 0;%是否展示窗口
    %net.divideFcn = ''; % 对于样本极少的情况，不要再三分了
    
    net{i} = train(net{i},input,output);
    result=net{i};


end