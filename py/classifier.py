"""
Build a classifier model with Keras.

usage: classifier.py [-h] -i INSTANCE -l LABEL [-s STEP] [-p PROCESS]
                     [-m SAVE_MODEL]

optional arguments:
  -h, --help            show this help message and exit
  -i INSTANCE, --instance INSTANCE
                        (Required) Instance file path
  -l LABEL, --label LABEL
                        (Required) Label file path
  -s STEP, --step STEP  Training step
  -p PROCESS, --process PROCESS
                        If show process during training
  -m SAVE_MODEL, --save_model SAVE_MODEL
                        Path of outputing trained model, if not none
"""

import argparse
import os

import pandas as pd
from keras.layers import Dense, Dropout
from keras.models import Sequential
from keras.optimizers import SGD


def build_model(input_dim, output_dim):
    """
    Build a model

    Multilayer Perceptron (MLP) for multi-class softmax classification

    Parameters
    ---
    input_dim: `int`, dimension of input nodes

    output_dim: `int`, dimension of output nodes

    Returns
    ---
    model: `Sequential`
    """
    model = Sequential()
    model.add(Dense(64, activation='relu', input_dim=input_dim))
    model.add(Dropout(0.5))
    model.add(Dense(64, activation='relu'))
    model.add(Dropout(0.5))
    model.add(Dense(output_dim, activation='softmax'))
    model.compile(loss='categorical_crossentropy', optimizer=SGD(
        lr=0.01, decay=1e-6, momentum=0.9, nesterov=True), metrics=['accuracy'])
    return model


def main(args):
    instance_file_path = args.instance
    label_file_path = args.label
    step = args.step
    show_process = args.process
    save_model_path = args.save_model
    batch_size = 128

    # Load data
    instances = pd.read_csv(filepath_or_buffer=instance_file_path, header=None)
    labels = pd.read_csv(filepath_or_buffer=label_file_path, header=None)
    train_instances = instances.values
    train_labels = labels.values

    # Build model and train it
    model = build_model(len(instances.values[0]), len(labels.values[0]))
    model.fit(train_instances, train_labels, epochs=step,
              batch_size=batch_size, verbose=show_process)

    # Save trained model
    if save_model_path:
        model.save(save_model_path)

    # # Effectiveness evaluation
    # score = model.evaluate(train_instances, train_labels,
    #                        batch_size=batch_size)
    # print('Test loss: ', score[0])
    # print('Test accuracy: ', score[1])


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--instance', required=True,
                        type=str, help='(Required) Instance file path')
    parser.add_argument('-l', '--label', required=True,
                        type=str, help='(Required) Label file path')
    parser.add_argument('-s', '--step', default=200,
                        type=int, help='Training step')
    parser.add_argument('-p', '--process', default=1,
                        type=int, help='If show process during training')
    parser.add_argument('-m', '--save_model', default=None,
                        type=str, help='Path of outputing trained model, if not none')
    args = parser.parse_args()
    main(args)
