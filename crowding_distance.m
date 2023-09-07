function f=crowding_distance(f,p)
[N,~]=size(f);
for i=1:p.Mv
    [temp,index]=sort(f(:,p.V+i));
    std_distance=temp(N)-temp(1);
    for j=1:N
        if j==1||j==N
            distance(index(j),i)=inf;
        else
            %distance(index(j),i)=temp(j+1)-temp(j-1);
            distance(index(j),i)=(temp(j+1)-temp(j-1))/std_distance;
        end
    end
end
final_distance=sum(distance,2);
f(:,p.V+p.Mv+1)=final_distance;
end