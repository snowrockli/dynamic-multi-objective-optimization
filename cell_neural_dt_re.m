function cell=cell_neural_dt_re(cell,i,j,t,M,theita,N_agent_length)
if i~=j
    input_num=M;%%输入层神经元数量,M种不同出发时间
    hidden_layer_num=2*input_num+1;%隐含层神经元数量
    output_num=M;%输出层神经元数量
    for ii=1:N_agent_length
        for jj=1:N_agent_length
            if t==1
               cell{i,j}.cell{ii,jj}.risk_dt=rand;%风险态度 
            end
            %=============计算后悔值================
            min_departure_fee=min(cell{i,j}.departure_fee(:));
            for dt=1:M
                cell{i,j}.cell{ii,jj}.dt_regret(dt)=cell{i,j}.departure_fee(dt)-1+exp(-cell{i,j}.cell{ii,jj}.risk_dt*(min_departure_fee-cell{i,j}.departure_fee(dt)));
            end
        end
    end
    if t==1
        for ii=1:N_agent_length
            for jj=1:N_agent_length
                %========计算出发时间选择概率========================
                cell{i,j}.cell{ii,jj}.input_dt=cell{i,j}.cell{ii,jj}.dt_regret(1:M);
                cell{i,j}.cell{ii,jj}.W1_dt=-1+(1+1)*rand(input_num,hidden_layer_num);%输入层与隐含层之间权重
                cell{i,j}.cell{ii,jj}.W2_dt=-1+(1+1)*rand(hidden_layer_num,output_num);%隐含层与输出层间权重
                cell{i,j}.cell{ii,jj}.output_dt=cell{i,j}.cell{ii,jj}.input_dt*cell{i,j}.cell{ii,jj}.W1_dt*cell{i,j}.cell{ii,jj}.W2_dt;%神经网络的输出
                %========sigmoid函数归一化========
                cell{i,j}.cell{ii,jj}.sig_output_dt=1./(1+exp(-cell{i,j}.cell{ii,jj}.output_dt));%sigmoid函数
                cell{i,j}.cell{ii,jj}.sum_sig_dt=sum(cell{i,j}.cell{ii,jj}.sig_output_dt);
                if cell{i,j}.cell{ii,jj}.sum_sig_dt==0
                    cell{i,j}.cell{ii,jj}.sig_output_dt=(1/output_num)*ones(1,output_num);
                end
                cell{i,j}.cell{ii,jj}.sum_sig_dt=sum(cell{i,j}.cell{ii,jj}.sig_output_dt);
                cell{i,j}.cell{ii,jj}.new_output_dt=cell{i,j}.cell{ii,jj}.sig_output_dt./cell{i,j}.cell{ii,jj}.sum_sig_dt;%概率和为1
                for ss=1:M
                    q_cell(ss,ii,jj)=cell{i,j}.cell{ii,jj}.new_output_dt(ss);
                end
            end
        end
        %=============出发时间选择概率=========
        for dt=1:M
            cell{i,j}.wd(dt)=mean(mean(q_cell(dt,:,:)));
        end
    end
    %=========每个元胞（出行者）预测出发时间预期费用==========
    for ii=1:N_agent_length
        for jj=1:N_agent_length
            cell{i,j}.cell{ii,jj}.input_dt=cell{i,j}.cell{ii,jj}.dt_regret(1:M);
            for s=1:output_num
                cell{i,j}.cell{ii,jj}.fee_dt(s)=cell{i,j}.cell{ii,jj}.input_dt(s)*cell{i,j}.cell{ii,jj}.new_output_dt(s);%加权出行费用
            end
            cell{i,j}.cell{ii,jj}.g_fee_dt=sum(cell{i,j}.cell{ii,jj}.fee_dt);%估计总出行费用
        end
    end
    %=========学习进化（学习周围的经验）=================
    for ii=2:N_agent_length-1
        for jj=2:N_agent_length-1
            %======收集周围信息=====
            i_index=1;
            for pp=ii-1:ii+1
                for qq=jj-1:jj+1
                    cell{i,j}.cell{ii,jj}.experience_dt(i_index,:)=[cell{i,j}.cell{pp,qq}.g_fee_dt,pp,qq];
                    i_index=i_index+1;
                end
            end
            %========定位到周围最好的经验=========
            cell{i,j}.cell{ii,jj}.best_dt=find(cell{i,j}.cell{ii,jj}.experience_dt==min(cell{i,j}.cell{ii,jj}.experience_dt(:,1)));
            best_index=cell{i,j}.cell{ii,jj}.best_dt;
            best_x=cell{i,j}.cell{ii,jj}.experience_dt(best_index,2);
            best_y=cell{i,j}.cell{ii,jj}.experience_dt(best_index,3);
            %=======学习交互==============
            cell{i,j}.cell{ii,jj}.risk_dt=(1-theita)*cell{i,j}.cell{ii,jj}.risk_dt+theita*cell{i,j}.cell{best_x(1),best_y(1)}.risk_dt;
            cell{i,j}.cell{ii,jj}.W1_dt=(1-theita)*cell{i,j}.cell{ii,jj}.W1_dt+theita*cell{i,j}.cell{best_x(1),best_y(1)}.W1_dt;
            cell{i,j}.cell{ii,jj}.W2_dt=(1-theita)*cell{i,j}.cell{ii,jj}.W2_dt+theita*cell{i,j}.cell{best_x(1),best_y(1)}.W2_dt;
            %=======计算出行方式选择概率=======
            cell{i,j}.cell{ii,jj}.output_dt=cell{i,j}.cell{ii,jj}.input_dt*cell{i,j}.cell{ii,jj}.W1_dt*cell{i,j}.cell{ii,jj}.W2_dt;%神经网络的输出
            %========sigmoid函数归一化========
            cell{i,j}.cell{ii,jj}.sig_output_dt=1./(1+exp(-cell{i,j}.cell{ii,jj}.output_dt));%sigmoid函数
            cell{i,j}.cell{ii,jj}.sum_sig_dt=sum(cell{i,j}.cell{ii,jj}.sig_output_dt);
            if cell{i,j}.cell{ii,jj}.sum_sig_dt==0
                cell{i,j}.cell{ii,jj}.sig_output_dt=(1/output_num)*ones(1,output_num);
            end
            cell{i,j}.cell{ii,jj}.sum_sig_dt=sum(cell{i,j}.cell{ii,jj}.sig_output_dt);
            cell{i,j}.cell{ii,jj}.new_output_dt=cell{i,j}.cell{ii,jj}.sig_output_dt./cell{i,j}.cell{ii,jj}.sum_sig_dt;%概率和为1
        end
    end
    for ii=1:N_agent_length
        for jj=1:N_agent_length
            for ss=1:M
                q_cell(ss,ii,jj)=cell{i,j}.cell{ii,jj}.new_output_dt(ss);
            end
        end
    end
    %==========出发时间选择概率=============
    for dt=1:M
        cell{i,j}.wd(dt)=mean(mean(q_cell(dt,:,:)));
    end
    
end
end