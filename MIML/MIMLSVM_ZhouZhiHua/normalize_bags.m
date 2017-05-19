function processed_bags=normalize_bags(input_bags,para)
%normalize_bags normalizes the input bags according to nomalization parameters.
%
%    Syntax
%
%       processed_bags=normalize_bags(input_bags,para)
%
%    Description
%
%       normalize_bags takes,
%           input_bags     - An Mx1 cell, the jth instance of the ith bag is stored in input_bags{i,1}(j,:)
%           para           - A struct variable specifying the nomalization configuration:
%                            1) If para.type=='column_wise', then all the instances contained in input_bags are put together and normalized 
%                               along each dimension. In this case, para.low and para.high specify the minimum and maximum values for 
%                               normalization respectively;
%                            2) If para.type=='row_wise', then all instances in input_bags are normalized to have L2 norm of 1.
%                            DEFAULT: para.type='column_wise', para.low=0, para.high=1;
%      and returns,
%           processed_bags  - An Mx1 cell, the jth instance of the ith normalized bag is stored in processed_bags{i,1}(j,:)

    if(nargin==1)
        para.type='column_wise';
        para.low=0;
        para.high=1;
    end
    
    if(strcmp(para.type,'column_wise')==1)
        M=size(input_bags,1);
        inst_nums=zeros(1,M);
        
        for i=1:M
            inst_nums(1,i)=size(input_bags{i,1},1);
        end
        vectors=cell2mat(input_bags);
        vectors=min_max_norm(para.low,para.high,vectors);
        
        processed_bags=cell(M,1);
        for i=1:M
            p1=sum(inst_nums(1:(i-1)))+1;
            p2=sum(inst_nums(1:i));
            processed_bags{i,1}=vectors(p1:p2,:);
        end        
    else
        if(strcmp(para.type,'row_wise')==1)
            M=size(input_bags,1);
            processed_bags=cell(M,1);
            for i=1:M
                tempbag=input_bags{i,1};
                tempsize=size(tempbag,1);
                for j=1:tempsize
                    if(norm(tempbag(j,:))~=0)
                        tempbag(j,:)=tempbag(j,:)/norm(tempbag(j,:));
                    end
                end
                processed_bags{i,1}=tempbag;
            end
        else
            error('parameter for normalization not correctly specified, please type "help normalize_bags" for usage reference.');
        end
    end