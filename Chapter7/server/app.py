import mido
from mido import MidiFile, MidiTrack, Message
from tensorflow.keras.models import load_model
from sklearn.preprocessing import MinMaxScaler
import numpy as np
import random
import time
from flask import send_file
import os

from flask import Flask, jsonify

app = Flask(__name__)


@app.route('/generate', methods=['GET', 'POST'])
def generate():

    songnum = random.randint(0, 3)

    notes = []

    for msg in MidiFile('Samples/%s.mid' % (songnum)):
        try:
            if not msg.is_meta and msg.channel in [0, 1, 2, 3] and msg.type == 'note_on':
                data = msg.bytes()
                notes.append(data[1])
        except:
            pass

    scaler = MinMaxScaler(feature_range=(0, 1))
    scaler.fit(np.array(notes).reshape(-1, 1))
    notes = list(scaler.transform(np.array(notes).reshape(-1, 1)))

    notes = [list(note) for note in notes]

    X = []
    y = []

    n_prev = 20
    for i in range(len(notes) - n_prev):
        X.append(notes[i:i + n_prev])
        y.append(notes[i + n_prev])

    model = load_model("model.h5")

    xlen = len(X)

    start = random.randint(0, 100)

    stop = start + 200

    prediction = model.predict(np.array(X[start:stop]))
    prediction = np.squeeze(prediction)
    prediction = np.squeeze(scaler.inverse_transform(prediction.reshape(-1, 1)))
    prediction = [int(i) for i in prediction]

    mid = MidiFile()
    track = MidiTrack()
    t = 0
    for note in prediction:
        vol = random.randint(50, 70)
        note = np.asarray([147, note, vol])
        bytes = note.astype(int)
        msg = Message.from_bytes(bytes[0:3])
        t += 1
        msg.time = t
        track.append(msg)
    mid.tracks.append(track)
    epoch_time = int(time.time())

    outputfile = 'output_%s.mid' % (epoch_time)
    mid.save("Output/" + outputfile)

    response = {'result': outputfile}

    return jsonify(response)

@app.route('/download/<fname>', methods=['GET'])
def download(fname):
    return send_file("Output/"+fname, mimetype="audio/midi", as_attachment=True)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)
