import sys
import signal
import threading
from types import FrameType
from typing import Optional
from flask import Flask

server = Flask(__name__)


@server.get('/')
def home() -> str:
    return 'Hello World!'


def shutdown_handler(
        signal_number: int,
        frame: Optional[FrameType]
) -> None:
    print("Received shutdown signal. Closing the server...")
    

    def shutdown() -> None:
        print("Server closed. Exiting process...")
        sys.exit(0)


    def force_shutdown() -> None:
        print("Couldn't close the server gracefully. Exiting forcefully...")
        sys.exit(1)


    shutdown_timer = threading.Timer(5.0, force_shutdown)
    shutdown_timer.start()

    try:
        shutdown()
    finally:
        shutdown_timer.cancel()


if __name__ == '__main__':
    signal.signal(signal.SIGINT, shutdown_handler)
    signal.signal(signal.SIGTERM, shutdown_handler)

    server.run(host='0.0.0.0', port=5000)

