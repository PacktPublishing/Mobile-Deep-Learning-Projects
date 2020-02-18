import numpy as np

BOARD_SIZE_W = 7
BOARD_SIZE_H = 6
KEY_SIZE = BOARD_SIZE_W * BOARD_SIZE_H

LIST4 = []
LIST4 += [[(y, x), (y + 1, x + 1), (y + 2, x + 2), (y + 3, x + 3)] for y in range(BOARD_SIZE_H - 3) for x in range(BOARD_SIZE_W - 3)]
LIST4 += [[(y, x + 3), (y + 1, x + 2), (y + 2, x + 1), (y + 3, x)] for y in range(BOARD_SIZE_H - 3) for x in range(BOARD_SIZE_W - 3)]
LIST4 += [[(y, x), (y, x + 1), (y, x + 2), (y, x + 3)] for y in range(BOARD_SIZE_H) for x in range(BOARD_SIZE_W - 3)]
NO_HORIZONTAL = len(LIST4)
LIST4 += [[(y, x), (y + 1, x), (y + 2, x), (y + 3, x)] for y in range(BOARD_SIZE_H - 3) for x in range(BOARD_SIZE_W)]

DEAD_PATTERN = {}
for y in range(BOARD_SIZE_H - 1):
    for x in range(BOARD_SIZE_W):
        k1 = (y, x)
        k2 = (y + 1, x)
        dp = []
        for p1 in range(NO_HORIZONTAL):
            if k1 in LIST4[p1]:
                for p2 in range(NO_HORIZONTAL):
                    if k2 in LIST4[p2]:
                        dp.append((p1, p2))

        for p1 in range(NO_HORIZONTAL, len(LIST4)):
            if LIST4[p1][2] == k1 and LIST4[p1][3] == k2:
                for p2 in range(NO_HORIZONTAL):
                    if k1 in LIST4[p2] or k2 in LIST4[p2]:
                        dp.append((p1, p2))
        DEAD_PATTERN[k1] = dp


def get_start_board():
    return np.zeros((BOARD_SIZE_H, BOARD_SIZE_W), dtype=np.int8)

def clone_board(board):
    return np.copy(board)

def get_action(board):
    result = []
    for x in range(BOARD_SIZE_W):
        for ry in range(BOARD_SIZE_H):
            y = BOARD_SIZE_H - ry - 1
            if board[y][x] == 0:
                # (action, key)
                action = y * BOARD_SIZE_W + x
                result.append((action, action))
                break
    return result

def action_to_string(action):
    y = action // BOARD_SIZE_W + 1
    x = action %  BOARD_SIZE_W + 1
    return str(x) + str(y)

def place_at(board, pos, player):
    y = pos // BOARD_SIZE_W
    x = pos %  BOARD_SIZE_W
    board[y][x] = player

def get_winner(board):
    for c in LIST4:
        v0 = board[c[0][0]][c[0][1]]
        if v0 == 0: continue
        v1 = board[c[1][0]][c[1][1]]
        if v0 != v1: continue
        v2 = board[c[2][0]][c[2][1]]
        if v0 != v2: continue
        v3 = board[c[3][0]][c[3][1]]
        if v0 != v3: continue
        return v0
    for y in range(BOARD_SIZE_H):
        for x in range(BOARD_SIZE_W):
            if board[y][x] == 0:
                return None
    return 0

HEURISTIC_SCORE = [0, 1, 3, 20, 1000]

def get_heuristic_score(board):
    score = 0
    got3 = [0] * len(LIST4)
    for i in range(len(LIST4)):
        c = LIST4[i]
        v = _count_xo(board[c[0][0]][c[0][1]], board[c[1][0]][c[1][1]], board[c[2][0]][c[2][1]], board[c[3][0]][c[3][1]])
        if v > 0:
            score += HEURISTIC_SCORE[v]
            if i < NO_HORIZONTAL:
                if v >= 3:
                    got3[i] = +1
            elif v >= 2:
                got3[i] = +1
        elif v < 0:
            v = -v
            score -= HEURISTIC_SCORE[v]
            if i < NO_HORIZONTAL:
                if v >= 3:
                    got3[i] = -1
            elif v >= 2:
                got3[i] = -1
    for y in range(BOARD_SIZE_H - 1):
        for x in range(BOARD_SIZE_W):
            if board[y][x] != 0 or board[y + 1][x] != 0: continue
            k1 = (y, x)
            k2 = (y + 1, x)
            for dp in DEAD_PATTERN[k1]:
                v = got3[dp[0]] + got3[dp[1]]
                if v == +2:
                    score += 2000
                elif v == -2:
                    score -= 2000
    return score

def _count_xo(v0, v1, v2, v3):
    if v0 >= 0 and v1 >= 0 and v2 >= 0 and v3 >= 0:
        return v0 + v1 + v2 + v3
    if v0 <= 0 and v1 <= 0 and v2 <= 0 and v3 <= 0:
        return v0 + v1 + v2 + v3
    return 0

def to_string(board):
    header = '  |' + ''.join(['{} '.format(x + 1) for x in range(BOARD_SIZE_W)]) + '\n' + '--+' + ('-' * BOARD_SIZE_W * 2) + '\n'
    return header + '\n'.join(['{:2}|'.format(y + 1) + _to_line(board, y, ' ') for y in range(BOARD_SIZE_H)])

def to_oneline(board):
    return ''.join([_to_line(board, y) for y in range(BOARD_SIZE_H)])

def _to_line(board, y, sep = ''):
    b = board[y]
    return sep.join([_to_char(b[x]) for x in range(BOARD_SIZE_W)])

def _to_char(v):
    if v > 0: return 'x'
    if v < 0: return 'o'
    return '.'
