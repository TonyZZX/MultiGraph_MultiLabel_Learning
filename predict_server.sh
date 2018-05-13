#!/bin/bash

image_path='./MSRC_v2/Images/1_1_s.bmp'
graph_path='./result/predict_graph'
instance_path='./result/predict_instance.csv'

# Segment original image to graph
python3 ./py/segment.py -i ${image_path} -n 500 -o ${graph_path}

# Transform to instance
./GraphToInstance/GraphToInstance/GraphToInstance -g ${graph_path} -l ./result/features/ -i ${instance_path}
