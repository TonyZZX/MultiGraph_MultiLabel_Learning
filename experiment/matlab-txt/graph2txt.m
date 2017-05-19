function [] = graph2txt( graph, file_name )
fileID = fopen(file_name, 'w');
m = 0;
for i = 1 : length(graph)
    for j = 1 : length(graph{i})
        fprintf(fileID, 't # %d\n', m);
        for k = 1 : length(graph{i}{j}.nodelabels)
            fprintf(fileID, 'v %d %d\n', k - 1, graph{i}{j}.nodelabels(k));
        end
        for k = 1 : length(graph{i}{j}.edges)
            fprintf(fileID, 'e %d %d 1\n', graph{i}{j}.edges(k, 1) - 1, graph{i}{j}.edges(k, 2) - 1);
        end
        m = m + 1;
    end
end
fprintf(fileID, 't # -1');
fclose(fileID);

end

