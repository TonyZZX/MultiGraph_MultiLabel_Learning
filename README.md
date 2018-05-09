# Multi-Graph Multi-Label Learning

## Abstract

Recently, Multi-Graph Learning was proposed as the extension of Multi-Instance Learning and has achieved some successes. However, to the best of our knowledge, currently, there is no study working on Multi-Graph Multi-Label Learning, where each object is represented as a bag containing a number of graphs and each bag is marked with multiple class labels. It is an interesting problem existing in many applications, such as image classification, medicinal analysis and so on. In this paper, we propose an innovate algorithm to address the problem. Firstly, it uses more precise structures, multiple Graphs, instead of Instances to represent an image so that the classification accuracy could be improved. Then, it uses multiple labels as the output to eliminate the semantic ambiguity of the image. Furthermore, it calculates the entropy to mine the informative sub-graphs instead of just mining the frequent sub-graphs, which enables selecting the more accurate features for the classification. Lastly, since the current algorithms cannot directly deal with graph-structures, we degenerate the Multi-Graph Multi-Label Learning into the Multi-Instance Multi-Label Learning in order to solve it by MIML-ELM (Improving Multi-Instance Multi-Label Learning by Extreme Learning Machine). The performance study shows that our algorithm outperforms the competitors in terms of both effectiveness and efficiency.

The details of `MGML` can be found in the following papers:

*Zhu, Z.; Zhao, Y.	Multi-Graph Multi-Label Learning Based on Entropy. Entropy 2018, 20, 245.* [[pdf](/entropy-20-00245.pdf)]

## Source Code

Innovative algorithm `ESM` mentioned in the paper could be found [here](/ESM).

Unfortunately, since we used some pioneers' codes, `Graph Segment`, `MIML-ELM` and `MIML-SVM` cannot be public due to confidentiality agreement.

However, I rewrote some of them to realize `MGML` Learning and all these codes can be used freely as long as you follow the [license](/LICENSE). Although the effectiveness and efficiency cannot be guaranteed as well as in the paper, you can still experience our advanced `MGML` algorithm!