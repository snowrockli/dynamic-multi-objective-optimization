function result=sue_fee_dd(cell,TF,i,j,tte,tta,dt)
alfa=0.88;%风险规避程度
beita=0.88;%风险偏好程度
lamada1=0.2;%风险规避系数（出发时间）
lamada2=0.33;%风险规避系数（出发时间）
u0=tte+(tta-tte)/2;
rdt=(dt-1)*10;%出发时间换算
if TF(i,j)==0%不用换乘
    for k=1:cell{i,j}.route_num
        if rdt+cell{i,j}.bus_travel_time(k,dt)>=tte&&rdt+cell{i,j}.bus_travel_time(k,dt)<u0
            futillity(k)=lamada1*(rdt+cell{i,j}.bus_travel_time(k,dt)-tte)^alfa;%收益
        elseif rdt+cell{i,j}.bus_travel_time(k,dt)>=u0&&rdt+cell{i,j}.bus_travel_time(k,dt)<=tta
            futillity(k)=lamada1*(tta-rdt-cell{i,j}.bus_travel_time(k,dt))^alfa;%收益
        elseif rdt+cell{i,j}.bus_travel_time(k,dt)<tte%到得太早
            futillity(k)=-lamada2*(tte-rdt-cell{i,j}.bus_travel_time(k,dt))^beita;
        elseif rdt+cell{i,j}.bus_travel_time(k,dt)>tta%到得太晚
            futillity(k)=-lamada2*(rdt+cell{i,j}.bus_travel_time(k,dt)-tta)^beita;
        end
    end
    result=mean(futillity(:));
else%需要换乘
    if rdt+cell{i,j}.bus_travel_time_sum(dt)>=tte&&rdt+cell{i,j}.bus_travel_time_sum(dt)<u0
        futillity=lamada1*(rdt+cell{i,j}.bus_travel_time_sum(dt)-tte)^alfa;%收益
    elseif rdt+cell{i,j}.bus_travel_time_sum(dt)>=u0&&rdt+cell{i,j}.bus_travel_time_sum(dt)<=tta
        futillity=lamada1*(tta-rdt-cell{i,j}.bus_travel_time_sum(dt))^alfa;%收益
    elseif rdt+cell{i,j}.bus_travel_time_sum(dt)<tte%到得太早
        futillity=-lamada2*(tte-rdt-cell{i,j}.bus_travel_time_sum(dt))^beita;
    elseif rdt+cell{i,j}.bus_travel_time_sum(dt)>tta%到得太晚
        futillity=-lamada2*(rdt+cell{i,j}.bus_travel_time_sum(dt)-tta)^beita;
    end
    result=futillity;
end
return