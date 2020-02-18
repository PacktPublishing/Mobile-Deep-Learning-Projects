import numpy as np

from .mcts import MCTS
from .compat import compat_input
from . import internal as util
from .nn import NN

def newPlayer(settings):
    settings = settings.split(',')
    t = settings[0]
    if t == 'mcts':
        nn = NN(settings[1])
        sim_count = int(settings[2]) if len(settings) >= 3 else 100
        return MctsPlayer(nn, sim_count)
    else:
        return HumanPlayer()

class MctsPlayer:
    def __init__(self, nn, sim_count, verbose=True):
        self.mcts = MCTS(nn)
        self.sim_count = sim_count
        self.verbose = verbose

    def prepare(self):
        self.mcts.resetStats()

    def getNextAction(self, state):
        return self.mcts.getMostVisitedAction(state, self.sim_count, self.verbose)

class HumanPlayer:
    def __init__(self):
        pass

    def getNextAction(self, state):
        action = state.getAction()
        available_x = []
        for i in range(len(action)):
            a, k = action[i]
            x = a %  util.BOARD_SIZE_W + 1
            y = a // util.BOARD_SIZE_W + 1
            print('{} - {},{}'.format(x, x, y))
            available_x.append(x)
        while True:
            try:
                x = int(compat_input('enter x: '))
                if x in available_x:
                    for i in range(len(action)):
                        if available_x[i] == x:
                            select = i
                            break
                    break
            except ValueError:
                pass
        a, k = action[select]
        return a

    def prepare(self):
        pass
