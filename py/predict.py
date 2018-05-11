import argparse
import json
import os

import numpy as np
import pandas as pd
from keras.models import Sequential

import classifier


def __avg__(list_):
    """Return average of all elements in the list."""
    return sum(list_) / len(list_)


def __evaluate__(label_file_path, pos_labels):
    labels_csv = pd.read_csv(filepath_or_buffer=label_file_path, header=None)
    true_labels = labels_csv.values

    precisions = []
    recalls = []
    accuracies = []
    for i, labels in enumerate(true_labels):
        true_pos = 0
        true_neg = 0
        for j, label in enumerate(labels):
            if label > 0:
                if j in pos_labels[i]:
                    true_pos += 1
            else:
                if j not in pos_labels[i]:
                    true_neg += 1

        false_pos = 0
        for pos_index in pos_labels[i]:
            if labels[pos_index] == 0:
                false_pos += 1

        false_neg = 0
        for j in range(len(true_labels[0])):
            if j not in pos_labels[i] and labels[j] == 1:
                false_neg += 1

        precisions.append(true_pos / (true_pos + false_pos)
                          if true_pos + false_pos != 0 else 0)
        recalls.append(true_pos / (true_pos + false_neg)
                       if true_pos + false_neg != 0 else 0)
        accuracies.append((true_pos + true_neg) / (true_pos + true_neg + false_pos +
                                                   false_neg) if true_pos + true_neg + false_pos + false_neg != 0 else 0)

    print('Precision: ', __avg__(precisions))
    print('Recall: ', __avg__(recalls))
    print('Accuracy: ', __avg__(accuracies))


def main(args):
    instance_file_path = args.instance
    save_model_path = args.model
    output_dim = args.dimension
    label_file_path = args.label
    batch_size = 128

    # Load data
    instances = pd.read_csv(filepath_or_buffer=instance_file_path, header=None)
    predict_instances = instances.values

    # Load saved model and predict
    model = classifier.build_model(len(instances.values[0]), output_dim)
    model.load_weights(save_model_path)
    predictions = model.predict(predict_instances, batch_size=batch_size)

    # Find positive labels
    pos_labels = []
    for prediction in predictions:
        avg_poss = __avg__(prediction)
        pos_label = [i for i, result in enumerate(
            prediction) if result >= avg_poss]
        pos_labels.append(pos_label)

    if label_file_path:
        __evaluate__(label_file_path, pos_labels)

    return json.dumps(pos_labels)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--instance', required=True,
                        type=str, help='(Required) Instance file path')
    parser.add_argument('-m', '--model', required=True,
                        type=str, help='(Required) Saved model path')
    parser.add_argument('-d', '--dimension', required=True,
                        type=int, help='(Required) Output (label) dimension')
    parser.add_argument('-l', '--label', default=None,
                        type=str, help='Label file path. If not none, the prediction will be evaluated')
    args = parser.parse_args()
    main(args)
