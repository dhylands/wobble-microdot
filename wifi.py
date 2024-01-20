"""Raspberry Pi Pico W file for connecting to Wifi."""

# secrets.py should contain 2 variabes:
#
#   SSID = "MY_WIFI_NETWORK_NAME"
#   PASSWORD = "MY_WIFI_PASSWORD"

import network
import time
import wifi_config

def connect(ssid, password):
    print(f'Connecting to "{ssid}"')
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True) # power up the WiFi chip
    wlan.connect(ssid, password)
    print('Waiting for wifi chip to power up...')

    max_attempts = 20
    attempt = 1
    while attempt <= max_attempts:
        if wlan.status() < 0 or wlan.status() >= 3:
            break
        print(f'  waiting for connection {attempt} ...')
        time.sleep(1)
        attempt += 1

    if wlan.status() != 3:
        print(f'Connection to "{ssid}" failed')
        return None
    ip = wlan.ifconfig()[0]
    print(f'Connected to "{ssid}" IP: {ip}')
    return ip


def setup():
    for attempt in range(3):
        ip = connect(wifi_config.SSID, wifi_config.PASSWORD)
        if ip is not None:
            return ip
        print('')
        print("Attempting to reconnect...")
        print('')
    return None
