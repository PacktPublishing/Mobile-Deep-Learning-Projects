import numpy as np

from util.keras_model import build, load
from . import internal as util

class NN:
    def __init__(self, filename):
        self.model = load(filename)
        pass

    def save(self, filename):
        self.model.save(filename)

    def predict(self, x):
        p, v = self.model.predict(np.asarray([x]))
        return p[0], v[0][0]

    def bulkPredict(self, x):
        p, v = self.model.predict(np.asarray(x))
        return p, v

    def fit(self, x, policy, value, batch_size = 256, epochs = 1):
        x = np.asarray(x)
        policy = np.asarray(policy)
        value = np.asarray(value).reshape((len(value), 1))
        self.model.fit(x, [policy, value], batch_size = batch_size, epochs = epochs)

def init(filename):
    model = build({
        'input_dim': (2, util.BOARD_SIZE_H, util.BOARD_SIZE_W),
		'policy_dim': util.KEY_SIZE,
		'res_layer_num': 5,
		'cnn_filter_num': 64,
		'cnn_filter_size': 5,
		'l2_reg': 1e-4,
		'learning_rate': 0.003,
		'momentum': 0.9,
    })
    model.save(filename)
