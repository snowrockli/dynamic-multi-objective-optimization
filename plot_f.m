function plot_f(global_dic_dy,V)

plot(global_dic_dy(:,V + 1),global_dic_dy(:,V + 2),'*');
%title('bus_fare');
xlabel('社会成本');
ylabel('碳排放');
      
end