function [ meanColor ] = CalMeanColor( L, rowNum, colNum, num, idx, image )
redIdx = idx{num};
greenIdx = idx{num} + rowNum * colNum;
blueIdx = idx{num} + 2 * rowNum * colNum;
meanRed = mean(image(redIdx));
meanGreen = mean(image(greenIdx));
meanBlue = mean(image(blueIdx));
meanColor = [meanRed, meanGreen, meanBlue];
end

