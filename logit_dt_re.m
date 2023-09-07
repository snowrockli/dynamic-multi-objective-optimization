function cell=logit_dt_re(cell,i,j,M,theita,kesei,theita_l)
if i~=j
    for dt=1:M
        %========ºó»ÚÖµ=====================
        min_departure_fee=min(cell{i,j}.departure_fee(:));
        cell{i,j}.departure_regret(dt)=cell{i,j}.departure_fee(dt)-1+exp(-theita_l*(min_departure_fee-cell{i,j}.departure_fee(dt)));
    end
    
    for dt=1:M
        cell{i,j}.wd(dt)=exp(-theita*kesei*cell{i,j}.departure_regret(dt))/sum(exp(-theita*kesei*cell{i,j}.departure_regret(:)));
    end
end
end