from flask import Flask, request, jsonify, send_file
import os
import time

from matplotlib.image import imsave

from model.srgan import generator

from model import resolve_single
from utils import load_image

weights_dir = 'weights/srgan'
weights_file = lambda filename: os.path.join(weights_dir, filename)

gan_generator = generator()
gan_generator.load_weights(weights_file('gan_generator.h5'))
    
app = Flask(__name__)

@app.route('/generate', methods=["GET", "POST"])
def generate():

    global gan_generator

    imgData = request.get_data()

    with open("input.png", 'wb') as output:
        output.write(imgData)

    lr = load_image("input.png")
    gan_sr = resolve_single(gan_generator, lr)

    epoch_time = int(time.time())

    outputfile = 'output_%s.png' % (epoch_time)

    imsave(outputfile, gan_sr.numpy())

    response = {'result': outputfile}

    return jsonify(response)


@app.route('/download/<fname>', methods=['GET'])
def download(fname):
    return send_file(fname, as_attachment=True)

app.run(host="0.0.0.0", port="8080")