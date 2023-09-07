function cell=logit_tm(dt,i,j,TF,cell,OD,theita) 
if TF(i,j)==0%不需要换乘
    %========选择私家车出行人数=========
    cell{i,j}.car_q(dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.car_fee(dt))/(sum(exp(-theita*cell{i,j}.bus_fee(:,dt)))+exp(-theita*cell{i,j}.car_fee(dt)));
    %========选择公交出行人数===========
    for k=1:cell{i,j}.route_num
        cell{i,j}.bus_q(k,dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.bus_fee(k,dt))/(sum(exp(-theita*cell{i,j}.bus_fee(:,dt)))+exp(-theita*cell{i,j}.car_fee(dt)));
    end
else%需要换乘
    %========选择私家车出行人数=========
    cell{i,j}.car_q(dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.car_fee(dt))/(exp(-theita*cell{i,j}.bus_fee(dt))+exp(-theita*cell{i,j}.car_fee(dt)));
    %========选择公交出行人数===========
    cell{i,j}.bus_q(1,dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.bus_fee(dt))/(exp(-theita*cell{i,j}.bus_fee(dt))+exp(-theita*cell{i,j}.car_fee(dt)));
end
end