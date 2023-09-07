function result=pop_neural_network(xx,p,ODt,environment,i,t_e,num_station,pop_num)
    %=============���룺OD����=======================
    input_1=ODt(:,:,environment(1:t_e)==i);%��Ŀǰ����ʱ���OD����
    if isempty(input_1)==1
        input_1=ODt(:,:,t_e);
    end
    input=reshape(input_1,num_station^2,size(input_1,3));
    %==============�������ʼ��Ⱥ=====================
    output_1=xx(:,:,environment(1:t_e)==i);%��Ŀǰ���е���Ⱥ
    if isempty(output_1)==1
        output_1=xx(:,:,t_e);
    end
    output=reshape(output_1,pop_num*p.V,size(output_1,3));
    

    net{i}=newff(input,output,5,{'logsig','purelin','traingd'});%��������Ԫ����̫����ڴ����
    net{i}.trainParam.goal = 1e-5;
    net{i}.trainParam.epochs = 500;
    net{i}.trainParam.lr = 0.05;
    net{i}.trainParam.showWindow = 0;%�Ƿ�չʾ����
    %net.divideFcn = ''; % �����������ٵ��������Ҫ��������
    
    net{i} = train(net{i},input,output);
    result=net{i};


end