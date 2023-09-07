%====================��ʱ���컯Ʊ�۶�̬��Ŀ���Ż�================
clc
clear 
close all
ODt(:,:,1)=xlsread('OD.xlsx','real_demand');%��ʼOD�������
TT=xlsread('OD.xlsx','real_travel_time');%վ�������ʱ�����
TF=xlsread('OD.xlsx','real_transfer');%������Ϣ
[num_station,~]=size(ODt(:,:,1));%վ������
pop_num=20;%��Ⱥ����
gen=3;%�㷨��������
M=5;%ÿ��5������ʱ��
for t_e=1:gen%OD����̬�仯
    if mod(t_e,7)==0%�ж��Ƿ���ĩ
        ODt(:,:,t_e-1)=ODt(:,:,1)*0.7;
        ODt(:,:,t_e)=ODt(:,:,1)*0.7;
        environment(t_e-1)=2;
        environment(t_e)=2;
    else
        ODt(:,:,t_e)=ODt(:,:,1);
        environment(t_e)=1;
    end
end
t_e=1;%�ݻ���ʼʱ��
%==============������·=============
% route(1,:)=[12,11,10,8,6,4,5,2];
% route(2,:)=[14,10,13,11,12,4,2,1];
% route(3,:)=[9,15,7,10,8,6,0,0];
% route(4,:)=[1,2,3,6,8,15,7,10];

route(1,:)=[1,2,5,6];
route(2,:)=[1,4,5,6];
route(3,:)=[4,5,2,3];

route_num=size(route,1);%��·����
capacity_ind=50;%�ֲ���֧�������
capacity_glo=200;%ȫ�ַ�֧�������
p.V=size(route,1)*M+1+size(route,1);
p.Mv=2;%Ŀ�����
min_pb=0.5;max_pb=1;%����Ʊ������
min_pc=10;max_pc=15;%ͣ��������
min_f=3;max_f=10;%����Ƶ������
p.min(1:size(route,1)*M)=min_pb;p.max(1:size(route,1)*M)=max_pb;%����Ʊ������
p.min(size(route,1)*M+1)=min_pc;p.max(size(route,1)*M+1)=max_pc;%ͣ��������
p.min(size(route,1)*M+2:size(route,1)*M+1+size(route,1))=min_f;p.max(size(route,1)*M+2:size(route,1)*M+1+size(route,1))=max_f;%����Ƶ������
%===========================·������·��ʼ��===============
for i=1:num_station
    for j=1:num_station
        cell{i,j}.route_num=0;%��·����
        cell{i,j}.transfer=0;%����վ��
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
        %=========ȷ��ÿ��OD����·����������============
        for k=1:route_num
            if ismember(i,route(k,:))&&ismember(j,route(k,:))&&(i~=j)
                cell{i,j}.route_num=cell{i,j}.route_num+1;
                cell{i,j}.route=[cell{i,j}.route,k];%�����·����
                cell{i,j}.i_locate(cell{i,j}.route_num,1)=find(ismember(route(k,:),i));%��λ�������·�е�λ��
                cell{i,j}.j_locate(cell{i,j}.route_num,1)=find(ismember(route(k,:),j));%��λ�յ�����·�е�λ��
                if cell{i,j}.i_locate(cell{i,j}.route_num,1)<cell{i,j}.j_locate(cell{i,j}.route_num,1)%����
                    cell{i,j}.direction(cell{i,j}.route_num,1)=1;%����
                else
                    cell{i,j}.direction(cell{i,j}.route_num,1)=-1;%����
                end
            end
        end
        if TF(i,j)~=0%��Ҫ����
            cell{i,j}.route_num=1;%ѡ��һ��������·
            cell{i,j}.transfer=TF(i,j);%����վ
            cell{i,j}.route_num1=0;
            cell{i,j}.route_num2=0;
            for k=1:route_num
                if ismember(i,route(k,:))&&ismember(cell{i,j}.transfer,route(k,:))
                    cell{i,j}.route_num1=cell{i,j}.route_num1+1;
                    cell{i,j}.route1=[cell{i,j}.route1,k];%�����·����
                    cell{i,j}.i_locate(cell{i,j}.route_num1,1)=find(ismember(route(k,:),i));%��λ�������·�е�λ��
                    cell{i,j}.tf_locate1(cell{i,j}.route_num1,1)=find(ismember(route(k,:),cell{i,j}.transfer));%��λ���˵�����·�е�λ��
                    if cell{i,j}.i_locate(cell{i,j}.route_num1,1)<cell{i,j}.tf_locate1(cell{i,j}.route_num1,1)%����
                        cell{i,j}.direction(cell{i,j}.route_num1,1)=1;%����
                    else
                        cell{i,j}.direction(cell{i,j}.route_num1,1)=-1;%����
                    end
                end
            end
            for k=1:route_num
                if ismember(cell{i,j}.transfer,route(k,:))&&ismember(j,route(k,:))
                    cell{i,j}.route_num2=cell{i,j}.route_num2+1;
                    cell{i,j}.route2=[cell{i,j}.route2,k];%�����·����
                    cell{i,j}.tf_locate2(cell{i,j}.route_num2,1)=find(ismember(route(k,:),cell{i,j}.transfer));%��λ���˵�����·�е�λ��
                    cell{i,j}.j_locate(cell{i,j}.route_num2,1)=find(ismember(route(k,:),j));%��λ�յ�����·�е�λ��
                    if cell{i,j}.tf_locate2(cell{i,j}.route_num2,1)<cell{i,j}.j_locate(cell{i,j}.route_num2,1)%����
                        cell{i,j}.direction(cell{i,j}.route_num2,2)=1;%����
                    else
                        cell{i,j}.direction(cell{i,j}.route_num2,2)=-1;%����
                    end
                end
            end
        end
        %==============����ÿ��OD���ʵ��·��==============   
        cell{i,j}.real_route=zeros(cell{i,j}.route_num,num_station);
        if TF(i,j)==0%���û���
            for k=1:cell{i,j}.route_num
                if cell{i,j}.direction(k)==1%����ʵ�ʵ�·��
                    cell{i,j}.route_length(k)=size(route(cell{i,j}.route(k),cell{i,j}.i_locate(k,1):cell{i,j}.j_locate(k,1)),2);
                    cell{i,j}.real_route(k,1:cell{i,j}.route_length(k))=route(cell{i,j}.route(k),cell{i,j}.i_locate(k,1):cell{i,j}.j_locate(k,1));
                elseif cell{i,j}.direction(k)==-1%����ʵ�ʵ�·��
                    cell{i,j}.route_length(k)=size(route(cell{i,j}.route(k),cell{i,j}.j_locate(k,1):cell{i,j}.i_locate(k,1)),2);
                    cell{i,j}.real_route(k,1:cell{i,j}.route_length(k))=route(cell{i,j}.route(k),cell{i,j}.j_locate(k,1):cell{i,j}.i_locate(k,1));
                end
            end
        else%��Ҫ����
            %==========��һ����===========
            if cell{i,j}.direction(1,1)==1%����ʵ�ʵ�·��
                cell{i,j}.route_length1=size(route(cell{i,j}.route1(1),cell{i,j}.i_locate(1,1):cell{i,j}.tf_locate1(1,1)),2);
                cell{i,j}.real_route(1,1:cell{i,j}.route_length1)=route(cell{i,j}.route1(1),cell{i,j}.i_locate(1,1):cell{i,j}.tf_locate1(1,1));
            elseif cell{i,j}.direction(1,1)==-1%����ʵ�ʵ�·��
                cell{i,j}.route_length1=size(route(cell{i,j}.route1(1),cell{i,j}.tf_locate1(1,1):cell{i,j}.i_locate(1,1)),2);
                cell{i,j}.real_route(1,1:cell{i,j}.route_length1)=route(cell{i,j}.route1(1),cell{i,j}.tf_locate1(1,1):cell{i,j}.i_locate(1,1));
            end
            %==========�ڶ�����==============
            if cell{i,j}.direction(1,2)==1%����ʵ�ʵ�·��
                cell{i,j}.route_length2=size(route(cell{i,j}.route2(1),cell{i,j}.tf_locate2(1,1):cell{i,j}.j_locate(1,1)),2);
                cell{i,j}.real_route(2,1:cell{i,j}.route_length2)=route(cell{i,j}.route2(1),cell{i,j}.tf_locate2(1,1):cell{i,j}.j_locate(1,1));
            elseif cell{i,j}.direction(1,2)==-1%����ʵ�ʵ�·��
                cell{i,j}.route_length2=size(route(cell{i,j}.route2(1),cell{i,j}.j_locate(1,1):cell{i,j}.tf_locate2(1,1)),2);
                cell{i,j}.real_route(2,1:cell{i,j}.route_length2)=route(cell{i,j}.route2(1),cell{i,j}.j_locate(1,1):cell{i,j}.tf_locate2(1,1));
            end
        end
        %==========��ʼ������ʱ��ѡ�����============
        cell{i,j}.wd=rand_d(M);
    end
end
%=============��Ⱥ��ʼ��=============================
pop_xy=p.min+rand(pop_num,p.V).*(p.max-p.min);%��Ⱥ��ʼ��
for i=1:pop_num
    pop_xy(i,p.V+1:p.V+p.Mv)=f_value(pop_xy(i,1:p.V),ODt,t_e,TT,TF,M,route,cell,route_num,num_station);
    indiv(i).dic=[];%�����֧����ֵ�
end
global_dic_dy=[];%ȫ�ַ�֧����ֵ�
%=======================��ʼ�ݻ�====================================================
while t_e<=gen
    %=============����������==============================
    pop_xy_t(:,:,t_e)=pop_xy(:,1:p.V)';%���������¼��ǰ��Ⱥ�뵱ǰ������ӳ��
    for i=1:max(environment)
        net{i}=pop_neural_network(pop_xy_t,p,ODt,environment,i,t_e,num_station,pop_num);%ѵ��������
    end
    %=============�ж�OD���󣨻������Ƿ����仯========
    %========�������û�з����仯�������Ż�һ����===========
    if t_e==1||environment(t_e)-environment(t_e-1)==0
        for i=1:pop_num
            indiv(i).dic=non_domination(pop_xy(i,:),indiv(i).dic,p);%���¸����֧���
            indiv(i).dic=delete_table(indiv(i).dic,capacity_ind,p);%ɾȥ�����ֵ�������
        end
        global_dic_dy=non_domination(pop_xy,global_dic_dy,p);%����ȫ�ַ�֧���
        global_dic_dy=delete_table(global_dic_dy,capacity_glo,p);%ɾȥ�����ֵ�������
        pop_xy = genetic_operator(indiv,global_dic_dy,p,ODt,t_e,TT,TF,M,route,cell,route_num,num_station);%������Ⱥ
        
    %========������������˱仯������µĻ�����ǰ����������ֱ�Ӹ�����Ӧ����Ⱥ�������¼��ǰ��Ⱥ�뵱ǰ������ӳ��===========    
    elseif environment(t_e)-environment(t_e-1)~=0
        pop_xy_temp=sim(net{environment(t_e)},reshape(ODt(:,:,t_e),num_station^2,size(ODt(:,:,t_e),3)));%�����������ȫ����ʼ��Ⱥ
        pop_xy(:,1:p.V)=reshape(pop_xy_temp,p.V,pop_num)';
        for i=1:pop_num
            pop_xy(i,p.V+1:p.V+p.Mv)=f_value(pop_xy(i,1:p.V),ODt,t_e,TT,TF,M,route,cell,route_num,num_station);
        end
    end
    %========�������ĵ�Ԥ�⡢ͻ�������Ⱥ=======
    global_order=sortrows(global_dic_dy,p.V+p.Mv);%�����з�֧�������
    center=round(size(global_order,1)/2);
    pop_center(t_e,:)=global_order(center,:);%��λ�������ĵĸ���
    if t_e>=2
        derta_xy=mean(pop_center(t_e,1:p.V)-pop_center(t_e-1,1:p.V));
        for i=1:pop_num
            if rand<0.4
                pop_xy(i,1:p.V)=pop_xy(i,1:p.V)+derta_xy;
                pop_xy(i,p.V+1:p.V+p.Mv)=f_value(pop_xy(i,1:p.V),ODt,t_e,TT,TF,M,route,cell,route_num,num_station);
            end
        end
    end
    %=======���º����Ⱥ�����Ż�һ��============
    global_dic_dy=non_domination(pop_xy,global_dic_dy,p);%����ȫ�ַ�֧���
    global_dic_dy=delete_table(global_dic_dy,capacity_glo,p);%ɾȥ�����ֵ�������
    t_e=t_e+1;
end
figure%��ͼ
plot_f(global_dic_dy,p.V);




