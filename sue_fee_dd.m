function result=sue_fee_dd(cell,TF,i,j,tte,tta,dt)
alfa=0.88;%���չ�̶ܳ�
beita=0.88;%����ƫ�ó̶�
lamada1=0.2;%���չ��ϵ��������ʱ�䣩
lamada2=0.33;%���չ��ϵ��������ʱ�䣩
u0=tte+(tta-tte)/2;
rdt=(dt-1)*10;%����ʱ�任��
if TF(i,j)==0%���û���
    for k=1:cell{i,j}.route_num
        if rdt+cell{i,j}.bus_travel_time(k,dt)>=tte&&rdt+cell{i,j}.bus_travel_time(k,dt)<u0
            futillity(k)=lamada1*(rdt+cell{i,j}.bus_travel_time(k,dt)-tte)^alfa;%����
        elseif rdt+cell{i,j}.bus_travel_time(k,dt)>=u0&&rdt+cell{i,j}.bus_travel_time(k,dt)<=tta
            futillity(k)=lamada1*(tta-rdt-cell{i,j}.bus_travel_time(k,dt))^alfa;%����
        elseif rdt+cell{i,j}.bus_travel_time(k,dt)<tte%����̫��
            futillity(k)=-lamada2*(tte-rdt-cell{i,j}.bus_travel_time(k,dt))^beita;
        elseif rdt+cell{i,j}.bus_travel_time(k,dt)>tta%����̫��
            futillity(k)=-lamada2*(rdt+cell{i,j}.bus_travel_time(k,dt)-tta)^beita;
        end
    end
    result=mean(futillity(:));
else%��Ҫ����
    if rdt+cell{i,j}.bus_travel_time_sum(dt)>=tte&&rdt+cell{i,j}.bus_travel_time_sum(dt)<u0
        futillity=lamada1*(rdt+cell{i,j}.bus_travel_time_sum(dt)-tte)^alfa;%����
    elseif rdt+cell{i,j}.bus_travel_time_sum(dt)>=u0&&rdt+cell{i,j}.bus_travel_time_sum(dt)<=tta
        futillity=lamada1*(tta-rdt-cell{i,j}.bus_travel_time_sum(dt))^alfa;%����
    elseif rdt+cell{i,j}.bus_travel_time_sum(dt)<tte%����̫��
        futillity=-lamada2*(tte-rdt-cell{i,j}.bus_travel_time_sum(dt))^beita;
    elseif rdt+cell{i,j}.bus_travel_time_sum(dt)>tta%����̫��
        futillity=-lamada2*(rdt+cell{i,j}.bus_travel_time_sum(dt)-tta)^beita;
    end
    result=futillity;
end
return