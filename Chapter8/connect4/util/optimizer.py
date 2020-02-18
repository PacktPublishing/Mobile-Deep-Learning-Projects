from util import game
from util.player import MinimaxPlayer

def optimize(state, history, player, verbose=False):
    # replay history
    for action in history:
        acs = state.getAction()
        select_action = None
        for encoded_action, k in acs:
            decoded_action = state.actionToString(encoded_action)
            if action == decoded_action:
                select_action = encoded_action
                break
        state = state.getNextState(select_action)

    # play by minimax
    new_history = []

    if verbose: print(state)
    while state.getWinner() == None:
        encoded_action = player.getNextAction(state)
        decoded_action = state.actionToString(encoded_action)
        new_history.append(decoded_action)
        state = state.getNextState(encoded_action)
        if verbose: print(state)

    winner = state.getWinner()
    win_str = 'x' if winner > 0 else 'o' if winner < 0 else '='

    return win_str + ' ' + ' '.join(history + new_history)
