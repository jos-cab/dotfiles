#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Devicons plugin for ranger
# Adds file type icons to ranger file browser

import ranger.api
from ranger.core.linemode import LinemodeBase

# File extension to icon mapping
EXTENSION_ICONS = {
    'py': '🐍', 'js': '📜', 'ts': '📘', 'html': '🌐', 'css': '🎨',
    'php': '🐘', 'rb': '💎', 'go': '🐹', 'rs': '🦀', 'c': '⚙️',
    'cpp': '⚙️', 'java': '☕', 'sh': '🐚', 'bash': '🐚',
    'json': '📋', 'yaml': '📋', 'yml': '📋', 'xml': '📋',
    'md': '📝', 'txt': '📄', 'zip': '📦', 'tar': '📦', 'gz': '📦',
    'png': '🖼️', 'jpg': '🖼️', 'jpeg': '🖼️', 'gif': '🖼️', 'svg': '🖼️',
    'mp3': '🎵', 'wav': '🎵', 'flac': '🎵', 'mp4': '🎬', 'avi': '🎬',
    'mkv': '🎬', 'pdf': '📕', 'doc': '📄', 'docx': '📄',
}

FILENAME_ICONS = {
    'Dockerfile': '🐳', 'Makefile': '🔧', 'package.json': '📦',
    'requirements.txt': '📋', '.gitignore': '🚫', 'LICENSE': '📜',
    'README.md': '📖', 'README.txt': '📖',
}

DIRECTORY_ICONS = {
    '.git': '📁', 'node_modules': '📦', '__pycache__': '🐍',
    'venv': '🐍', 'env': '🐍', 'src': '📂', 'test': '🧪',
    'tests': '🧪', 'docs': '📚', 'doc': '📚', 'images': '🖼️',
    'img': '🖼️', 'config': '⚙️', 'scripts': '📜',
}

def get_icon(filename, is_directory=False):
    if is_directory:
        return DIRECTORY_ICONS.get(filename.lower(), '📁')
    if filename in FILENAME_ICONS:
        return FILENAME_ICONS[filename]
    if '.' in filename:
        ext = filename.split('.')[-1].lower()
        return EXTENSION_ICONS.get(ext, '📄')
    return '📄'

class DeviconsLinemode(LinemodeBase):
    name = "devicons"
    
    def filetitle(self, file, metadata):
        icon = get_icon(file.basename, file.is_directory)
        return f"{icon} {file.basename}"

# Register the linemode
ranger.api.register_linemode(DeviconsLinemode)

# Hook to automatically enable devicons when ranger starts
def hook_init(fm):
    try:
        # Wait a bit for everything to load, then set devicons
        import threading
        def set_devicons():
            try:
                fm.execute_console("linemode devicons")
            except:
                pass
        timer = threading.Timer(0.1, set_devicons)
        timer.start()
    except:
        pass

# Register the hook
ranger.api.hook_init = hook_init