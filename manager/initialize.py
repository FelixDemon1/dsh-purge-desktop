import json
import os
import secrets
from pathlib import Path

root = Path('/shared')
for directory in (root, root / 'auths', root / 'data'):
    directory.mkdir(parents=True, exist_ok=True)
    os.chown(directory, 10001, 10001)
config_path = root / 'config.json'
if not config_path.exists():
    config = json.loads(Path('/seed/config.example.json').read_text())
    config['api_key'] = secrets.token_urlsafe(32)
    config['auth_dir'] = '/shared/auths'
    config['state_file'] = '/shared/data/state.json'
    config['global']['enabled'] = False
    config['prompt'] = {'mode': 'append', 'file': '/shared/prompt.md'}
    fd = os.open(config_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    with os.fdopen(fd, 'w') as stream:
        json.dump(config, stream, ensure_ascii=False, indent=2)
        stream.write('\n')
    os.chown(config_path, 10001, 10001)
