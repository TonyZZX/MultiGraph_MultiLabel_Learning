# Entropy-Based Sub-graph Mining

It combines the idea of information entropy with [gSpan][gSpan.Java] to mine the informative subgraphs instead of just mining the frequent subgraphs, which enables selecting the more accurate features for the classification. For more details, please see our publication [here][Paper].

## Documentation

### Graph file format

Below is an example of the format of a text file containing a set of graphs. Each line denodes a vertex (v) or edge (e) with a given label (end of line).

```
t # 0
v 0 2
v 1 2
v 2 2
v 3 3
v 4 2
e 0 1 2
e 0 2 2
e 2 3 3
e 2 4 2
t # 1
v 0 2
v 1 2
v 2 6
e 0 1 2
e 0 2 2
```

### Label file format

Below is an example of the format of a text file containing a set of labels. Each line denodes a label (a) for a graph with the same number (t).

```
t # 0
l 0 1
l 1 0
t # 1
l 0 1
l 1 1
```

### How to run

This program supports 2 ways to run.

1. From the command line.

```
usage: ESM
 -a,--max-node <arg>    Maximum number of nodes for each sub-graph
 -d,--data <arg>        (Required) File path of data set
 -g,--max-graph <arg>   Maximum number of sub-graphs that will be returned
 -h,--help              Help
 -i,--min-node <arg>    Minimum number of nodes for each sub-graph
 -l,--label <arg>       (Required) File path of label
 -r,--result <arg>      File path of result
 -s,--sup <arg>         (Required) Minimum support
 ```

2. Directly run it from an IDE.

In this mode, you can only specify the file path of input data set and the minimum support.

## Reference

- [gSpan.Java][gSpan.Java]

Java implementation of frequent sub-graph mining algorithm gSpan

- [Paper][Paper]

Zhu, Z.; Zhao, Y.	Multi-Graph Multi-Label Learning Based on Entropy. Entropy 2018, 20, 245.

[gSpan.Java]: https://github.com/TonyZZX/gSpan.Java
[Paper]: ../../../entropy-20-00245.pdf
