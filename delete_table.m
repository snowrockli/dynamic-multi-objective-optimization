function f=delete_table(f,capacity_glo,p)
[N,~]=size(f);
if N>capacity_glo
    [~,index]=sort(f(:,p.V+p.Mv+1),'descend');
    f(index(capacity_glo+1:end),:)=[];
end
end