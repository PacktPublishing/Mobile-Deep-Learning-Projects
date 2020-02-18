import numpy as np

from util.mcts import MCTS

def generate(state, nn, callback, args):
    generator = Generator()
    generator.generate(state, nn, callback, args)

class Generator:
    def __init__(self):
        pass

    def generate(self, state, nn, cb, args):
        self.mcts = MCTS(nn)

        iterator = range(args['selfplay'])
        if args['progress']:
            from tqdm import tqdm
            iterator = tqdm(iterator, ncols = 50)

        # self play
        for pi in iterator:
            result = self._selfplay(state, args)
            if cb != None:
                cb(result)

    def _selfplay(self, state, args):
        self.mcts.resetStats()
        turn = 0
        hard_random_turn = args['hard_random'] if 'hard_random' in args else 0
        soft_random_turn = (args['soft_random'] if 'soft_random' in args else 30) + hard_random_turn
        history = []
        while state.getWinner() == None:
            if turn < hard_random_turn:
                # random action
                action_list = state.getAction()
                index = np.random.choice(len(action_list))
                (action, key) = action_list[index]
            else:
                action_list = self.mcts.getActionInfo(state, args['simulation'])
                if turn < soft_random_turn:
                    # random action by visited count
                    visited = [1.0 * a.visited for a in action_list]
                    sum_visited = sum(visited)
                    assert(sum_visited > 0)
                    p = [v / sum_visited for v in visited]
                    index = np.random.choice(len(action_list), p = p)
                else:
                    # select most visited count
                    index = np.argmax([a.visited for a in action_list])
                choice = action_list[index]
                key = choice.key
                action = choice.action

            # collect history
            history.append(state.actionToString(action))

            # next state
            state = state.getNextState(action)
            turn += 1

        winner = state.getWinner()
        win_str = 'x' if winner > 0 else 'o' if winner < 0 else '='

        return win_str + ' ' + ' '.join(history)
