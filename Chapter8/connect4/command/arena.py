from util.state import State

def arena(argv):
    import argparse
    parser = argparse.ArgumentParser(description='fighting between two players')
    parser.add_argument('p1', nargs='?', default='human', help='player 1 settings')
    parser.add_argument('p2', nargs='?', default='minimax,6', help='player 2 settings')
    parser.add_argument('-n', '--number', default=1, type=int, help='number of fighting round')
    parser.add_argument('--history', help='game state from history')
    parser.add_argument('--first', type=int, help='use first N steps from history')
    parser.add_argument('--truncate', type=int, help='truncate last N steps from history')
    args = parser.parse_args(argv)

    from util import player
    p1 = player.newPlayer(args.p1)
    p2 = player.newPlayer(args.p2)
    p1.prepare()
    p2.prepare()

    from util.arena import Arena

    state = State()

    if args.history != None:
        history = None
        if args.first != None:
            history = args.history.split(' ')[1:(args.first + 1)]
        elif args.truncate != None:
            history = args.history.split(' ')[1:-args.truncate]
        if history != None:
            for action in history:
                acs = state.getAction()
                select_action = None
                for encoded_action, k in acs:
                    decoded_action = state.actionToString(encoded_action)
                    if action == decoded_action:
                        select_action = encoded_action
                        break
                assert(select_action != None)
                state = state.getNextState(select_action)

    arena = Arena()
    arena.fight(state, p1, p2, args.number)
