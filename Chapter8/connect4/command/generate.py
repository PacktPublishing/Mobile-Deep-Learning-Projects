def generate(argv):
    import argparse
    parser = argparse.ArgumentParser(description='generate game states from mcts+nn')
    parser.add_argument('-m', '--model', default='latest.h5', help='model filename')
    parser.add_argument('-n', '--number', default=1000000, type=int, help='number of generated states')
    parser.add_argument('-s', '--simulation', default=100, type=int, help='number of simulations per move')
    parser.add_argument('--hard', default=0, type=int, help='number of random moves')
    parser.add_argument('--soft', default=1000, type=int, help='number of random moves that depends on visited node count')
    parser.add_argument('--progress', action='store_true', help='show progress bar')
    parser.add_argument('--gpu', type=float, help='gpu memory fraction')
    parser.add_argument('--file', help='save to a file')
    parser.add_argument('--network', help='save to remote server')
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
    nn = NN(args.model)
    file = None

    if args.network != None:
        from util.server import submit
        def submit_to_remote_server(result):
            submit(args.network, args.model, result)
        callback = submit_to_remote_server
    elif args.file != None:
        file = open(args.file, 'a')
        def save_to_file(result):
            file.write(result)
            file.write('\n')
            file.flush()
        callback = save_to_file
    else:
        def print_to_stdout(result):
            print(result)
        callback = print_to_stdout

    from util.generator import generate
    generate(state, nn, callback, {
        'selfplay': args.number,
        'simulation': args.simulation,
        'hard_random': args.hard,
        'soft_random': args.soft,
        'progress': args.progress,
    })

    if file != None:
        file.close()
