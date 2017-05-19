function [ graph ] = txt2graph( file_name )
fileID = fopen(file_name, 'r');
% if it is not the end line of the file
num = 1;
node = 0;
edge = 0;
node_count = 1;
edge_count = 1;
while ~feof(fileID)
    % read one line
    line = fgetl(fileID);
    % split it by space
    split_str = strsplit(string(line),' ');
    if (split_str(1) == 't')
        if (node_count ~= 1 && edge_count ~= 1)
            % build graph
            field1 = 'nodelabels';
            value1 = uint32(node);
            % Build edges
            field2 = 'edges';
            value2 = uint32(edge);
            graph{num} = struct(field1, value1, field2, value2);
            num = num + 1;
        end
        node = 0;
        edge = 0;
        node_count = 1;
        edge_count = 1;
    end
    if (split_str(1) == 'v')
        node(node_count, 1) = split_str(3);
        node_count = node_count + 1;
    end
    if (split_str(1) == 'e')
        edge(edge_count, 1) = str2num(char(split_str(2))) + 1;
        edge(edge_count, 2) = str2num(char(split_str(3))) + 1;
        edge(edge_count, 3) = split_str(4);
        edge_count = edge_count + 1;
    end
end
fclose(fileID);
end