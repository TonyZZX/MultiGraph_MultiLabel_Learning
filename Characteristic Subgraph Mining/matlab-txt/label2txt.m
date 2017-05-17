function [] = label2txt( label, graph )
% need graph to identify the number of graphs in each bag
fileID = fopen('label','w');
m = 0;
for i = 1 : length(label)
    for j = 1 : length(graph{i})
        fprintf(fileID, 't # %d\n', m);
        for k = 1 : length(label(i, :))
            fprintf(fileID, 'l %d %d\n', k - 1, label(i, k));
        end
        m = m + 1;
    end
end
fprintf(fileID, 't # -1');
fclose(fileID);

end

