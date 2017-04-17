function [ graphs ] = Prim( coordinates, nodes, edges, heapNum )
p=cell2mat(coordinates');

% Cluster to [heapNum] heaps
idx=kmeans(p,heapNum);
count=zeros(heapNum,1);
am=zeros(length(edges));
for cnt=1:length(edges)
    am(edges(cnt,1),edges(cnt,2))=edges(cnt,3);
end
for num=1:length(idx)
    tmp=idx(num);
    count(tmp)=count(tmp)+1;
    point_set(count(tmp),tmp)=num;
end

% Prim
for num=1:heapNum
    clear mir_t eset_tmp etable gtmp ttmp tedge;
    k=1;
    for i=1:count(num)
        for j=i+1:count(num)
            if am(point_set(i,num),point_set(j,num))~=0
                eset_tmp(k,1)=i;
                eset_tmp(k,2)=j;
                eset_tmp(k,3)=am(point_set(i,num),point_set(j,num));
                %mir_t(i)=point_set(i,num);  %ding dian ming cheng dui zhao biao
                %mir_t(j)=point_set(j,num);
                k=k+1;
            end
        end
    end
    %mir{1,num}=mir_t;
    edge_set{1,num}=eset_tmp;
    etable = table(eset_tmp(:,1:2),eset_tmp(:,3),'VariableNames',{'EndNodes','Weight'});
    EdgeTable{1,num}=etable;
    gtmp=graph(etable);
    G{1,num}=gtmp;
    ttmp=minspantree(gtmp);
    T{1,num}=ttmp;
    tedge=ttmp.Edges.EndNodes;
    tedge(:,3)=1;
%{
    for i=1:length(tedge)
        tedge(i,1)=mir_t(tedge(i,1));
        tedge(i,2)=mir_t(tedge(i,2));
    end
%}
    true_edge{1,num}=tedge;
    
    % Get label from nodes. Compare it with point_set. Bulid nodes
    countP = 1;
    nodesTemp = 0;
    for i = 1:length(point_set)
        point = point_set(i, num);
        if (point ~= 0)
            nodesTemp(countP, 1) = nodes(point, 1);
            countP = countP + 1;
        end
    end
    field1 = 'nodelabels';
    value1 = uint32(nodesTemp);
%     nodeTable = table(nodesTemp(:,1));
    % Build edges
    edgesTemp = 0;
    for i=1:length(point_set)
        if(point_set(i,num)==0)
            break;
        end
        point_set(i,num)=i;
    end
    for i = 1:length(tedge)
%{
        if tedge(i, 3) == 0
            continue;
        end
%}
        for j = 1:length(point_set)
            point = point_set(j, num);
            if point == tedge(i, 1)
                edgesTemp(i, 1) = j;
                break;
            end
        end
        for j = 1:length(point_set)
            point = point_set(j, num);
            if point == tedge(i, 2)
                edgesTemp(i, 2) = j;
                break;
            end
        end
        edgesTemp(i, 3) = 1;
    end
    field2 = 'edges';
    value2 = uint32(edgesTemp);
%     edgeTable = table(edgesTemp(:,1:2), edgesTemp(:,3), 'VariableNames', {'EndNodes','Weight'});
    graphs{num} = struct(field1, value1, field2, value2);
end
end

