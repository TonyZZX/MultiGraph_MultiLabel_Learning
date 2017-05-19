function [ new_label ] = label_minus1( old_label )
% 把标签变成-1 标签数 * 图个数
[m, n] = size(old_label);
for i = 1 : m
    for j = 1 : n
        if old_label(i,j) <= 0
            new_label(j,i) = -1;
        else
            new_label(j,i) = 1;
        end
    end
end