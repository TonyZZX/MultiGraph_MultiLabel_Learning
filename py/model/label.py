import copy


class Label(object):
    """A group of marks (labels) for one image"""

    def __init__(self):
        self.marks = []

    def clear(self):
        """Remove all marks."""
        self.marks.clear()

    def is_empty(self):
        return len(self.marks) == 0

    def add(self, mark):
        self.marks.append(mark)


class MultiLabel(object):

    def __init__(self):
        self.labels = []

    def add_label(self, label):
        self.labels.append(label)

    def read(self, label_file_path):
        with open(label_file_path) as label_file:
            label = Label()
            for line in label_file:
                split_str = line.rstrip().split(' ')
                if split_str[0] == 't':
                    if not label.is_empty():
                        self.add_label(copy.deepcopy(label))
                    label.clear()
                elif split_str[0] == 'l' and len(split_str) >= 3:
                    label.add(int(split_str[2]))
            # Add the last label
            if not label.is_empty():
                self.add_label(copy.deepcopy(label))

    def write(self, output_file_path):
        with open(output_file_path, 'w') as output_file:
            output_str = ''
            for i, label in enumerate(self.labels):
                output_str += 't # {}\n'.format(i)
                for j, mark in enumerate(label.marks):
                    output_str += 'l {} {}\n'.format(j, mark)
            output_file.write(output_str)

    def write_csv(self, output_file_path):
        with open(output_file_path, 'w') as output_file:
            output_str = ''
            for label in self.labels:
                for i, mark in enumerate(label.marks):
                    # Convert labels to 0 or 1.
                    if mark > 0:
                        output_str += '1'
                    else:
                        output_str += '0'
                    if i == len(label.marks) - 1:
                        output_str += '\n'
                    else:
                        output_str += ','
            output_file.write(output_str)
