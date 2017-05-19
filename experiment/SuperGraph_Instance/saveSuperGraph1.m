function features=saveSuperGraph1(cell_name)
%{
idea:
1.loop the data: check in cell array,if any cell is the subgraph of the current
cell,set it null
2.find out which cells in array is not empty,put them into new cell
array,return
%}
%{ 
old
cell_len=size(cell_name,2);
for i=1:cell_len
    if isempty(cell_name{i})
        continue;
    end
    save=cell_name{i};
    idx0=cellfun(@(x)isSuperGraph(x,cell_name{i}),cell_name);%isequal won't compare with itself
    idx0=logical(idx0);
    cell_name(idx0)={[]};   
    cell_name{i}=save;%incase it delete itself
end
%}
%new
cell_len=size(cell_name,2);
for i=1:cell_len
   if isempty(cell_name{i})
       continue;
   end
   for j=1:cell_len
       if j==i
           continue;
       end
       if isSuperGraph(cell_name{j},cell_name{i})
           cell_name{j}=[];
       end
   end
end
% new
t=cellfun(@isempty,cell_name);
idx=find(t==0);
if isempty(idx)%check if is empty
    features={};
else
    features=cell_name(idx);
end
