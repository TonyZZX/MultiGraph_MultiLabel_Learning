"""
This script is used to batch segment images to graphs.

usage: segment_no_region_batch.py [-h] -l LIST -n NUM [-p PREFIX]
                                  [-g GRAPH_OUTPUT]

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
"""

import argparse

from model.graph import *
from segment_no_region import segment_no_region


def batch_segment(image_list_path, node_num, image_path_prefix='', output_file_path='graph'):
    """
    Batch segment images to graphs.

    Parameters
    ---
    image_list_path: `str`

    node_num: `int`

    image_path_prefix: `str`

    output_file_path: `str`
    """
    graphs = MultiGraph()
    with open(image_list_path) as images_list:
        count = 0
        for image_path in images_list:
            print('Segmenting image {}...'.format(count + 1))
            count += 1
            path = image_path_prefix + image_path.rstrip()
            image_graph = segment_no_region(path, node_num)
            graphs.add_graph(image_graph)
    print('Writing graphs to file...')
    graphs.write(output_file_path)


def main(args):
    batch_segment(args.list, args.num, args.prefix, args.graph_output)


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
    args = parser.parse_args()
    main(args)
