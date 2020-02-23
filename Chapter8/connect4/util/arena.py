class Arena:
    def __init__(self):
        pass

    def fight(self, state, p1, p2, count):
        stats = [0, 0, 0]
        for i in range(count):
            print('==== EPS #{} ===='.format(i + 1))
            winner = self._fight(state, p1, p2)
            stats[winner + 1] += 1
            print('stats', stats[::-1])
            winner = self._fight(state, p2, p1)
            stats[winner * -1 + 1] += 1
            print('stats', stats[::-1])

    def _fight(self, state, p1, p2):
        while state.getWinner() == None:
            print(state)
            if state.getCurrentPlayer() > 0:
                action = p1.getNextAction(state)
            else:
                action = p2.getNextAction(state)
            state = state.getNextState(action)
        print(state)
        return state.getWinner()
