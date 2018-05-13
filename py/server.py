import os
from http.server import BaseHTTPRequestHandler, HTTPServer

from predict import *
from segment import *


class HTTPHandler(BaseHTTPRequestHandler):

    upload_file_path = './image'
    node_num = 500
    predict_graph_path = '../result/predict_graph'
    feature_path = '../result/features/'
    instance_path = '../result/predict_instance.csv'
    model_path = '../result/MSRC_v2_model.h5'
    label_dim = 23
    label_result = ''

    def __predict_image__(self):
        # Segment original image to graph
        print('Segment...')
        graph_ = segment_region(self.upload_file_path, self.node_num)
        graphs = MultiGraph()
        graphs.add_graph(graph_)
        graphs.write(self.predict_graph_path)
        # Transform to instance
        print('Instance...')
        os.system('../GraphToInstance/GraphToInstance/GraphToInstance -g {} -l {} -i {}'.format(
            self.predict_graph_path, self.feature_path, self.instance_path))
        # Predict
        print('Predict...')
        self.label_result = predict(
            self.instance_path, self.model_path, self.label_dim)

    def do_POST(self):
        content_length = int(self.headers['content-length'])
        boundary = self.rfile.readline()
        content_disposition = self.rfile.readline()
        content_type = self.rfile.readline()
        content_length -= len(boundary) * 2 + \
            len(content_disposition) + len(content_type)
        # there may be an empty line
        line = self.rfile.readline()
        if line.strip():
            line = line
        else:
            content_length -= len(line)
            line = self.rfile.readline()
        content_length -= len(line)
        with open(self.upload_file_path, 'wb') as upload_file:
            upload_file.write(line)
            data = self.rfile.read(content_length)
            upload_file.write(data)

        self.__predict_image__()

        self.send_header('Content-type', 'text/json')
        self.end_headers()
        self.wfile.write((self.label_result + '\n').encode())

        self.send_response(200)


server = HTTPServer(('', 1696), HTTPHandler)
print('HTTP server is running on localhost:1696')
server.serve_forever()
