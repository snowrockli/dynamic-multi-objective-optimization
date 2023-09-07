function cell=logit_dt(cell,i,j,M,theita,kesei)
if i~=j
    for dt=1:M
        cell{i,j}.wd(dt)=exp(-theita*kesei*cell{i,j}.departure_fee(dt))/sum(exp(-theita*kesei*cell{i,j}.departure_fee(:)));
    end
end
end