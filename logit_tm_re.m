function cell=logit_tm_re(dt,i,j,TF,cell,OD,theita,theita_l)
%========私家车后悔值=====================
min_bus_fee=min(cell{i,j}.bus_fee(:,dt));
cell{i,j}.car_regret(dt)=cell{i,j}.car_fee(dt)-1+exp(-theita_l*(min(min_bus_fee,cell{i,j}.car_fee(dt))-cell{i,j}.car_fee(dt)));
%========公交车后悔值=====================
for k=1:cell{i,j}.route_num
    cell{i,j}.bus_regret(k,dt)=cell{i,j}.bus_fee(k,dt)-1+exp(-theita_l*(min(min_bus_fee,cell{i,j}.car_fee(dt))-cell{i,j}.bus_fee(k,dt)));
end
if TF(i,j)==0%不需要换乘
    %========选择私家车出行人数=========
    cell{i,j}.car_q(dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.car_regret(dt))/(sum(exp(-theita*cell{i,j}.bus_regret(:,dt)))+exp(-theita*cell{i,j}.car_regret(dt)));
    %========选择公交出行人数===========
    for k=1:cell{i,j}.route_num
        cell{i,j}.bus_q(k,dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.bus_regret(k,dt))/(sum(exp(-theita*cell{i,j}.bus_regret(:,dt)))+exp(-theita*cell{i,j}.car_regret(dt)));
    end
else
    %========选择私家车出行人数=========
    cell{i,j}.car_q(dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.car_regret(dt))/(exp(-theita*cell{i,j}.bus_regret(dt))+exp(-theita*cell{i,j}.car_regret(dt)));
    %========选择公交出行人数===========
    cell{i,j}.bus_q(1,dt)=OD(i,j)*cell{i,j}.wd(dt)*exp(-theita*cell{i,j}.bus_regret(dt))/(exp(-theita*cell{i,j}.bus_regret(dt))+exp(-theita*cell{i,j}.car_regret(dt)));
end
end