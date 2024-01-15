#!/usr/bin/env python3
"""Application entry point."""

import asyncio
import os
import sys
import time
import traceback

from app import app


def file_newer_than1(timestamp: float) -> bool:
    """Recursively ests if any file in the current directory tree is neweer than timestamp."""
    for root, _, files in os.walk('.'):
        for file in files:
            try:
                filename = os.path.join(root, file)
                print(filename)
                if os.path.getmtime(filename) > timestamp:
                    print('File:', filename, 'was modified')
                    return True
            except OSError:
                # File doesn't exist - this means it was removed bwteen the time os.walk
                # was called and getmtime was called.
                pass
    return False


def entry_newer_than(entry: os.DirEntry, timestamp: float) -> bool:
    """Checks if directory entry is newer than `timestamp`."""
    if entry.is_dir():
        if entry.name == '.direnv':
            # This is the python virtual environment directory associated with direnv,
            # which we can skip
            return False
        return dir_newer_than(entry.path, timestamp)
    try:
        if os.path.getmtime(entry.path) > timestamp:
            print('File:', entry.path, 'was modified')
            return True
    except OSError:
        # File doesn't exist - this means it was removed bwteen the time os.walk
        # was called and getmtime was called.
        pass
    return False


def dir_newer_than(dirname: str, timestamp: float) -> bool:
    """Recursively tests if any file in `dir` is neweer than `timestamp`."""
    with os.scandir(dirname) as it:
        for entry in it:
            if entry_newer_than(entry, timestamp):
                return True
    return False


async def start_watcher():
    """Starts a file watcher, which shutsdown the server when changes are detected."""
    try:
        await asyncio.sleep(1)
        print("Watching for changes...")
        start_time = time.time()
        while True:
            if dir_newer_than('.', start_time):
                break
            await asyncio.sleep(0.5)
    except Exception as exc:  # pylint: disable=broad-exception-caught
        print(exc)
        traceback.print_tb(exc.__traceback__)
        print('-----')
    app.shutdown()


async def main():
    """Main entry point."""
    await asyncio.gather(start_watcher(),
                         app.start_server(debug=True),
                         return_exceptions=True)
    # If we get this far, then the server was shutdown
    sys.exit(0)


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print('')
        print('Quitting due to Control-C')
        sys.exit(1)
