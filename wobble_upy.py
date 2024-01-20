from app import app
import wifi

ip = wifi.setup()
if ip:
    print('Starting server')
    app.run(debug=True, port=5000, host=f'{ip}')
else:
    print('Not starting server - no IP address')
