function wd=rand_d(M)
for k=1:M
    randd(k)=rand;
end
randxigemad=sum(randd(:));
for k=1:M
    wd(k)=randd(k)/randxigemad;
end
return