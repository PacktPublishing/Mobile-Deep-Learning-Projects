from flask import Flask, request, jsonify
import os
import sys
import multiprocessing as mp
from logging import getLogger

from chess_zero.agent.player_chess import ChessPlayer
from chess_zero.config import Config, PlayWithHumanConfig
from chess_zero.env.chess_env import ChessEnv

from chess_zero.agent.model_chess import ChessModel
from chess_zero.lib.model_helper import load_best_model_weight

logger = getLogger(__name__)


def start(config: Config):

    PlayWithHumanConfig().update_play_config(config.play)

    me_player = None
    env = ChessEnv().reset()

    app = Flask(__name__)

    model = ChessModel(config)

    if not load_best_model_weight(model):
        raise RuntimeError("Best model not found!")

    player = ChessPlayer(config, model.get_pipes(config.play.search_threads))

    @app.route('/play', methods=["GET", "POST"])
    def play():
        data = request.get_json()
        print(data["position"])
        env.update(data["position"])
        env.step(data["moves"], False)
        bestmove = player.action(env, False)
        return jsonify(bestmove)

    app.run(host="0.0.0.0", port="8080")
