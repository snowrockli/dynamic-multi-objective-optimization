function f=f_value(x,ODt,t_e,TT,TF,M,route,cell,route_num,num_station)
OD=ODt(:,:,t_e);
t=1;
t_T=10;
tte=20;%�絽ʱ��
tta=80;%�ϰ�ʱ��
theita=0.7;%Ч�ø�֪ϵ��
kesei=0.2;%Ч��ϵ��
N_agent_length=5;%Ԫ���ռ�߳�
theita_l_so=1.5;%��Ϣѧϰϵ��
theita_l=0.5;%������̶�
capacity=150;%ӵ����ֵ
capacity_bus=100;%������Ա
%==============��λ��̷�ʱƱ�ۣ�������=============
for i=1:size(route,1)
    for j=1:M
        p_route(i,j)=x((i-1)*M+j);
    end
end
p_park=x(size(route,1)*M+1);
f_route(1:size(route,1))=x(size(route,1)*M+2:size(route,1)*M+1+size(route,1));
%==========================��ʼ�ݻ�=========================
while t<=t_T%ÿ��
    dt=1;
    q=zeros(num_station,num_station,route_num,M);%·��ʵʱ��������
    while dt<=M%ÿһʱ���
        for i=1:num_station
            for j=1:num_station
                %=======����Ʊ�ۡ��г�ʱ�䡢�ȴ�ʱ��=====
                if TF(i,j)==0%���û���
                    for k=1:cell{i,j}.route_num
                        %=======Ʊ��==========
                        %cell{i,j}.bus_fare(k,dt)=p_route(k,dt)*cell{i,j}.route_length(k);
                        cell{i,j}.bus_fare(k,dt)=p_route(cell{i,j}.route(k),dt)*cell{i,j}.route_length(k);
                        %=======�г�ʱ��========
                        cell{i,j}.bus_travel_time(k,dt)=0;
                        non_zero=cell{i,j}.real_route(k,(find(cell{i,j}.real_route(k,:)~=0)));%��ȡʵ����·
                        for kk=1:length(non_zero)-1
                            if t==1
                                cell{i,j}.bus_travel_time(k,dt)=cell{i,j}.bus_travel_time(k,dt)+TT(non_zero(kk),non_zero(kk+1));%��·�г�ʱ��
                            else
                                cell{i,j}.bus_travel_time(k,dt)=cell{i,j}.bus_travel_time(k,dt)+TT(non_zero(kk),non_zero(kk+1))*1.4*(1+0.15*(cell{i,j}.bus_crowd(k,dt)/(f_route(cell{i,j}.route(k))*capacity))^4);%��·�г�ʱ��
                            end
                        end
                        %==========�ȴ�ʱ��=============
                        if t==1
                            cell{i,j}.bus_wait_time(k,dt)=1/f_route(cell{i,j}.route(k));%�����ȴ�ʱ��
                        else
                            cell{i,j}.bus_wait_time(k,dt)=cell{i,j}.bus_crowd(k,dt)/(f_route(cell{i,j}.route(k))*capacity_bus);%�����ȴ�ʱ��
                        end
                    end
                else%��Ҫ����
                    %=======�г�ʱ��========
                    cell{i,j}.bus_travel_time(1,dt)=0;
                    cell{i,j}.bus_travel_time(2,dt)=0;
                    non_zero1=cell{i,j}.real_route(1,(find(cell{i,j}.real_route(1,:)~=0)));%��ȡ��һ��ʵ����·
                    non_zero2=cell{i,j}.real_route(2,(find(cell{i,j}.real_route(2,:)~=0)));%��ȡ�ڶ���ʵ����·
                    for kk=1:length(non_zero1)-1%��һ��·
                        if t==1
                            cell{i,j}.bus_travel_time(1,dt)=cell{i,j}.bus_travel_time(1,dt)+TT(non_zero1(kk),non_zero1(kk+1));%��·�г�ʱ��
                        else
                            cell{i,j}.bus_travel_time(1,dt)=cell{i,j}.bus_travel_time(1,dt)+TT(non_zero1(kk),non_zero1(kk+1))*1.4*(1+0.15*(cell{i,j}.bus_crowd(1,dt)/(f_route(cell{i,j}.route1(1))*capacity))^4);%��·�г�ʱ��
                        end
                    end
                    for kk=1:length(non_zero2)-1%�ڶ���·
                        if t==1
                            cell{i,j}.bus_travel_time(2,dt)=cell{i,j}.bus_travel_time(2,dt)+TT(non_zero2(kk),non_zero2(kk+1));%��·�г�ʱ��
                        else
                            cell{i,j}.bus_travel_time(2,dt)=cell{i,j}.bus_travel_time(2,dt)+TT(non_zero2(kk),non_zero2(kk+1))*1.4*(1+0.15*(cell{i,j}.bus_crowd(2,dt)/(f_route(cell{i,j}.route2(1))*capacity))^4);%��·�г�ʱ��
                        end
                    end
                    cell{i,j}.bus_travel_time_sum(dt)=sum(cell{i,j}.bus_travel_time(:,dt));%�����г�ʱ��
                    %=======�ȴ�ʱ��===========
                    if t==1
                        cell{i,j}.bus_wait_time(1,dt)=1/f_route(cell{i,j}.route1(1));%��һ��·
                        cell{i,j}.bus_wait_time(2,dt)=1/f_route(cell{i,j}.route2(1));%�ڶ���·
                    else
                        cell{i,j}.bus_wait_time(1,dt)=cell{i,j}.bus_crowd(1,dt)/(f_route(cell{i,j}.route1(1))*capacity_bus);%��һ��·
                        cell{i,j}.bus_wait_time(2,dt)=cell{i,j}.bus_crowd(2,dt)/(f_route(cell{i,j}.route2(1))*capacity_bus);%�ڶ���·
                    end
                    cell{i,j}.bus_wait_time_sum(dt)=sum(cell{i,j}.bus_wait_time(:,dt))+10;%���յȴ�ʱ�䣨���ǻ��ˣ�
                    %=========Ʊ��===========
                    dt_arr=floor(cell{i,j}.bus_travel_time(1,dt)/10);%��һ��·����ʱ��ȡ��
                    if dt_arr>M
                        dt_arr=M;
                    elseif dt_arr==0
                        dt_arr=1;
                    end
                    cell{i,j}.bus_fare(1,dt)=p_route(cell{i,j}.route1(1),dt)*cell{i,j}.route_length1;%��һ��·�̼۸�
                    cell{i,j}.bus_fare(2,dt)=p_route(cell{i,j}.route2(1),dt_arr)*cell{i,j}.route_length2;%�ڶ���·�̼۸�
                    cell{i,j}.bus_fare_sum(dt)=sum(cell{i,j}.bus_fare(:,dt));%��Ʊ��
                end
                %=============˽�ҳ�ͣ�����á��г�ʱ��=========
                cell{i,j}.car_fare=p_park;
                if i~=j
                    if TF(i,j)==0%���û���
                        cell{i,j}.car_time(dt)=min(cell{i,j}.bus_travel_time(:,dt));
                    else%��Ҫ����
                        cell{i,j}.car_time(dt)=cell{i,j}.bus_travel_time_sum(dt);
                    end
                end
                %==============�������==========================================================
                if i~=j
                    if TF(i,j)==0%���û���
                        %===========˽�ҳ��������===========
                        if t==1
                            cell{i,j}.car_fee(dt)=kesei*cell{i,j}.car_fare+kesei*cell{i,j}.car_time(dt);
                        else
                            cell{i,j}.car_fee(dt)=kesei*cell{i,j}.car_fare+kesei*cell{i,j}.car_time(dt)+theita_l_so*kesei*sum(cell{i,j}.bus_q(:,dt))/mean(OD(:));
                        end
                        %==========�������������==========
                        for k=1:cell{i,j}.route_num
                            if t==1
                                cell{i,j}.bus_fee(k,dt)=kesei*cell{i,j}.bus_travel_time(k,dt)+kesei*cell{i,j}.bus_wait_time(k,dt)+kesei*cell{i,j}.bus_fare(k,dt);
                            else
                                cell{i,j}.bus_fee(k,dt)=kesei*cell{i,j}.bus_travel_time(k,dt)+kesei*cell{i,j}.bus_wait_time(k,dt)+kesei*cell{i,j}.bus_fare(k,dt)+kesei*cell{i,j}.bus_crowd(k,dt)/(f_route(cell{i,j}.route(k))*capacity_bus)+theita_l_so*kesei*sum(cell{i,j}.car_q(dt))/mean(OD(:));
                            end
                        end
                    else%��Ҫ����
                        %===========˽�ҳ��������===========
                        if t==1
                            cell{i,j}.car_fee(dt)=kesei*cell{i,j}.car_fare+kesei*cell{i,j}.car_time(dt);
                        else
                            cell{i,j}.car_fee(dt)=kesei*cell{i,j}.car_fare+kesei*cell{i,j}.car_time(dt)+theita_l_so*kesei*cell{i,j}.bus_q(dt)/mean(OD(:));
                        end
                        %==========�������������==========
                        if t==1
                            cell{i,j}.bus_fee(dt)=kesei*cell{i,j}.bus_travel_time_sum(dt)+kesei*cell{i,j}.bus_wait_time_sum(dt)+kesei*cell{i,j}.bus_fare_sum(dt);
                        else
                            cell{i,j}.bus_fee(dt)=kesei*cell{i,j}.bus_travel_time_sum(dt)+kesei*cell{i,j}.bus_wait_time_sum(dt)+kesei*cell{i,j}.bus_fare_sum(dt)+kesei*mean(cell{i,j}.bus_crowd(:,dt))/((f_route(cell{i,j}.route1(1))+f_route(cell{i,j}.route2(1)))*capacity_bus/2)+theita_l_so*kesei*sum(cell{i,j}.car_q(dt))/mean(OD(:));
                        end
                    end
                    %================�������ʱ�����=============
                    cell{i,j}.departure_fee(dt)=-sue_fee_dd(cell,TF,i,j,tte,tta,dt);
                    %===================����ѡ��ͬ���䷽ʽ������============================
                    %%%%%%%%%%%%%%%%%%%%logitģ��%%%%%%%%%%%%
                    %cell=logit_tm(dt,i,j,TF,cell,OD,theita);
                    %%%%%%%%%%%%%%%%%%%%logitģ�ͣ����Ч�ã�%%%%%%%%
                    cell=logit_tm_re(dt,i,j,TF,cell,OD,theita,theita_l);
                    %%%%%%%%%%%%%%%%%%%%Ԫ��������ģ��%%%%%%%
                    %cell=cell_neural_tm(t,dt,i,j,cell,OD,theita,N_agent_length);
                    %%%%%%%%%%%%%%%%%%%%Ԫ��������ģ�ͣ����Ч�ã�%%%%%%%
                    %cell=cell_neural_tm_re(t,dt,i,j,cell,OD,theita,N_agent_length);
                    %===================���������===================
                    bus_q(i,j)=mean(cell{i,j}.bus_q(:,dt));
                end
            end
        end
        %============���������==============
        if t==1
            q_var(t)=0;
        else
            bus_qq(t)=mean(mean(bus_q(:,:)));%���������
            q_var(t)=abs(bus_qq(t)-bus_qq(t-1))/max(bus_qq(1:t));%���������
        end
        %=============����ÿ����·��ʹ�����(����ʵʱ·������)===============
        q=zeros(num_station,num_station,route_num,M);
        for i=1:num_station
            for j=1:num_station
                for k=1:route_num
                    if TF(i,j)==0%���û���
                        if i==j
                            q(i,j,k,dt)=0;
                        elseif t>1
                            if isempty(find(cell{i,j}.route==k))==1
                                q(i,j,k,dt)=0;
                            else
                                q(i,j,k,dt)=cell{i,j}.bus_q(find(cell{i,j}.route==k),dt);
                                %===========��������ռ��·��==============
                                travel_time_int=floor(cell{i,j}.bus_travel_time(find(cell{i,j}.route==k),dt)/10);%�г�ʱ��ȡ��
                                for ii=1:travel_time_int
                                    if dt+ii<=M
                                        q(i,j,k,dt+ii)=cell{i,j}.bus_q(find(cell{i,j}.route==k),dt);
                                    end
                                end
                            end
                        end
                    else%��Ҫ����
                        %======��һ��·============
                        if i==j
                            q(i,j,k,dt)=0;
                        elseif t>1
                            if isempty(find(cell{i,j}.route1(1)==k))==1
                                q(i,j,k,dt)=0;
                            else
                                q(i,j,k,dt)=cell{i,j}.bus_q(find(cell{i,j}.route1(1)==k),dt);
                                %===========��������ռ��·��==============
                                travel_time_int=floor(cell{i,j}.bus_travel_time(find(cell{i,j}.route1(1)==k),dt)/10);%�г�ʱ��ȡ��
                                for ii=1:travel_time_int
                                    if dt+ii<=M
                                        q(i,j,k,dt+ii)=cell{i,j}.bus_q(find(cell{i,j}.route1(1)==k),dt);
                                    end
                                end
                            end
                        end
                        %=========�ڶ���·===========
                        if i==j
                            q(i,j,k,dt)=0;
                        elseif t>1
                            if isempty(find(cell{i,j}.route2(1)==k))==1
                                q(i,j,k,dt)=0;
                            else
                                q(i,j,k,dt)=cell{i,j}.bus_q(find(cell{i,j}.route2(1)==k),dt);
                                %===========��������ռ��·��==============
                                travel_time_int=floor(cell{i,j}.bus_travel_time(find(cell{i,j}.route2(1)==k),dt)/10);%�г�ʱ��ȡ��
                                for ii=1:travel_time_int
                                    if dt+ii<=M
                                        q(i,j,k,dt+ii)=cell{i,j}.bus_q(find(cell{i,j}.route2(1)==k),dt);
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        %===========����ÿ��·�ε�ӵ���̶ȣ����У�================
        for k=1:size(route,1)
            for ii=1:size(route,2)-1
                if route(k,ii)*route(k,ii+1)==0
                    crowd(k,ii,dt,1)=0;%����
                else
                    if ii==1
                        crowd(k,ii,dt,1)=0;
                        for jj=ii+1:size(route,2)
                            if route(k,jj)~=0
                                crowd(k,ii,dt,1)=crowd(k,ii,dt,1)+q(route(k,ii),route(k,jj),k,dt);
                            end
                        end
                    else
                        q_hou=0;
                        q_qian=0;
                        for jj=ii+1:size(route,2)
                            if route(k,jj)~=0
                                q_hou=q_hou+q(route(k,ii),route(k,jj),k,dt);
                            end
                        end
                        for jj=1:ii
                            if route(k,jj)~=0
                                q_qian=q_qian+q(route(k,jj),route(k,ii),k,dt);
                            end
                        end
                        crowd(k,ii,dt,1)=crowd(k,ii-1,dt,1)+q_hou-q_qian;
                    end
                end
            end
        end
        %===========����ÿ��·�ε�ӵ���̶ȣ����У�================
        for k=1:size(route,1)
            for ii=size(route,2):-1:2
                if route(k,ii)*route(k,ii-1)==0
                    crowd(k,ii-1,dt,2)=0;%����
                else
                    if ii==size(route,2)
                        crowd(k,ii-1,dt,2)=0;
                        for jj=ii-1:-1:1
                            if route(k,jj)~=0
                                crowd(k,ii-1,dt,2)=crowd(k,ii-1,dt,2)+q(route(k,ii),route(k,jj),k,dt);
                            else
                                crowd(k,ii-1,dt,2)=0;
                            end
                        end
                    else
                        q_hou=0;
                        q_qian=0;
                        for jj=1:ii-1
                            if route(k,jj)~=0
                                q_hou=q_hou+q(route(k,ii),route(k,jj),k,dt);
                            end
                        end
                        for jj=ii:size(route,2)
                            if route(k,jj)~=0
                                q_qian=q_qian+q(route(k,jj),route(k,ii),k,dt);
                            end
                        end
                        crowd(k,ii-1,dt,2)=crowd(k,ii,dt,2)+q_hou-q_qian;
                    end
                end
            end
        end
        %==================����ÿ��OD���ӵ����===================
        for i=1:num_station
            for j=1:num_station
                if TF(i,j)==0%���û���
                    for k=1:cell{i,j}.route_num
                        if cell{i,j}.direction(k)==1
                            cell{i,j}.bus_crowd(k,dt)=sum(crowd(cell{i,j}.route(k),cell{i,j}.i_locate(k):cell{i,j}.j_locate(k)-1,dt,1));
                        elseif cell{i,j}.direction(k)==-1
                            cell{i,j}.bus_crowd(k,dt)=sum(crowd(cell{i,j}.route(k),cell{i,j}.j_locate(k):cell{i,j}.i_locate(k)-1,dt,2));
                        end
                    end
                else%��Ҫ����
                    if cell{i,j}.direction(1,1)==1
                        cell{i,j}.bus_crowd(1,dt)=sum(crowd(cell{i,j}.route1(1),cell{i,j}.i_locate(1):cell{i,j}.tf_locate1(1)-1,dt,1));
                    elseif cell{i,j}.direction(1,1)==-1
                        cell{i,j}.bus_crowd(1,dt)=sum(crowd(cell{i,j}.route1(1),cell{i,j}.tf_locate1(1):cell{i,j}.i_locate(1)-1,dt,2));
                    end
                    if cell{i,j}.direction(1,2)==1
                        cell{i,j}.bus_crowd(2,dt)=sum(crowd(cell{i,j}.route2(1),cell{i,j}.tf_locate2(1):cell{i,j}.j_locate(1)-1,dt,1));
                    elseif cell{i,j}.direction(1,2)==-1
                        cell{i,j}.bus_crowd(2,dt)=sum(crowd(cell{i,j}.route2(1),cell{i,j}.j_locate(1):cell{i,j}.tf_locate2(1)-1,dt,2));
                    end
                end
            end
        end
        dt=dt+1;
    end
    %===============����ѡ��ͬ����ʱ�������=====================
    for i=1:num_station
        for j=1:num_station
            %=========logitģ��========
            %cell=logit_dt(cell,i,j,M,theita,kesei);
            %=========logitģ��(���Ч��)========
            cell=logit_dt_re(cell,i,j,M,theita,kesei,theita_l);
            %=========Ԫ��������ģ�ͣ����Ч�ã�=========
            %cell=cell_neural_dt_re(cell,i,j,t,M,theita,N_agent_length);
        end
    end
    t=t+1;
end
%===================����Ŀ�꺯��==========
%======Ŀ�꺯��1���������ɱ�
%======Ŀ�꺯��2������̼�ŷ�
%=================�������ɱ�============
for i=1:num_station
    for j=1:num_station
        if i~=j
            for dt=1:M
                for k=1:cell{i,j}.route_num
                    if TF(i,j)==0%���û���
                        profit_bus(k,dt)=cell{i,j}.bus_fare(k,dt)*cell{i,j}.bus_q(k,dt)-f_route(cell{i,j}.route(k))*5;
                        g_fee_bus(k,dt)=cell{i,j}.bus_fee(k,dt)*cell{i,j}.bus_q(k,dt);
                    else%��Ҫ����
                        profit_bus(k,dt)=cell{i,j}.bus_fare_sum(k,dt)*cell{i,j}.bus_q(k,dt)-f_route(cell{i,j}.route1(1))*5-f_route(cell{i,j}.route2(1))*5;
                        g_fee_bus(k,dt)=cell{i,j}.bus_fee(k,dt)*cell{i,j}.bus_q(k,dt);
                    end
                end
                profit_car(dt)=cell{i,j}.car_fare*cell{i,j}.car_q(dt);
                g_fee_car(dt)=cell{i,j}.car_fee(dt)*cell{i,j}.car_q(dt);
            end
            profit(i,j)=sum(sum(profit_bus(:,:)))+sum(profit_car(:));
            g_fee(i,j)=sum(sum(g_fee_bus(:,:)))+sum(g_fee_car(:));
        else
            profit(i,j)=0;
            g_fee(i,j)=0;
        end
    end
end
f(1)=mean(mean(g_fee(g_fee~=0)))-mean(mean(profit(profit~=0)));%Ŀ�꺯��1
%=================����̼�ŷ�=============
for i=1:num_station
    for j=1:num_station
        if i~=j
            for dt=1:M
                if TF(i,j)==0%���û���
                    emission_c(dt)=cell{i,j}.car_q(dt)*min(cell{i,j}.route_length(:))*0.51;
                    for k=1:cell{i,j}.route_num
                        emission_b(k,dt)=cell{i,j}.bus_q(k,dt)*cell{i,j}.route_length(k)*0.036;
                    end
                else%��Ҫ����
                    emission_c(dt)=cell{i,j}.car_q(dt)*(cell{i,j}.route_length1+cell{i,j}.route_length2)*0.51;
                    emission_b(1,dt)=cell{i,j}.bus_q(1,dt)*(cell{i,j}.route_length1+cell{i,j}.route_length2)*0.036;
                end
            end
            emission(i,j)=sum(emission_c(:))+sum(sum(emission_b(:,:)));
        end
    end
end
f(2)=mean(mean(emission(emission~=0)));%Ŀ�꺯��2

end