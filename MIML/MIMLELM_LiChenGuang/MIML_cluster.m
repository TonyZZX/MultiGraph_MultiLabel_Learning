function [clustering,matrix_fai,num_iter]=MIML_cluster(num_cluster,distance_matrix)

   rand('state',sum(100*clock));
   [num_bags,tempvalue]=size(distance_matrix);
   indicators=zeros(1,num_bags);
   clustering=cell(num_cluster,1);
   for i=1:num_cluster
       success=0;
       while(success==0)
           pointer=ceil(num_bags*rand);
           if(indicators(1,pointer)==0)
               indicators(1,pointer)=1;
               success=1;
               clustering{i,1}=[clustering{i,1},pointer];
           end
       end
   end
   for i=1:num_bags
       if(indicators(1,i)==0)
           pointer=ceil(num_cluster*rand);
           clustering{pointer,1}=[clustering{pointer,1},i];
       end
   end
   
   indicator=zeros(1,num_bags);
   cur_center=[];
   for i=1:num_cluster
       [tempvalue,clu_size]=size(clustering{i,1});
       temp=-ones(1,clu_size);
       for j=1:clu_size
           temp(1,j)=sum(distance_matrix(clustering{i,1}(1,j),clustering{i,1}));
       end
       [minimum,index]=min(temp);
       clustering{i,1}=clustering{i,1}(1,index);
       indicator(1,clustering{i,1})=i;
       cur_center=[cur_center,clustering{i,1}];
   end
   
   num_iter=0;
   complete=0;
   max_iter=100;
   while(complete==0)
       num_iter=num_iter+1;
       disp(strcat(num2str(num_iter),'/',num2str(max_iter)));
       if(num_iter>max_iter)
           break;
       end
       distance=zeros(num_bags,num_cluster);
       for i=1:num_bags
           if(indicator(1,i)~=0)
               distance(i,:)=ones(1,num_cluster);
               distance(i,indicator(1,i))=0;
           else               
               distance(i,:)=distance_matrix(i,cur_center);
           end
       end
       new_clustering=cell(num_cluster,1);
       for i=1:num_bags
           [tempvalue,index]=min(distance(i,:));
           new_clustering{index,1}=[new_clustering{index,1},i];
       end
       no_empty=1;
       for i=1:num_cluster
           [tempvalue,tempsize]=size(new_clustering{i,1});
           if(tempsize==0)
               no_empty=0;
               break;
           end
       end
       changed=0; 
       if(no_empty==1)
           new_indicator=zeros(1,num_bags);
           new_cur_center=[];
           for i=1:num_cluster
               [tempvalue,clu_size]=size(new_clustering{i,1});
               temp=-ones(1,clu_size);
               for j=1:clu_size
                   temp(1,j)=sum(distance_matrix(new_clustering{i,1}(1,j),new_clustering{i,1}));
               end
               [minimum,index]=min(temp);
               new_clustering{i,1}=new_clustering{i,1}(1,index);
               new_indicator(1,new_clustering{i,1})=i;
               new_cur_center=[new_cur_center,new_clustering{i,1}];
           end
           if(isempty(setdiff(cur_center,new_cur_center))==0)
               changed=1;
           end
       end
       if(changed==1)
           clustering=new_clustering;
           cur_center=new_cur_center;
           indicator=new_indicator;
       else
           complete=1;
       end
   end
   
   matrix_fai=zeros(num_bags,num_cluster);
   for i=1:num_bags       
       matrix_fai(i,:)=distance_matrix(i,cur_center);
   end               