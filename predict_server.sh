#!/bin/bash

image_path='./MSRC_v2/Images/20_3_s.bmp'
segment_node_num=500
graph_path='./result/predict_graph'
instance_path='./result/predict_instance.csv'

# Segment original image to graph
python3 ./py/segment.py -i ${image_path} -n ${segment_node_num} -o ${graph_path}

# Transform to instance
./GraphToInstance/GraphToInstance/GraphToInstance -g ${graph_path} -s ./result/MSRC_v2_subgraph -i ${instance_path}
