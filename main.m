%====================分时差异化票价动态多目标优化================
clc
clear 
close all
ODt(:,:,1)=xlsread('OD.xlsx','real_demand');%初始OD需求矩阵
TT=xlsread('OD.xlsx','real_travel_time');%站点间运行时间矩阵
TF=xlsread('OD.xlsx','real_transfer');%换乘信息
[num_station,~]=size(ODt(:,:,1));%站点数量
pop_num=20;%种群数量
gen=3;%算法迭代步数
M=5;%每天5个出发时刻
for t_e=1:gen%OD需求动态变化
    if mod(t_e,7)==0%判断是否周末
        ODt(:,:,t_e-1)=ODt(:,:,1)*0.7;
        ODt(:,:,t_e)=ODt(:,:,1)*0.7;
        environment(t_e-1)=2;
        environment(t_e)=2;
    else
        ODt(:,:,t_e)=ODt(:,:,1);
        environment(t_e)=1;
    end
end
t_e=1;%演化开始时间
%==============公交线路=============
% route(1,:)=[12,11,10,8,6,4,5,2];
% route(2,:)=[14,10,13,11,12,4,2,1];
% route(3,:)=[9,15,7,10,8,6,0,0];
% route(4,:)=[1,2,3,6,8,15,7,10];

route(1,:)=[1,2,5,6];
route(2,:)=[1,4,5,6];
route(3,:)=[4,5,2,3];

route_num=size(route,1);%线路数量
capacity_ind=50;%局部非支配解容量
capacity_glo=200;%全局非支配解容量
p.V=size(route,1)*M+1+size(route,1);
p.Mv=2;%目标个数
min_pb=0.5;max_pb=1;%公交票价区间
min_pc=10;max_pc=15;%停车费区间
min_f=3;max_f=10;%发车频率区间
p.min(1:size(route,1)*M)=min_pb;p.max(1:size(route,1)*M)=max_pb;%公交票价区间
p.min(size(route,1)*M+1)=min_pc;p.max(size(route,1)*M+1)=max_pc;%停车费区间
p.min(size(route,1)*M+2:size(route,1)*M+1+size(route,1))=min_f;p.max(size(route,1)*M+2:size(route,1)*M+1+size(route,1))=max_f;%发车频率区间
%===========================路网及线路初始化===============
for i=1:num_station
    for j=1:num_station
        cell{i,j}.route_num=0;%线路数量
        cell{i,j}.transfer=0;%换乘站点
        cell{i,j}.wd=[];
        cell{i,j}.route=[];
        cell{i,j}.route1=[];
        cell{i,j}.route2=[];
        cell{i,j}.route_length=[];
        cell{i,j}.bus_travel_time=[];
        cell{i,j}.bus_wait_time=[];
        cell{i,j}.car_time=[];
        cell{i,j}.bus_fare=[];
        cell{i,j}.car_fare=[];
        cell{i,j}.real_route=[];
        cell{i,j}.direction=[];
        cell{i,j}.bus_fee=[];
        cell{i,j}.car_fee=[];
        cell{i,j}.bus_q=[];
        cell{i,j}.car_q=[];
        cell{i,j}.dis=[];
        cell{i,j}.departure_fee=[];
        %=========确定每个OD间线路数量与名称============
        for k=1:route_num
            if ismember(i,route(k,:))&&ismember(j,route(k,:))&&(i~=j)
                cell{i,j}.route_num=cell{i,j}.route_num+1;
                cell{i,j}.route=[cell{i,j}.route,k];%添加线路名称
                cell{i,j}.i_locate(cell{i,j}.route_num,1)=find(ismember(route(k,:),i));%定位起点在线路中的位置
                cell{i,j}.j_locate(cell{i,j}.route_num,1)=find(ismember(route(k,:),j));%定位终点在线路中的位置
                if cell{i,j}.i_locate(cell{i,j}.route_num,1)<cell{i,j}.j_locate(cell{i,j}.route_num,1)%方向
                    cell{i,j}.direction(cell{i,j}.route_num,1)=1;%上行
                else
                    cell{i,j}.direction(cell{i,j}.route_num,1)=-1;%下行
                end
            end
        end
        if TF(i,j)~=0%需要换乘
            cell{i,j}.route_num=1;%选择一条换乘线路
            cell{i,j}.transfer=TF(i,j);%换乘站
            cell{i,j}.route_num1=0;
            cell{i,j}.route_num2=0;
            for k=1:route_num
                if ismember(i,route(k,:))&&ismember(cell{i,j}.transfer,route(k,:))
                    cell{i,j}.route_num1=cell{i,j}.route_num1+1;
                    cell{i,j}.route1=[cell{i,j}.route1,k];%添加线路名称
                    cell{i,j}.i_locate(cell{i,j}.route_num1,1)=find(ismember(route(k,:),i));%定位起点在线路中的位置
                    cell{i,j}.tf_locate1(cell{i,j}.route_num1,1)=find(ismember(route(k,:),cell{i,j}.transfer));%定位换乘点在线路中的位置
                    if cell{i,j}.i_locate(cell{i,j}.route_num1,1)<cell{i,j}.tf_locate1(cell{i,j}.route_num1,1)%方向
                        cell{i,j}.direction(cell{i,j}.route_num1,1)=1;%上行
                    else
                        cell{i,j}.direction(cell{i,j}.route_num1,1)=-1;%下行
                    end
                end
            end
            for k=1:route_num
                if ismember(cell{i,j}.transfer,route(k,:))&&ismember(j,route(k,:))
                    cell{i,j}.route_num2=cell{i,j}.route_num2+1;
                    cell{i,j}.route2=[cell{i,j}.route2,k];%添加线路名称
                    cell{i,j}.tf_locate2(cell{i,j}.route_num2,1)=find(ismember(route(k,:),cell{i,j}.transfer));%定位换乘点在线路中的位置
                    cell{i,j}.j_locate(cell{i,j}.route_num2,1)=find(ismember(route(k,:),j));%定位终点在线路中的位置
                    if cell{i,j}.tf_locate2(cell{i,j}.route_num2,1)<cell{i,j}.j_locate(cell{i,j}.route_num2,1)%方向
                        cell{i,j}.direction(cell{i,j}.route_num2,2)=1;%上行
                    else
                        cell{i,j}.direction(cell{i,j}.route_num2,2)=-1;%下行
                    end
                end
            end
        end
        %==============计算每个OD间的实际路径==============   
        cell{i,j}.real_route=zeros(cell{i,j}.route_num,num_station);
        if TF(i,j)==0%不用换乘
            for k=1:cell{i,j}.route_num
                if cell{i,j}.direction(k)==1%上行实际的路径
                    cell{i,j}.route_length(k)=size(route(cell{i,j}.route(k),cell{i,j}.i_locate(k,1):cell{i,j}.j_locate(k,1)),2);
                    cell{i,j}.real_route(k,1:cell{i,j}.route_length(k))=route(cell{i,j}.route(k),cell{i,j}.i_locate(k,1):cell{i,j}.j_locate(k,1));
                elseif cell{i,j}.direction(k)==-1%下行实际的路径
                    cell{i,j}.route_length(k)=size(route(cell{i,j}.route(k),cell{i,j}.j_locate(k,1):cell{i,j}.i_locate(k,1)),2);
                    cell{i,j}.real_route(k,1:cell{i,j}.route_length(k))=route(cell{i,j}.route(k),cell{i,j}.j_locate(k,1):cell{i,j}.i_locate(k,1));
                end
            end
        else%需要换乘
            %==========第一条线===========
            if cell{i,j}.direction(1,1)==1%上行实际的路径
                cell{i,j}.route_length1=size(route(cell{i,j}.route1(1),cell{i,j}.i_locate(1,1):cell{i,j}.tf_locate1(1,1)),2);
                cell{i,j}.real_route(1,1:cell{i,j}.route_length1)=route(cell{i,j}.route1(1),cell{i,j}.i_locate(1,1):cell{i,j}.tf_locate1(1,1));
            elseif cell{i,j}.direction(1,1)==-1%下行实际的路径
                cell{i,j}.route_length1=size(route(cell{i,j}.route1(1),cell{i,j}.tf_locate1(1,1):cell{i,j}.i_locate(1,1)),2);
                cell{i,j}.real_route(1,1:cell{i,j}.route_length1)=route(cell{i,j}.route1(1),cell{i,j}.tf_locate1(1,1):cell{i,j}.i_locate(1,1));
            end
            %==========第二条线==============
            if cell{i,j}.direction(1,2)==1%上行实际的路径
                cell{i,j}.route_length2=size(route(cell{i,j}.route2(1),cell{i,j}.tf_locate2(1,1):cell{i,j}.j_locate(1,1)),2);
                cell{i,j}.real_route(2,1:cell{i,j}.route_length2)=route(cell{i,j}.route2(1),cell{i,j}.tf_locate2(1,1):cell{i,j}.j_locate(1,1));
            elseif cell{i,j}.direction(1,2)==-1%下行实际的路径
                cell{i,j}.route_length2=size(route(cell{i,j}.route2(1),cell{i,j}.j_locate(1,1):cell{i,j}.tf_locate2(1,1)),2);
                cell{i,j}.real_route(2,1:cell{i,j}.route_length2)=route(cell{i,j}.route2(1),cell{i,j}.j_locate(1,1):cell{i,j}.tf_locate2(1,1));
            end
        end
        %==========初始化出发时间选择概率============
        cell{i,j}.wd=rand_d(M);
    end
end
%=============种群初始化=============================
pop_xy=p.min+rand(pop_num,p.V).*(p.max-p.min);%种群初始化
for i=1:pop_num
    pop_xy(i,p.V+1:p.V+p.Mv)=f_value(pop_xy(i,1:p.V),ODt,t_e,TT,TF,M,route,cell,route_num,num_station);
    indiv(i).dic=[];%个体非支配解字典
end
global_dic_dy=[];%全局非支配解字典
%=======================开始演化====================================================
while t_e<=gen
    %=============更新神经网络==============================
    pop_xy_t(:,:,t_e)=pop_xy(:,1:p.V)';%用神经网络记录当前种群与当前环境的映射
    for i=1:max(environment)
        net{i}=pop_neural_network(pop_xy_t,p,ODt,environment,i,t_e,num_station,pop_num);%训练神经网络
    end
    %=============判断OD需求（环境）是否发生变化========
    %========如果环境没有发生变化（继续优化一步）===========
    if t_e==1||environment(t_e)-environment(t_e-1)==0
        for i=1:pop_num
            indiv(i).dic=non_domination(pop_xy(i,:),indiv(i).dic,p);%更新个体非支配解
            indiv(i).dic=delete_table(indiv(i).dic,capacity_ind,p);%删去超出字典容量的
        end
        global_dic_dy=non_domination(pop_xy,global_dic_dy,p);%更新全局非支配解
        global_dic_dy=delete_table(global_dic_dy,capacity_glo,p);%删去超出字典容量的
        pop_xy = genetic_operator(indiv,global_dic_dy,p,ODt,t_e,TT,TF,M,route,cell,route_num,num_station);%更新种群
        
    %========如果环境发生了变化。如果新的环境以前遇到过，则直接给出对应的种群，否则记录当前种群与当前环境的映射===========    
    elseif environment(t_e)-environment(t_e-1)~=0
        pop_xy_temp=sim(net{environment(t_e)},reshape(ODt(:,:,t_e),num_station^2,size(ODt(:,:,t_e),3)));%用神经网络输出全部初始种群
        pop_xy(:,1:p.V)=reshape(pop_xy_temp,p.V,pop_num)';
        for i=1:pop_num
            pop_xy(i,p.V+1:p.V+p.Mv)=f_value(pop_xy(i,1:p.V),ODt,t_e,TT,TF,M,route,cell,route_num,num_station);
        end
    end
    %========利用中心点预测、突变更新种群=======
    global_order=sortrows(global_dic_dy,p.V+p.Mv);%对所有非支配解排序
    center=round(size(global_order,1)/2);
    pop_center(t_e,:)=global_order(center,:);%定位处于中心的个体
    if t_e>=2
        derta_xy=mean(pop_center(t_e,1:p.V)-pop_center(t_e-1,1:p.V));
        for i=1:pop_num
            if rand<0.4
                pop_xy(i,1:p.V)=pop_xy(i,1:p.V)+derta_xy;
                pop_xy(i,p.V+1:p.V+p.Mv)=f_value(pop_xy(i,1:p.V),ODt,t_e,TT,TF,M,route,cell,route_num,num_station);
            end
        end
    end
    %=======更新后的种群继续优化一步============
    global_dic_dy=non_domination(pop_xy,global_dic_dy,p);%更新全局非支配解
    global_dic_dy=delete_table(global_dic_dy,capacity_glo,p);%删去超出字典容量的
    t_e=t_e+1;
end
figure%画图
plot_f(global_dic_dy,p.V);




