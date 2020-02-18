def train(argv):
    import argparse
    parser = argparse.ArgumentParser(description='train nn from history file')
    parser.add_argument('history', help='history file')
    parser.add_argument('input', help='input model file name')
    parser.add_argument('output', help='output model file name')
    parser.add_argument('--progress', action='store_true', help='show progress bar')
    parser.add_argument('--epoch', default=1, type=int, help='training epochs')
    parser.add_argument('--batch', default=256, type=int, help='batch size')
    parser.add_argument('--block', default=100000, type=int, help='block size')
    parser.add_argument('--gpu', type=float, help='gpu memory fraction')
    args = parser.parse_args(argv)

    # set gpu memory
    if args.gpu != None:
        import tensorflow as tf
        from keras.backend.tensorflow_backend import set_session

        config = tf.ConfigProto()
        config.gpu_options.per_process_gpu_memory_fraction = args.gpu
        set_session(tf.Session(config=config))

    from util.nn import NN
    from util.state import State

    state = State()
    nn = NN(args.input)

    for epoch in range(args.epoch):
        from util.trainer import train
        train(state, nn, args.history, {
            'batch': args.batch,
            'block': args.block,
            'progress': args.progress,
        })
        nn.save(args.output)
