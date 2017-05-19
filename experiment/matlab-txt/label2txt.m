function [] = label2txt( label, graph, file_name )
% need graph to identify the number of graphs in each bag
fileID = fopen(file_name, 'w');
m = 0;
% graph number
for i = 1 : length(label)
    for j = 1 : length(graph{i})
        fprintf(fileID, 't # %d\n', m);
        % multi label
        for k = 1 : length(label(:, i))
            fprintf(fileID, 'l %d %d\n', k - 1, label(k, i));
        end
        m = m + 1;
    end
end
fprintf(fileID, 't # -1');
fclose(fileID);
end

