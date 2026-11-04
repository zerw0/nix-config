"""Idempotent Calibre wireless/KOReader Sync configuration for Lambda."""
import os
import secrets
import sys
from pathlib import Path
from calibre.customize.ui import add_plugin
from calibre.devices.smart_device_app.driver import SMART_DEVICE_APP
from calibre.db.legacy import LibraryDatabase
from calibre.gui2 import gprefs
from calibre.utils.config import JSONConfig, config_dir, prefs

library = Path.home() / 'Books' / 'Calibre Library'
library.mkdir(parents=True, exist_ok=True)
plugin_zip = Path(sys.argv[1])
installed = Path(config_dir) / 'plugins' / 'KOReader Sync.zip'
if not installed.exists() or installed.read_bytes() != plugin_zip.read_bytes():
    add_plugin(str(plugin_zip))

# A fresh random password stays in Calibre's private preferences and is paired
# directly with KOReader during setup. Do not put the value into the Nix store.
driver = SMART_DEVICE_APP(None)
password = driver.get_option('password') or secrets.token_urlsafe(24)
driver.set_option('password', password)
driver.set_option('autostart', True)
driver.set_option('use_fixed_port', True)
driver.set_option('port_number', '9090')

columns = {
    'column_percent_read_int': ('ko_progress', 'Read %', 'int', {'number_format': '{}%'}),
    'column_status': ('ko_status', 'Reading status', 'text', {}),
    'column_last_read_location': ('ko_location', 'KOReader location', 'text', {}),
    'column_bookmarks': ('ko_highlights', 'Highlights and notes', 'comments', {'interpret_as': 'markdown'}),
    'column_md5': ('ko_md5', 'KOReader checksum', 'text', {}),
    'column_date_synced': ('ko_synced', 'Last Kindle sync', 'datetime', {}),
    'column_sidecar': ('ko_sidecar', 'KOReader sidecar backup', 'comments', {'interpret_as': 'long-text'}),
}
db = LibraryDatabase(str(library))
changed = False
for key, (label, name, datatype, display) in columns.items():
    if label not in db.custom_column_label_map:
        db.create_custom_column(label, name, datatype, False, display=display)
        changed = True
db.close()
settings = JSONConfig(os.path.join('plugins', 'KOReader Sync.json'))
for key, (label, _, _, _) in columns.items():
    settings[key] = '#' + label
settings['checkbox_enable_automatic_sync'] = True
settings['checkbox_sync_if_more_recent'] = False
settings['checkbox_no_sync_if_finished'] = False
settings['checkbox_enable_scheduled_progressync'] = False
prefs['library_path'] = str(library)
for key in ('action-layout-toolbar', 'action-layout-toolbar-device'):
    layout = list(gprefs.get(key, gprefs.defaults.get(key, ())))
    if 'KOReader Sync' not in layout:
        layout.append('KOReader Sync')
        gprefs[key] = layout
print('Configured Calibre wireless port 9090 and automatic KOReader metadata import; password not displayed.')
