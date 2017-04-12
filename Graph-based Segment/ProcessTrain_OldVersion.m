 %【训练集】
 %{
data=importdata('corel5k_train_list.txt');
    length=length(data);
    path='./真正的Corel5k数据集(带标注,训练与测试集)/';
    gBagsTrain=cell(1,length);
    for i=1:length
        img_path=strcat(path,data{i},'.jpeg');
        im=imread(img_path);
        %处理图片
        %存数据
    end
 %}
clc;
clear;
tic;
run('./vlfeat-0.9.20-bin\vlfeat-0.9.20\toolbox\vl_setup')
data=importdata('./真正的Corel5k数据集(带标注,训练与测试集)/corel5k_test_list.txt');%【改文件名】

    length=length(data);
    
    path='./真正的Corel5k数据集(带标注,训练与测试集)/';
    gBagsTest=cell(1,length);%%【改test】
    for i=1:length
        img_path=strcat(path,data{i},'.jpeg');
        im=imread(img_path);
       %处理图片 
        ims = im2single(im) ;
        regionSize = 10 ;
        regularizer = 10 ;
        segments = vl_slic(ims, regionSize, regularizer);
        regionSize2 = 50;
        segments2 = vl_slic(ims, regionSize2, regularizer);
        minS=min(min(segments));%求segments矩阵中的最小值
        maxS=max(max(segments));%求segments矩阵中的最大值
        [ms ns]=size(segments);

        %确定每个点在4096中的第几维
        [a0 b0 c0]=size(im);
        im1=double(im);%数据类型的关系，为了后面的计算，转换im的类型为double型
        imt=floor(im1./16);%这里转换了一下数据类型，否则计算4096时会溢出;16bin;向下取整
        %(整数计算结果也是整数，而且直接向上取整)
        ref4096=zeros(a0,b0);%此矩阵记录各点对应4096维中的第几维
        %因为是RGB三维，直接按RGB由高到低的顺序加倍数计算对应的4096值
        %即：x=R*(16^2)+B*16+G;
        ref4096=imt(:,:,1).*(16^2)+imt(:,:,2).*16+imt(:,:,3);%取值范围0-4095

        %生成各超像素点对应的4096维向量
        SuperPixel4096=zeros(1,max(max(segments))+1);%因为MATLAB中矩阵从1开始，所以第i个超像素点对应的向量是本矩阵中的第i+1行
        %【同理】ref4096中若ref4096(i,j)=m,则对应的是SuperPixel4096中第i+1行，j+1列的值+1

        for r1=minS:maxS %暂时想不到比for更有效率的方法
            temp4096=zeros(1,4096);
            idx=find(segments==r1);%idx是一个列向量
            temp=ref4096(idx);
            if size(idx)>0
                for r2=1:size(idx)
                 temp4096(temp(r2)+1)=temp4096(temp(r2)+1)+1;
                end
            end
            %取4096中值最大的一维
            [t idxm]=max(temp4096);
            SuperPixel4096(r1+1)=idxm;
        end
%求各区域中所含的超像素点
    minR=min(min(segments2));%求segments矩阵中的最小值
    maxR=max(max(segments2));%求segments矩阵中的最大值
    RegionV=zeros(maxR+1,maxS+1);%【看每个区域的SP】记录每个区域（子图）含有那些超像素点的矩阵
    for r1=minR:maxR
        idxi=find(segments2==r1);
        tempi=double(segments(idxi));
        tablei=tabulate(tempi);%tabulate是一个分析矩阵中各数出现的频数的函数。（递增顺序）
         %tablet=double(tablet);
        idxi1=find(tablei(:,2)~=0);%找出索引中频数不为0的值    
        [m1 n1]=size(idxi1);
      
        RegionV(r1+1,1:m1)=tablei(idxi1,1)';%RegionV中存的是实际超像素点序号
    
    end
graphSP=zeros(maxR+1,maxS+1,maxS+1);%
graphs=cell(1,maxR+1);
%（因为矩阵表达关系，子图0对应的图（graph）则为第一维值为1对应的矩阵）

for r1=1:(maxR+1)%圈范围找点法【有边缘误差--把别的区域的点会画进来】
       %graphi=cell(2,1);
       edges=[];
      
        [mi ni]=find(segments2==(r1-1));%确定segments中对应于segments2的i区域的位置；注意矩阵值和实际数值的对应
        Vertexi=find(RegionV(r1,:)~=0);%记录区域i中有哪些superpixel
        idxnl=Vertexi';
        if idxnl(1)~=1%排除一不小心把0超像素点给撇了的错误
            idxnl=[1;idxnl];
        end
        [idxnlx,idxnly]=size(idxnl);%不知这里为什么不能用函数length()
        [Vertexix,Vertexiy]=size(Vertexi);
         nodelabels=zeros(idxnlx,1);
         nodelabels=SuperPixel4096(RegionV(r1,idxnl)'+1)'-1;
        for r2=1:Vertexiy
            [mj nj]=find(segments==RegionV(r1,r2));
            segt=segments(max(min(mj)-1,min(mi)):min(max(mj)+1,max(mi)),max((nj)-1,min(ni)):min(max(nj)+1,max(ni)));%划出包含superpixlj的最小加1矩阵
             %上面这区域画的比较粗糙（存在对角相连（就是正好一个对角有连接））
            idxj=find(segt~=RegionV(r1,r2));
            tablej=tabulate(double(segt(idxj)));%划分超像素点i-1对应的最小包含矩形（阵）
            idxj1=find(tablej(:,2)~=0);    
            nsq=tablej(idxj1,1);
            for m=1:size(nsq)%这改成存的是超像素点在图中的自然顺序序号
                idm=0;
                if nsq(m)==0%省得一不小心找了一堆0
                 idm=1;
                else
                idm=find(RegionV(r1,:)==nsq(m));
            end
            if isempty(idm)~=1 %%算法误差,得加这一项；【这也算一种避错措施】
                if graphSP(r1,r2,idm)==0 &&(r2<=idm)
                     graphSP(r1,r2,idm)=1;%用的时候将取出来的非1位置值都减1即可
                     edges=[edges;r2 idm 1];
                 %只存小->大的关系
                % graphSP(i,nsq(m)+1,RegionV(i,j)+1)=1;%无向图中两点相连产生的对称关系
                    end
                end
            end
        end
    
   %graphs{r1}={nodelabels;edges};
   graphs{r1}.nodelabels=uint32(nodelabels);
   graphs{r1}.edges=uint32(edges);
    end
   
        %按格式存数据
        
        gBagsTest{i}=graphs;%【改test】
        fprintf('processing:%d\n',i);

    end
    toc;
   