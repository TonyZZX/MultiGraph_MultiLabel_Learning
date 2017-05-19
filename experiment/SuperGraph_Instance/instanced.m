function [instanceBags] = instanced (gBags, subgs)

for i=1:length(gBags)
	for j=1:length(gBags{i})
		 %把所有图存入cell向量G中
         for k=1:length(subgs)
            [count,ma] = graphmatch (subgs{k},gBags{i}{j}, 1, 0);
            if(count>0)
                instanceBags{i}(j,k)=1;
            else
                instanceBags{i}(j,k)=0;
            end
         end
	end
end

instanceBags=instanceBags';


