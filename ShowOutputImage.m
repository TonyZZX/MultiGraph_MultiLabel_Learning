function [ ] = ShowOutputImage( L, rowNum, colNum, idx, image, N, isShowBoundary, isShowMeanColor )
% Display the superpixel boundaries overlaid on the original image.
if isShowBoundary == 1
    figure
    BW = boundarymask(L);
    imshow(imoverlay(image, BW, 'cyan'), 'InitialMagnification', 67)
end

% Set the color of each pixel in the output image to the mean RGB color of
% the superpixel region.
if isShowMeanColor == 1
outputImage = zeros(size(image), 'like', image);
    for num = 1:N
        redIdx = idx{num};
        greenIdx = idx{num} + rowNum * colNum;
        blueIdx = idx{num} + 2 * rowNum * colNum;
        outputImage(redIdx) = mean(image(redIdx));
        outputImage(greenIdx) = mean(image(greenIdx));
        outputImage(blueIdx) = mean(image(blueIdx));
    end
    figure
    imshow(outputImage, 'InitialMagnification', 67)
end
end
