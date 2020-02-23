import math
import numpy as np

CPUCT = 1.0

class NodeInfo:
    def __init__(self, state, action, raw_policy, value):
        self.state = state
        self.action = action
        self.policy = [raw_policy[k] for a, k in action]
        self.value = value
        self.children_state = [None for i in range(len(action))]

    def __str__(self):
        return self._tostring()

    def __repr__(self):
        return self._tostring()

    def _tostring(self):
        return '{}|{}'.format(self.policy, self.value)

class NodeStat:
    def __init__(self, action_len):
        self.total_visited = 0
        self.children_score = [0. for i in range(action_len)]
        self.children_visited = [0 for i in range(action_len)]

    def __str__(self):
        return self._tostring()

    def __repr__(self):
        return self._tostring()

    def _tostring(self):
        return '{}|{}|{}'.format(self.total_visited, self.children_score, self.children_visited)


class Result:
    def __init__(self, action, key, Q, U, visited, policy):
        self.action = action
        self.key = key
        self.Q = Q
        self.U = U
        self.visited = visited
        self.policy = policy

class MCTS:
    def __init__(self, nn):
        self.nn = nn
        self.info_map = {}
        self.stat_map = {}

    def resetStats(self):
        if len(self.info_map) > 20000: self.info_map = {}
        self.stat_map = {}

    def getMostVisitedAction(self, state, sim_count, verbose = False):
        info = self.getActionInfo(state, sim_count)
        if verbose:
            for a in info:
                print('{:4} {:+.4f} {:+.4f} {:4} {:+.4f} {}'.format(a.key, a.Q, a.U, a.visited, a.policy, state.actionToString(a.action)))
        index = np.argmax([i.visited for i in info])
        return info[index].action

    def getActionInfo(self, state, sim_count):
        uid = state.getRepresentativeString()
        info = self._getinfo(state, uid)
        if not uid in self.stat_map:
            stat = self.stat_map[uid] = NodeStat(len(info.action))
        else:
            stat = self.stat_map[uid]
        for i in range(sim_count):
            self._simulation(state)

        return [self._summary(info, stat, i) for i in range(len(info.action))]
    
    def _summary(self, info, stat, i):
        action, key = info.action[i]
        visited = stat.children_visited[i]
        policy = info.policy[i]
        if visited > 0:
            Q = stat.children_score[i] / visited
            U = CPUCT * policy * math.sqrt(stat.total_visited) / (1 + visited)
        else:
            Q = -2 # not visited
            U = CPUCT * policy * math.sqrt(stat.total_visited)
        return Result(action, key, Q, U, visited, policy)

    def _simulation(self, state):
        # terminal state
        winner = state.getWinner()
        if winner != None:
            return winner * state.getCurrentPlayer()

        # leaf
        uid = state.getRepresentativeString()
        info = self._getinfo(state, uid)
        if not uid in self.stat_map:
            self.stat_map[uid] = NodeStat(len(info.action))
            return info.value

        #  select next state
        best_score = -float('inf')
        best_index = None
        stat = self.stat_map[uid]
        for i in range(len(info.action)):
            visited = stat.children_visited[i]
            if visited > 0:
                Q = stat.children_score[i] / visited
                u = Q + CPUCT * info.policy[i] * math.sqrt(stat.total_visited) / (1 + visited)
                #u = Q + CPUCT * math.sqrt(stat.total_visited) / (1 + visited)
            else:
                u = CPUCT * info.policy[i] * math.sqrt(stat.total_visited)
                #u = CPUCT * math.sqrt(stat.total_visited)
            if u > best_score:
                best_score = u
                best_index = i

        # simulate
        child_state = info.children_state[best_index]
        if child_state == None:
            a, k = info.action[best_index]
            child_state = info.children_state[best_index] = state.getNextState(a)
        v = -self._simulation(child_state)

        # update stats
        stat.children_score[best_index] += v
        stat.children_visited[best_index] += 1
        stat.total_visited += 1

        return v

    def _getinfo(self, state, uid):
        if not uid in self.info_map:
            action = state.getAction() # (action, key)
            raw_policy, value = self.nn.predict(state.getNnInput())
            info = self.info_map[uid] = NodeInfo(state, action, raw_policy, value)
            return info
        return self.info_map[uid]
