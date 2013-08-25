clear

load digits.mat
t=cputime;        %record the start time of the program      
s = 0;            %counter to sum the accuarcy of the running cycles
rts = 1;        %Times to train and test the RBF with K-means
k = 100;          %centers to be classified

disp(['k =' num2str(k)]);
disp('Start...');

for loops=1:rts

%Get training set ,crossvalide train and test for 1
[train test] = crossvalind('HoldOut',size(X,1),0.2);
xtrain =X(train,:);
xtest  =X(test,:);
t_train =Y(train,:);
t_test =Y(test,:);

%reconstruct the t_train output into 4 dimensions
t_train_plus=zeros(size(t_train,1),4);
for i=1:size(t_train,1)
            if t_train(i,1) == 1
                t_train_plus(i,1)=1;
                
            elseif t_train(i,1) == 2
                t_train_plus(i,2)= 1;
                
            elseif t_train(i,1) == 3
                t_train_plus(i,3)= 1;
                
            elseif t_train(i,1) == 4
                t_train_plus(i,4)= 1;
            end
end 

%finding kmeans' center
[idx,ctrs,sumd,D]= kmeans(xtrain,k);

%train the RBF netowrk to calculate the weight and basis values.
[nodenum centerrow]=size(ctrs);
row=size(xtrain,1);
nodeout = zeros(size(xtrain,1),k);
netout = zeros(size(xtest,1),k);

%gussian function
for step=1:row                    
    for step1=1:nodenum
        nodeout(step,step1)=exp(-(norm(xtrain(step,:)-ctrs(step1,:))^2)/1000);
    end % this end for step1=1:nodenum
end %this end for step=1:row

%pesudo-inverse to get the weight of the network
weight = pinv(nodeout)*t_train_plus;

%simulate 
simrow=size(xtest,1);
for step=1:simrow
    for step1=1:nodenum
        netout(step,step1)=exp(-(norm(xtest(step,:)-ctrs(step1,:))^2)/1000);
    end % this end for step1=1:nodenum
end %this end for step=1:simrow

%output the correspoding traget vectors
target=netout*weight;

%translate output of target dataset into one demension (1~4)
m_t = target';
[M,I]=max(m_t);
result = I';

%Evaluation function to get accuracy of network
s=sum(result==t_test)/size(t_test,1)+s;

end

e=cputime-t;
disp('Finshing!');
disp(['Average Accuracy of RBF with K-means is: ' num2str(s/rts)]);
disp(['Average CPU runningtime of RBF with K-menas is: ' num2str(e/rts)]); 
