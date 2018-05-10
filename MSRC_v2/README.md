# MSRC v2

MSRC v2 is a subset of the Microsoft Research Cambridge (MSRC) image data set. It contains 591 images and 23 classes of labels. About 80% of images belong to more than 1 label and there are about 3 labels per image on average.

`Images` is from the [original data set website](https://www.microsoft.com/en-us/research/project/image-understanding/), and `newsegmentations_mats` is from the [cleaned-up version](http://www.cs.cmu.edu/~tmalisie/projects/bmvc07/).

The MATLAB script `Extract_MSRC_v2_Label.m` is used to extract labels of MSRC v2 into one file: `MSRC_v2_label`.

The order of labels is listed below:

| Num | Label     |
| --- | --------- |
| 0   | building  |
| 1   | grass     |
| 2   | tree      |
| 3   | cow       |
| 4   | horse     |
| 5   | sheep     |
| 6   | sky       |
| 7   | mountain  |
| 8   | aeroplane |
| 9   | water     |
| 10  | face      |
| 11  | car       |
| 12  | bicycle   |
| 13  | flower    |
| 14  | sign      |
| 15  | bird      |
| 16  | book      |
| 17  | chair     |
| 18  | road      |
| 19  | cat       |
| 20  | dog       |
| 21  | body      |
| 22  | boat      |

As the document in MSRC v2 said, please note that there are really not many examples of horses and mountains. You may consider not using those labels.