"""Build the terminal profiles from the original NeoTokyo palette. Python 3, stdlib only."""
import json
import plistlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
palette = json.loads((ROOT / 'config/palette.json').read_text(encoding='utf-8'))


def color(value):
    return {
        'Color Space': 'sRGB',
        'Red Component': int(value[1:3], 16) / 255,
        'Green Component': int(value[3:5], 16) / 255,
        'Blue Component': int(value[5:7], 16) / 255,
    }


mapping = {
    'Background Color': 'background', 'Foreground Color': 'foreground',
    'Cursor Color': 'cursorColor', 'Selection Color': 'selectionBackground',
    'Cursor Text Color': 'background', 'Selected Text Color': 'background',
    'Bold Color': 'brightWhite', 'Link Color': 'blue',
}
ansi = ['black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white',
        'brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue',
        'brightPurple', 'brightCyan', 'brightWhite']
mapping.update({f'Ansi {i} Color': name for i, name in enumerate(ansi)})
colors = {key: color(palette[name]) for key, name in mapping.items()}
profile = {
    'Name': 'NeoTokyo',
    'Guid': 'e4291583-e47f-4ddf-8f63-193af92108fb',
    'Tags': ['NeoTokyo', 'macOS', 'Zsh'],
    'Normal Font': 'MonofokiNF-Regular 14',
    'Non Ascii Font': 'MonofokiNF-Regular 14',
    'Use Non-ASCII Font': True,
    'ASCII Anti Aliased': True, 'Non-ASCII Anti Aliased': True,
    'Use Bold Font': True, 'Use Italic Font': True,
    'Use Bright Bold': False, 'Minimum Contrast': 0,
    'Use Separate Colors for Light and Dark Mode': False,
    'Smart Cursor Color': False,
    'Use Tab Color': True, 'Tab Color': color(palette['background']),
    'Horizontal Spacing': 1, 'Vertical Spacing': 1.1,
    'Columns': 90, 'Rows': 30,
    'Cursor Type': 1, 'Blinking Cursor': False,
    'Transparency': 0.18, 'Initial Use Transparency': True,
    'Blur': True, 'Blur Radius': 18,
    'Background Image Location': '',
    'Scrollback Lines': 50000, 'Unlimited Scrollback': False,
    'Silence Bell': True, 'Visual Bell': False,
    'Custom Command': 'Yes', 'Command': '/bin/zsh -l',
    'Custom Directory': 'No',
    'Initial Text': '',
    'Option Key Sends': 2, 'Right Option Key Sends': 0,
    'Keyboard Map': {
        # Shift+Enter; Control+arrows. Action 11 is Send Hex Codes in iTerm2.
        '0xd-0x20000': {'Action': 11, 'Text': '0x1b 0x5b 0x31 0x33 0x3b 0x32 0x75'},
        '0xf702-0x40000': {'Action': 11, 'Text': '0x1b 0x5b 0x31 0x3b 0x35 0x44'},
        '0xf703-0x40000': {'Action': 11, 'Text': '0x1b 0x5b 0x31 0x3b 0x35 0x43'},
        '0x7f-0x40000': {'Action': 11, 'Text': '0x1b 0x5b 0x31 0x32 0x37 0x3b 0x35 0x75'},
    },
    **colors,
}
dest = ROOT / 'config/iterm2'
dest.mkdir(parents=True, exist_ok=True)
(dest / 'NeoTokyo.json').write_text(json.dumps({'Profiles': [profile]}, indent=2) + '\n', encoding='utf-8')
(dest / 'NeoTokyo.itermcolors').write_bytes(plistlib.dumps(colors))
print('iTerm2 profile and color preset generated.')
