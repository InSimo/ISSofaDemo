"""
Update (or create) the `.bin.json` file.

Usage: python <this-script.py> <binary_dir>
"""
from __future__ import print_function
import sys
import os
import json

SELF_DIR = os.path.abspath(os.path.dirname(__file__))
BIN_JSON_FILE_PATH = os.path.join(SELF_DIR, '..', '.bin.json')

def update_binary_dir(binary_dir):
    if os.path.exists(BIN_JSON_FILE_PATH):
        with open(BIN_JSON_FILE_PATH) as json_file:
            data = json.load(json_file)
        already_set_binary_dir = data.get('binary_dir')
        if binary_dir == already_set_binary_dir:
            print('update_binary_dir: nothing to do')
            return # nothing to do
        if already_set_binary_dir is not None:
            for build_config in ('Release', 'RelWithDebInfo', 'Debug'):
                if already_set_binary_dir == binary_dir + '/' + build_config:
                    # We are certainly doing a new CMake configure but a build
                    # was previously done and the built config name was already
                    # appended to the path. So let's keep it.
                    print('update_binary_dir: keeping the existing value %r '
                          'which is more complete than the requested %r'
                          % (already_set_binary_dir, binary_dir))
                    return
    else:
        data = {}
    data['binary_dir'] = binary_dir
    with open(BIN_JSON_FILE_PATH, 'w') as json_file:
        json.dump(data, json_file, indent=4)
    print('update_binary_dir: set to %r' % binary_dir)

if __name__ == '__main__':
    update_binary_dir(sys.argv[1])
