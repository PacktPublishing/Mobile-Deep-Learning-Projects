from util.state import State

def arena(argv):
    import argparse
    parser = argparse.ArgumentParser(description='fighting between two players')
    parser.add_argument('p1', nargs='?', default='human', help='player 1 settings')
    parser.add_argument('p2', nargs='?', default='minimax,6', help='player 2 settings')
    parser.add_argument('-n', '--number', default=1, type=int, help='number of fighting round')

    args = parser.parse_args(argv)

    from util import player
    p1 = player.newPlayer(args.p1)
    p2 = player.newPlayer(args.p2)
    p1.prepare()
    p2.prepare()

    from util.arena import Arena

    state = State()

    arena = Arena()
    arena.fight(state, p1, p2, args.number)
