"""
This script is used to batch segment images to graphs.
There are two kinds of segments: segment one image to multi-graph or one graph.
If you choose the multi-graph one, you need to specify the label file to transform it to support multi-graph.

usage: segment_batch.py [-h] -l LIST -n NUM [-p PREFIX] [-g GRAPH_OUTPUT]
                        [-a LABEL] [-o LABEL_OUTPUT]

optional arguments:
  -h, --help            show this help message and exit
  -l LIST, --list LIST  (Required) Image list path
  -n NUM, --num NUM     (Required) Number of nodes which each image will have
                        approximately
  -p PREFIX, --prefix PREFIX
                        Specify the prefix of image path if the list does not
                        contains it
  -g GRAPH_OUTPUT, --graph_output GRAPH_OUTPUT
                        Output graph file path
  -a LABEL, --label LABEL
                        Label file path
  -o LABEL_OUTPUT, --label_output LABEL_OUTPUT
                        Output label file path
"""

import argparse

from model.graph import *
from model.label import *
from segment import *


def batch_segment(image_list_path, node_num, image_path_prefix='', output_file_path='graph', label_file_path=None):
    """
    Batch segment images to multiple graphs.

    Parameters
    ---
    image_list_path: `str`

    node_num: `int`

    image_path_prefix: `str`

    output_file_path: `str`

    label_file_path: `str`, if not none, use multi-graph segment

    Returns
    ---
    graph_nums: `list`, number of graphs that each image has
    """
    graphs = MultiGraph()
    graph_nums = []
    with open(image_list_path) as images_list:
        count = 0
        for image_path in images_list:
            print('Segmenting image {}...'.format(count + 1))
            count += 1
            path = image_path_prefix + image_path.rstrip()
            # If not none, use multi-graph segment.
            if label_file_path:
                image_graphs = segment(path, node_num)
                graphs.add_multi_graph(image_graphs)
                graph_nums.append(image_graphs.get_num())
            else:
                image_graph = segment_region(path, node_num)
                graphs.add_graph(image_graph)
    print('Writing graphs to file...')
    graphs.write(output_file_path)
    return graph_nums


def transform_label(label_file_path, graph_nums, output_file_path='graph_label'):
    """
    Transform label file to support multi-graph.
    """
    print('Transforming labels...')
    multi_label = MultiLabel()
    multi_label.read(label_file_path)
    new_labels = MultiLabel()
    for i, label in enumerate(multi_label.labels):
        count = graph_nums[i]  # times that this label should be duplicated
        for j in range(count):
            new_labels.add_label(label)
    new_labels.write(output_file_path)


def main(args):
    graph_nums = batch_segment(
        args.list, args.num, args.prefix, args.graph_output, args.label)
    if args.label:
        transform_label(args.label, graph_nums, args.label_output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--list', required=True,
                        type=str, help='(Required) Image list path')
    parser.add_argument('-n', '--num', required=True, type=int,
                        help='(Required) Number of nodes which each image will have approximately')
    parser.add_argument('-p', '--prefix', default='',
                        type=str, help='Specify the prefix of image path if the list does not contains it')
    parser.add_argument('-g', '--graph_output', default='graph',
                        type=str, help='Output graph file path')
    parser.add_argument('-a', '--label', default=None,
                        type=str, help='Label file path')
    parser.add_argument('-o', '--label_output', default='graph_label',
                        type=str, help='Output label file path')
    args = parser.parse_args()
    main(args)
