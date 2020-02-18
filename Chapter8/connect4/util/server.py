import requests
import json

def submit(url, model, result):
    # 'https://gw10.gameindy.com/zero-checkers/submit.php'
    payload = { 'model': model, 'result': result }
    response = requests.post(url, data=payload)
    if response.status_code != 200:
        print(response.text)
        print(response.status_code, response.reason)

def getUnoptimize(url):
    # 'https://gw10.gameindy.com/zero-checkers/unoptimize.php'
    response = requests.get(url)
    if response.status_code != 200:
        print(response.text)
        print(response.status_code, response.reason)
        return None
    payload = json.loads(response.text)
    if 'model' not in payload or 'result' not in payload:
        return None
    return (payload['model'], payload['result'])

def optimize(url, model, result, updated):
    # 'https://gw10.gameindy.com/zero-checkers/optimize.php'
    payload = { 'model': model, 'result': result, 'updated': updated }
    response = requests.post(url, data=payload)
    if response.status_code != 200:
        print(response.text)
        print(response.status_code, response.reason)
