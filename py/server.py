import os
from http.server import BaseHTTPRequestHandler, HTTPServer

from predict import *
from segment import *


class HTTPHandler(BaseHTTPRequestHandler):

    label_result = ''

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
        with open('./image', 'wb') as upload_file:
            upload_file.write(line)
            data = self.rfile.read(content_length)
            upload_file.write(data)

        # Segment original image to graph
        segment('./image', 500)
        # Transform to instance
        os.system('../GraphToInstance/GraphToInstance/GraphToInstance - g image - l ../result/features/ -i ../result/predict_instance.csv')
        # Predict
        self.label_result = predict(
            '../result/predict_instance.csv', '../result/MSRC_v2_model.h5', 23)

        self.send_response(200)

    def do_GET(self):
        self.send_header('Content-type', 'text/json')
        self.end_headers()
        self.wfile.write(label_result.encode())
        self.send_response(200)


server = HTTPServer(('', 1696), HTTPHandler)
print('HTTP server is running on localhost:1696')
server.serve_forever()
