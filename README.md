# Multi-Graph Multi-Label Learning

## Abstract

Recently, Multi-Graph Learning was proposed as the extension of Multi-Instance Learning and has achieved some successes. However, to the best of our knowledge, currently, there is no study working on Multi-Graph Multi-Label Learning, where each object is represented as a bag containing a number of graphs and each bag is marked with multiple class labels. It is an interesting problem existing in many applications, such as image classification, medicinal analysis and so on. In this paper, we propose an innovate algorithm to address the problem. Firstly, it uses more precise structures, multiple Graphs, instead of Instances to represent an image so that the classification accuracy could be improved. Then, it uses multiple labels as the output to eliminate the semantic ambiguity of the image. Furthermore, it calculates the entropy to mine the informative sub-graphs instead of just mining the frequent sub-graphs, which enables selecting the more accurate features for the classification. Lastly, since the current algorithms cannot directly deal with graph-structures, we degenerate the Multi-Graph Multi-Label Learning into the Multi-Instance Multi-Label Learning in order to solve it by MIML-ELM (Improving Multi-Instance Multi-Label Learning by Extreme Learning Machine). The performance study shows that our algorithm outperforms the competitors in terms of both effectiveness and efficiency.

The details of `MGML` can be found in the following papers:

*Zhu, Z.; Zhao, Y.	Multi-Graph Multi-Label Learning Based on Entropy. Entropy 2018, 20, 245.* [[pdf](/entropy-20-00245.pdf)]

## Source Code

Innovative algorithm `ESM` mentioned in the paper could be found [here](/ESM).

Unfortunately, since we used some pioneers' codes, `Graph Segment`, `MIML-ELM` and `MIML-SVM` cannot be public due to confidentiality agreement.

However, I rewrote some of them to realize `MGML` Learning and all these codes can be used freely as long as you follow the [license](/LICENSE). Although the effectiveness and efficiency cannot be guaranteed as well as in the paper, you can still experience our advanced `MGML` algorithm!

## How to run

1. Segment original images into graphs
```
$ python ./py/segment_batch.py -l ./MSRC_v2/list_Images.txt -n 500 -p ./MSRC_v2/Images/ -g ./result/MSRC_v2_graph
```
2. Mine the informative sub-graphs
```
$ cd ./ESM/target/
$ java -cp ESM-1.1-jar-with-dependencies.jar:./* cn.edu.neu.esm.MainKt -d MSRC_v2_graph -l MSRC_v2_label -s 3 -e 0.25 -r ../../result/MSRC_v2_subgraph
$ cd ../../
```
3. Transform to instances
```
$ cd ./GraphToInstance/GraphToInstance/
$ ./GraphToInstance -g ../../result/MSRC_v2_graph -s ../../result/MSRC_v2_subgraph -i ../../result/MSRC_v2_instance.csv
$ cd ../../
```
4. Transform label file to `.csv` file
```
$ python ./py/label_to_csv.py -l ./MSRC_v2/MSRC_v2_label -o ./result/MSRC_v2_label.csv
```
6. Build the DNN classifier
```
$ python ./py/classifier.py -i ./result/MSRC_v2_instance.csv -l ./result/MSRC_v2_label.csv -s 5000 -m ./result/MSRC_v2_model.h5
```
7. Predict
```
$ python ./py/predict.py -i ./result/MSRC_v2_instance.csv -m ./result/MSRC_v2_model.h5 -d 23 -l ./result/MSRC_v2_label.csv
```