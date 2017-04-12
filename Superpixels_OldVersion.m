A = imread('raw.png');
[L,N] = superpixels(A,10);
numRows = size(A,1);
numCols = size(A,2);

% cal central coordinate and edges
pixels_coordinates = cell(1, N);
pixels_edges = cell(1, N);
for num = 1:N
%     % cal horizental
%     count = 1;
%     for i = 1:numRows
%         min = numCols;
%         max = 1;
%         for j = 1:numCols
%             if L(i, j) == num
%                 if j < min
%                     min = j;
%                 end
%                 if j > max
%                     max = j;
%                 end
%             end
%         end
%         if (min == numCols) && (max == 0)
%             continue
%         end
%         mean_j(count) = (min + max) / 2;
%         count = count + 1;
%     end
%     mean_all_j = mean(mean_j) / numCols;
%     mean_j = 0;
%     
%     % cal vertical
%     count = 1;
%     for j = 1:numCols
%         min = numRows;
%         max = 0;
%         for i = 1:numRows
%             if L(i, j) == num
%                 if i < min
%                     min = i;
%                 end
%                 if i > max
%                     max = i;
%                 end
%             end
%         end
%         if (min == numRows) && (max == 0)
%             continue
%         end
%         mean_i(count) = (min + max) / 2;
%         count = count + 1;
%     end
%     mean_all_i = mean(mean_i) / numRows;
%     mean_i = 0;
    pixels_coordinates{num} = CalMeanCoordinate(L, numRows, numCols, num);
    pixels_edges{num} = FindEdges(L, numRows, numCols, num);
end

idx = label2idx(L);
meanColor = cell(1, N);
for labelVal = 1:N
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    mean_red = mean(A(redIdx));
    mean_green = mean(A(greenIdx));
    mean_blue = mean(A(blueIdx));
    meanColor{labelVal} = [mean_red, mean_green, mean_blue];
end

% Display the superpixel boundaries overlaid on the original image.
figure
BW = boundarymask(L);
imshow(imoverlay(A,BW,'cyan'),'InitialMagnification',67)

% Set the color of each pixel in the output image to the mean RGB color of
% the superpixel region.
outputImage = zeros(size(A),'like',A);
for labelVal = 1:N
    redIdx = idx{labelVal};
    greenIdx = idx{labelVal}+numRows*numCols;
    blueIdx = idx{labelVal}+2*numRows*numCols;
    outputImage(redIdx) = mean(A(redIdx));
    outputImage(greenIdx) = mean(A(greenIdx));
    outputImage(blueIdx) = mean(A(blueIdx));
end
figure
imshow(outputImage,'InitialMagnification',67)