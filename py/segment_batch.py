"""
This script is used to batch segment images to multiple graphs.

usage: segment_batch.py [-h] -l LIST -n NUM [-p PREFIX] [-o OUTPUT]

optional arguments:
  -h, --help            show this help message and exit
  -l LIST, --list LIST  (Required) Image list path
  -n NUM, --num NUM     (Required) Number of nodes which each image will have
                        approximately
  -p PREFIX, --prefix PREFIX
                        Sepecify the prefix of image path if the list does not
                        contains it
  -o OUTPUT, --output OUTPUT
                        Output file path
"""

import argparse

from graph import *
from segment import segment


def batch_segment(image_list_path, node_num, image_path_prefix='', output_file_path='./graph'):
    """
    Batch segment images to multiple graphs.

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
            print('Segementing image {}...'.format(count + 1))
            count += 1
            path = image_path_prefix + image_path.rstrip()
            graphs.add_multi_graph(segment(path, node_num))
    print('Writing graphs to file...')
    graphs.write(output_file_path)


def main(args):
    batch_segment(args.list, args.num, args.prefix, args.output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--list', required=True,
                        type=str, help='(Required) Image list path')
    parser.add_argument('-n', '--num', required=True, type=int,
                        help='(Required) Number of nodes which each image will have approximately')
    parser.add_argument('-p', '--prefix', default='',
                        type=str, help='Sepecify the prefix of image path if the list does not contains it')
    parser.add_argument('-o', '--output', default='./graph',
                        type=str, help='Output file path')
    args = parser.parse_args()
    main(args)
