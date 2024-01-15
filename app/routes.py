"""Wobble Bot MicroDot routes."""

import asyncio
import json
import random
import time

from microdot import Microdot, Response, send_file
from microdot.utemplate import Template
from microdot.websocket import with_websocket


app = Microdot()
Response.default_content_type = 'text/html'

TEMPLATE_DIR = "app/templates"

class Globals:
    start_time = 0

G = Globals()

Template.initialize(TEMPLATE_DIR)

@app.route('/')
async def index(req):
    """Handle root page."""
    return Template('index.html').render(title="Wobble Home Page", subtitle="Wobble Subtitle")


@app.route('/charts')
async def index(req):
    """Handle charts page."""
    print('/charts requested')
    G.start_time = 0
    return Template('charts.html').render(title="Charts")


@app.route('/chart-data')
@with_websocket
async def chart_data(req, ws):
    """
    WebSocket endpoint which serves up chart data.
    """
    print('/chart-data requested')
    if G.start_time == 0:
        G.start_time = time.time()
    while True:
        json_data = json.dumps({
            "time": f'{time.time() - G.start_time:.3f}',
            "value": random.random() * 100,
        })
        try:
            await ws.send(f'{json_data}\n\n')
        except ConnectionResetError:
            # This happens when the client side closes the socket by
            # clicking on the chart
            break
        await asyncio.sleep(0.5)


@app.route('/echo')
@with_websocket
async def echo(request, ws):
    while True:
        message = await ws.receive()
        await ws.send(message)

@app.route('/form', methods=['GET', 'POST'])
async def form(req):
    """Handle a Form page."""
    name = None
    if req.method == 'POST':
        name = req.form.get('name')
    print('name =', name)
    return Template('form.html').render(name=name)

@app.route('/static/<path:path>')
async def static(request, path):
    if '..' in path:
        # directory traversal is not allowed
        return f'Path "{path}" Not found', 404
    return send_file('app/static/' + path)

@app.errorhandler(404)
def not_found(request):
    return f'Not found: "{request.path}"'
