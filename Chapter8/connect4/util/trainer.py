def train(state, nn, filename, args = {}):
    batch = args['batch'] if 'batch' in args and type(args['batch']) == int else 32
    block = args['block'] if 'block' in args and type(args['block']) == int else 100000
    progress = 'progress' in args and type(args['progress']) == bool and args['progress']

    X = []
    policy = []
    value = []

    def newPbar():
        from tqdm import tqdm
        return tqdm(total=block, ncols=50)

    if progress:
        pbar = newPbar()
    with open(filename) as f:
        for line in f:
            history = line.strip('\n\r').split(' ')[1:]
            x, p, v = _replay(state, history)
            X += x
            policy += p
            value += v
            if progress:
                pbar.update(len(x))

            if len(X) > block:
                if progress: pbar.close()
                nn.fit(X, policy, value, batch_size = batch, epochs = 1)
                if progress: pbar = newPbar()
                X = []
                policy = []
                value = []

    if progress:
        pbar.close()
    if len(X) > 0:
        nn.fit(X, policy, value, batch_size = batch, epochs = 1)

def _replay(state, history):
    X = []
    policy = []
    value = []
    for action in history:
        acs = state.getAction()
        select_action = None
        select_key = None
        for encoded_action, key in acs:
            decoded_action = state.actionToString(encoded_action)
            if action == decoded_action:
                select_action = encoded_action
                select_key = key
                break

        x = state.getNnInput()
        p = [1 if i == select_key else 0 for i in range(state.getKeySize())]
        
        X.append(x)
        policy.append(p)
        value.append(state.getCurrentPlayer())

        state = state.getNextState(select_action)

    winner = state.getWinner()
    value = [v * winner for v in value]

    return X, policy, value
