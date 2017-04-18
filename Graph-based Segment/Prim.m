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
    pset(count(tmp),tmp)=num;
end
% Prim
for num=1:heapNum
    clear mir_t eset_tmp etable gtmp ttmp tedge ptmp;
    k=1;
    point_set{1,num}=1:count(num);
    for i=1:count(num)
        for j=i+1:count(num)
            if am(pset(i,num),pset(j,num))~=0
                eset_tmp(k,1)=i;
                eset_tmp(k,2)=j;
                eset_tmp(k,3)=am(pset(i,num),pset(j,num));
                k=k+1;
            end
        end
    end
    edge_set{1,num}=eset_tmp;
    etable = table(eset_tmp(:,1:2),eset_tmp(:,3),'VariableNames',{'EndNodes','Weight'});
    EdgeTable{1,num}=etable;
    gtmp=graph(etable);
    G{1,num}=gtmp;
    ttmp=minspantree(gtmp);
    T{1,num}=ttmp;
    tedge=ttmp.Edges.EndNodes;
    tedge(:,3)=1;
    true_edge{1,num}=tedge;
    
    % Get label from nodes. Compare it with point_set. Bulid nodes

    nodesTemp = 0;
    for i = 1:count(num)
        nodesTemp(i, 1) = nodes(pset(i,num), 1);
    end

    field1 = 'nodelabels';
    value1 = uint32(nodesTemp);
    % Build edges
    field2 = 'edges';
    value2 = uint32(tedge);
%    edgeTable = table(edgesTemp(:,1:2), edgesTemp(:,3), 'VariableNames', {'EndNodes','Weight'});
    graphs{num} = struct(field1, value1, field2, value2);
end
end


