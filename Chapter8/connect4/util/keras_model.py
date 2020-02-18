import keras.backend as k

from keras.models import load_model
from keras.engine.topology import Input
from keras.engine.training import Model
from keras.layers.convolutional import Conv2D
from keras.layers.core import Activation, Dense, Flatten
from keras.layers.merge import Add
from keras.layers.normalization import BatchNormalization
from keras.optimizers import SGD
from keras.losses import mean_squared_error
from keras.regularizers import l2

def _build_residual_block(args, x):
    cnn_filter_num = args['cnn_filter_num']
    cnn_filter_size = args['cnn_filter_size']
    l2_reg = args['l2_reg']
    
    in_x = x
    x = Conv2D(filters=cnn_filter_num, kernel_size=cnn_filter_size, padding="same",
                data_format="channels_first", kernel_regularizer=l2(l2_reg))(x)
    x = BatchNormalization(axis=1)(x)
    x = Activation("relu")(x)
    x = Conv2D(filters=cnn_filter_num, kernel_size=cnn_filter_size, padding="same",
                data_format="channels_first", kernel_regularizer=l2(l2_reg))(x)
    x = BatchNormalization(axis=1)(x)
    x = Add()([in_x, x])
    x = Activation("relu")(x)
    return x

def build_model(args):
    cnn_filter_num = args['cnn_filter_num']
    cnn_filter_size = args['cnn_filter_size']
    l2_reg = args['l2_reg']

    in_x = x = Input(args['input_dim'])

    # (batch, channels, height, width)
    x = Conv2D(filters=cnn_filter_num, kernel_size=cnn_filter_size, padding="same",
                data_format="channels_first", kernel_regularizer=l2(l2_reg))(x)
    x = BatchNormalization(axis=1)(x)
    x = Activation("relu")(x)

    for _ in range(args['res_layer_num']):
        x = _build_residual_block(args, x)

    res_out = x
    
    # for policy output
    x = Conv2D(filters=2, kernel_size=1, data_format="channels_first", kernel_regularizer=l2(l2_reg))(res_out)
    x = BatchNormalization(axis=1)(x)
    x = Activation("relu")(x)
    x = Flatten()(x)
    policy_out = Dense(args['policy_dim'], kernel_regularizer=l2(l2_reg), activation="softmax", name="policy")(x)
    
    # for value output
    x = Conv2D(filters=1, kernel_size=1, data_format="channels_first", kernel_regularizer=l2(l2_reg))(res_out)
    x = BatchNormalization(axis=1)(x)
    x = Activation("relu")(x)
    x = Flatten()(x)
    x = Dense(256, kernel_regularizer=l2(l2_reg), activation="relu")(x)
    value_out = Dense(1, kernel_regularizer=l2(l2_reg), activation="tanh", name="value")(x)
    
    return Model(in_x, [policy_out, value_out], name="model")

def build(args):
    model = build_model(args)
    model.compile(loss=['categorical_crossentropy', 'mean_squared_error'],
                    optimizer=SGD(lr=args['learning_rate'], momentum = args['momentum']),
                    #optimizer='adam',
                    loss_weights=[0.5, 0.5])
    return model

def load(filename):
    return load_model(filename)