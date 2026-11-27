"""Run with python3 tests/check.py. No network or third-party Python packages."""
import json
import os
from pathlib import Path
import plistlib
import pty
import shutil
import struct
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class Assets(unittest.TestCase):
    def test_color_exports_match_original_palette(self):
        palette = json.loads((ROOT / 'config/palette.json').read_text(encoding='utf-8'))
        profile = json.loads((ROOT / 'config/iterm2/NeoTokyo.json').read_text())['Profiles'][0]
        preset = plistlib.loads((ROOT / 'config/iterm2/NeoTokyo.itermcolors').read_bytes())
        names = ['black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white',
                 'brightBlack', 'brightRed', 'brightGreen', 'brightYellow', 'brightBlue',
                 'brightPurple', 'brightCyan', 'brightWhite']
        pairs = [(f'Ansi {i} Color', n) for i, n in enumerate(names)]
        pairs += [('Background Color', 'background'), ('Foreground Color', 'foreground'),
                  ('Cursor Color', 'cursorColor'), ('Selection Color', 'selectionBackground')]
        for key, name in pairs:
            with self.subTest(color=key):
                actual = '#' + ''.join(f'{round(profile[key][component] * 255):02X}'
                                      for component in ('Red Component', 'Green Component', 'Blue Component'))
                self.assertEqual(actual, palette[name])
                self.assertEqual(profile[key], preset[key])

    def test_profile_font_uses_real_postscript_name(self):
        font = (ROOT / 'fonts/MonofokiNerdFont-Regular.ttf').read_bytes()
        names = set()
        for index in range(struct.unpack_from('>H', font, 4)[0]):
            tag, _, offset, _ = struct.unpack_from('>4sIII', font, 12 + index * 16)
            if tag != b'name':
                continue
            _, count, strings = struct.unpack_from('>HHH', font, offset)
            for record in range(count):
                platform, _, _, name, length, pos = struct.unpack_from('>HHHHHH', font, offset + 6 + record * 12)
                if name == 6:
                    encoding = 'utf-16-be' if platform in (0, 3) else 'mac_roman'
                    names.add(font[offset + strings + pos:offset + strings + pos + length].decode(encoding))
        profile = json.loads((ROOT / 'config/iterm2/NeoTokyo.json').read_text())['Profiles'][0]
        self.assertIn(profile['Normal Font'].rsplit(' ', 1)[0], names)

    def test_shell_syntax(self):
        for script in ('install.sh', 'uninstall.sh'):
            subprocess.run(['bash', '-n', str(ROOT / script)], check=True)
        zsh = os.environ.get('NEOTOKYO_TEST_ZSH') or shutil.which('zsh')
        if zsh and not os.environ.get('NEOTOKYO_TEST_ZSH_ROOT'):
            result = subprocess.run([zsh, '-n', str(ROOT / 'config/neotokyo.zsh')], check=True, capture_output=True, text=True)
            self.assertEqual(result.stderr, '')


@unittest.skipIf(os.name == 'nt' or os.geteuid() == 0, 'Installer isolation requires a regular Unix user')
class Installer(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='neotokyo test ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / 'home with spaces'
        self.home.mkdir()
        bin_dir = self.root / 'bin'
        bin_dir.mkdir()
        self.env = {**os.environ, 'HOME': str(self.home), 'PATH': str(bin_dir) + ':' + os.environ['PATH']}
        for key in ('XDG_CONFIG_HOME', 'XDG_STATE_HOME', 'ZDOTDIR'):
            self.env.pop(key, None)
        self.fake_uname = bin_dir / 'uname'
        self.fake_uname.write_text('#!/bin/sh\ncase "$1" in -s) echo Darwin;; -m) echo x86_64;; esac\n')
        (bin_dir / 'sysctl').write_text('#!/bin/sh\nexit 1\n')
        (bin_dir / 'brew').write_text('#!/bin/sh\nexit 0\n')
        (bin_dir / 'pgrep').write_text('#!/bin/sh\n[ "${NEOTOKYO_TEST_RUNNING:-0}" = 1 ]\n')
        (bin_dir / 'defaults').write_text("""#!/bin/sh
state="$HOME/default-profile-test"
case "$1" in
 read) [ -f "$state" ] && cat "$state" || exit 1 ;;
 write) printf '%s\n' "$5" > "$state" ;;
 delete) rm -f "$state" ;;
 *) exit 2 ;;
esac
""")
        for file in bin_dir.iterdir():
            file.chmod(0o755)

    def run_script(self, script, success=True):
        result = subprocess.run(['bash', str(ROOT / script)], env=self.env,
                                text=True, capture_output=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_install_reinstall_uninstall_preserves_user_changes(self):
        rc = self.home / '.zshrc'
        rc.write_text('# My settings\nexport EXAMPLE=1\n')
        self.run_script('install.sh')
        config = self.home / '.config/neotokyo'
        (config / 'local.zsh').write_text('export PERSONAL=1\n')
        with rc.open('a') as file:
            file.write('# Added after installation\n')
        self.run_script('install.sh')
        self.assertEqual(rc.read_text().count('# >>> NeoTokyo >>>'), 1)
        self.assertEqual((config / 'local.zsh').read_text(), 'export PERSONAL=1\n')
        self.assertTrue((config / 'shortcuts.txt').is_file())
        self.assertEqual(len(list((self.home / 'Library/Fonts').glob('*.ttf'))), 4)
        self.run_script('uninstall.sh')
        self.assertIn('export EXAMPLE=1', rc.read_text())
        self.assertIn('# Added after installation', rc.read_text())
        self.assertNotIn('>>> NeoTokyo', rc.read_text())
        self.assertTrue((config / 'local.zsh').is_file())
        self.assertFalse((self.home / 'Library/Application Support/iTerm2/DynamicProfiles/NeoTokyo.json').exists())
        self.run_script('uninstall.sh')

    def test_symlink_and_custom_zdotdir(self):
        zdot = self.home / 'dot files'
        zdot.mkdir()
        target = zdot / 'actual-rc'
        target.write_text('export KEEP_ME=yes\n')
        rc = zdot / '.zshrc'
        rc.symlink_to(target)
        self.env['ZDOTDIR'] = str(zdot)
        self.env['XDG_CONFIG_HOME'] = str(self.home / 'custom config')
        self.run_script('install.sh')
        self.assertTrue(rc.is_symlink())
        self.assertIn('>>> NeoTokyo', target.read_text())
        self.assertTrue((self.home / 'custom config/neotokyo/neotokyo.zsh').exists())
        self.run_script('uninstall.sh')
        self.assertTrue(rc.is_symlink())
        self.assertIn('KEEP_ME', target.read_text())

    def test_default_profile_restores_previous_and_respects_user_change(self):
        state = self.home / 'default-profile-test'
        state.write_text('old-profile-guid\n')
        self.run_script('install.sh')
        self.assertEqual(state.read_text().strip(), 'e4291583-e47f-4ddf-8f63-193af92108fb')
        self.run_script('install.sh')
        self.run_script('uninstall.sh')
        self.assertEqual(state.read_text().strip(), 'old-profile-guid')
        self.run_script('install.sh')
        state.write_text('user-selected-profile\n')
        self.run_script('uninstall.sh')
        self.assertEqual(state.read_text().strip(), 'user-selected-profile')

    def test_running_iterm_aborts_before_changing_files(self):
        self.env['NEOTOKYO_TEST_RUNNING'] = '1'
        for script in ('install.sh', 'uninstall.sh'):
            self.run_script(script, success=False)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_no_previous_default_is_restored_as_unset(self):
        self.run_script('install.sh')
        self.run_script('uninstall.sh')
        self.assertFalse((self.home / 'default-profile-test').exists())

    def test_missing_homebrew_downloads_official_installer(self):
        bin_dir = self.root / 'bin'
        (bin_dir / 'brew').unlink()
        self.env['PATH'] = str(bin_dir) + ':/usr/bin:/bin:/usr/sbin:/sbin'
        fake_installer = self.root / 'official-install-fixture.sh'
        fake_installer.write_text("""#!/bin/bash
cat > "$NEOTOKYO_FAKE_BIN/brew" <<'BREW'
#!/bin/sh
printf '%s\\n' "$*" >> "$HOME/brew-calls"
exit 0
BREW
chmod +x "$NEOTOKYO_FAKE_BIN/brew"
printf 'installed\\n' > "$HOME/homebrew-installed"
""")
        (bin_dir / 'curl').write_text("""#!/bin/sh
[ "$1" = '-fsSL' ] || exit 2
[ "$2" = 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh' ] || exit 2
[ "$3" = '-o' ] || exit 2
cp "$NEOTOKYO_INSTALL_FIXTURE" "$4"
""")
        (bin_dir / 'curl').chmod(0o755)
        self.env.update(NEOTOKYO_FAKE_BIN=str(bin_dir), NEOTOKYO_INSTALL_FIXTURE=str(fake_installer))
        master, slave = pty.openpty()
        try:
            proc = subprocess.Popen(['bash', str(ROOT / 'install.sh')], env=self.env,
                                    stdin=slave, stdout=slave, stderr=slave)
            os.close(slave)
            slave = None
            output = bytearray()
            while True:
                try:
                    data = os.read(master, 8192)
                except OSError:
                    break
                if not data:
                    break
                output.extend(data)
            self.assertEqual(proc.wait(timeout=20), 0, output.decode(errors='replace'))
        finally:
            if slave is not None:
                os.close(slave)
            os.close(master)
        self.assertEqual((self.home / 'homebrew-installed').read_text(), 'installed\n')
        self.assertTrue((self.home / '.config/neotokyo/neotokyo.zsh').is_file())

    def test_malformed_markers_never_truncate_rc(self):
        rc = self.home / '.zshrc'
        for content in ('# >>> NeoTokyo >>>\nkeep\n', '# <<< NeoTokyo <<<\nkeep\n# >>> NeoTokyo >>>\n'):
            for script in ('install.sh', 'uninstall.sh'):
                with self.subTest(script=script, content=content):
                    rc.write_text(content)
                    self.run_script(script, success=False)
                    self.assertEqual(rc.read_text(), content)

    def test_other_platform_rejected_before_changes(self):
        self.fake_uname.write_text('#!/bin/sh\necho Linux\n')
        self.run_script('install.sh', success=False)
        self.assertEqual(list(self.home.iterdir()), [])


if __name__ == '__main__':
    unittest.main(verbosity=2)
