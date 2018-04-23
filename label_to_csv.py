import argparse


def label_to_csv(label_file_path, output_file_path=None):
    """
    Transform label to .csv file.

    type label_file_path: str

    type output_file_path: str
    """
    if not output_file_path:
        output_file_path = label_file_path + '.csv'
    output_str = ''
    with open(label_file_path) as label_file:
        # Omit the first line in label file. (t # 0)
        label_file.readline()
        for line in label_file:
            split_str = line.rstrip().split(' ')
            if split_str[0] == 't':
                output_str += '\n'
            elif split_str[0] == 'l' and len(split_str) >= 3:
                if len(output_str) > 0 and output_str[-1] != '\n':
                    output_str += ','
                # Convert labels to 0 or 1.
                label = int(split_str[2])
                if label > 0:
                    output_str += '1'
                else:
                    output_str += '0'
    with open(output_file_path, 'w') as output_file:
        output_file.write(output_str)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-l', '--label', required=True,
                        type=str, help='(Required) Label file path')
    parser.add_argument('-o', '--output', default=None,
                        type=str, help='Output file path')
    args = parser.parse_args()
    label_to_csv(args.label, args.output)


if __name__ == '__main__':
    main()
