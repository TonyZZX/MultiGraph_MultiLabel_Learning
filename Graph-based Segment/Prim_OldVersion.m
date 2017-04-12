% Show points
% figure;
p=cell2mat(centralCoordinates');
% scatter(p(:,1), p(:,2), 'blue', 'filled');

% Show points with edges
% figure;
% scatter(p(:,1), p(:,2), 'blue', 'filled');
% for num=1:length(std_edges)
%     line([p(std_edges(num,1),1),p(std_edges(num,2),1)],[p(std_edges(num,1),2),p(std_edges(num,2),2)]);
% end

% Cluster to 4 heaps
idx=kmeans(p,4);
count=zeros(4,1);
am=zeros(length(std_edges));
for cnt=1:length(std_edges)
    am(std_edges(cnt,1),std_edges(cnt,2))=std_edges(cnt,3);
end
% figure;
% scatter(p(:,1), p(:,2), 'blue', 'filled');
for num=1:length(idx)
%     hold on;
    tmp=idx(num);
%     switch(tmp)
%         case 1
%             scatter(p(num,1), p(num,2), 'blue', 'filled');
%             count(1)=count(1)+1;
%             point_set(count(1),1)=num;
%         case 2
%             scatter(p(num,1), p(num,2), 'red', 'filled');
%             count(2)=count(2)+1;
%             point_set(count(2),2)=num;
%         case 3
%             scatter(p(num,1), p(num,2), 'green', 'filled');
%             count(3)=count(3)+1;
%             point_set(count(3),3)=num;
%         case 4
%             scatter(p(num,1), p(num,2), 'yellow', 'filled');
%             count(4)=count(4)+1;
%             point_set(count(4),4)=num;
%         otherwise
%     end
    count(tmp)=count(tmp)+1;
    point_set(count(tmp),tmp)=num;
end

% Prim
for num=1:4
    clear mir_t eset_tmp etable gtmp ttmp tedge;
    k=1;
    for i=1:count(num)
        for j=i+1:count(num)
            if am(point_set(i,num),point_set(j,num))~=0
                eset_tmp(k,1)=i;
                eset_tmp(k,2)=j;
                eset_tmp(k,3)=am(point_set(i,num),point_set(j,num));
                mir_t(i)=point_set(i,num);  %ding dian ming cheng dui zhao biao
                mir_t(j)=point_set(j,num);
                %{
                if mir_t(i)==0
                    mir_t(i)=point_set(j-1,num);
                end
                %}
                k=k+1;
            end
        end
    end
    mir{1,num}=mir_t;
    edge_set{1,num}=eset_tmp;
    etable = table(eset_tmp(:,1:2),eset_tmp(:,3),'VariableNames',{'EndNodes','Weight'});
    EdgeTable{1,num}=etable;
    gtmp=graph(etable);
    G{1,num}=gtmp;
    ttmp=minspantree(gtmp);
    T{1,num}=ttmp;
    tedge=ttmp.Edges.EndNodes;
    tedge(:,3)=ttmp.Edges.Weight;
    for i=1:length(tedge)
        tedge(i,1)=mir_t(tedge(i,1));
        tedge(i,2)=mir_t(tedge(i,2));
    end
    true_edge{1,num}=tedge;
    hold on;
    for i=1:length(tedge)
        line([p(tedge(i,1),1),p(tedge(i,2),1)],[p(tedge(i,1),2),p(tedge(i,2),2)]);
        hold on;
    end
end
