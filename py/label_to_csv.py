"""
This script is used to transform label file to csv format.

usage: label_to_csv.py [-h] -l LABEL [-o OUTPUT]

optional arguments:
  -h, --help            show this help message and exit
  -l LABEL, --label LABEL
                        (Required) Label file path
  -o OUTPUT, --output OUTPUT
                        Output file path
"""

import argparse

from model.label import *


def label_to_csv(label_file_path, output_file_path=None):
    """
    Transform label to .csv file.

    Parameters
    ---
    label_file_path: `str`

    output_file_path: `str`
    """
    if not output_file_path:
        output_file_path = label_file_path + '.csv'
    labels = MultiLabel()
    labels.read(label_file_path)
    labels.write_csv(output_file_path)


def main(args):
    label_to_csv(args.label, args.output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--label', required=True,
                        type=str, help='(Required) Label file path')
    parser.add_argument('-o', '--output', default=None,
                        type=str, help='Output file path')
    args = parser.parse_args()
    main(args)
