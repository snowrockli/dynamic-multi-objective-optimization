function f=non_domination(solution,f,p)
[N,~]=size(solution);
for i=1:N
    xx=solution(i,:);
    if isempty(f)==1
        f(1,1:p.V+p.Mv)=xx;
    else
        [Nf,~]=size(f);
        [Nf,~]=size(f);
        index_sel=zeros(Nf,1);
        for k=1:Nf%�ֵ䳤��ѭ��
            dom_less=0;
            dom_equal=0;
            dom_more=0;
            for s=1:p.Mv%Ŀ�꺯��ѭ��
                if xx(p.V+s)<f(k,p.V+s)
                    dom_less=dom_less+1;
                elseif xx(p.V+s)==f(k,p.V+s)
                    dom_equal=dom_equal+1;
                else
                    dom_more=dom_more+1;
                end
            end
            if dom_less==0&&dom_equal~=p.Mv
                index_sel(k)=1;%�¼���Ľⱻ֧��
            elseif dom_more==0&&dom_equal~=p.Mv
                index_sel(k)=-1;%�ֵ���Ľⱻ֧��
            else
                index_sel(k)=0;
            end
        end
        f(index_sel==-1,:)=[];%ɾȥ�ֵ��ﱻ֧��Ľ�
        if ~any(index_sel==1)==1%��fΪ��ʱ
            [K,~]=size(f);
            f(K+1,1:p.V+p.Mv)=xx;
        end
    end
    
end
f=crowding_distance(f,p);
end