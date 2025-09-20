#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Devicons plugin for ranger
# Adds file type icons to ranger file browser

import ranger.api
from ranger.core.linemode import LinemodeBase

# File extension to icon mapping
EXTENSION_ICONS = {
    # Programming languages
    'py': '🐍',
    'js': '📜',
    'ts': '📘',
    'html': '🌐',
    'css': '🎨',
    'php': '🐘',
    'rb': '💎',
    'go': '🐹',
    'rs': '🦀',
    'c': '⚙️',
    'cpp': '⚙️',
    'java': '☕',
    'sh': '🐚',
    'bash': '🐚',
    
    # Markup and data
    'json': '📋',
    'yaml': '📋',
    'yml': '📋',
    'xml': '📋',
    'md': '📝',
    'txt': '📄',
    
    # Archives
    'zip': '📦',
    'tar': '📦',
    'gz': '📦',
    
    # Images
    'png': '🖼️',
    'jpg': '🖼️',
    'jpeg': '🖼️',
    'gif': '🖼️',
    'svg': '🖼️',
    
    # Audio
    'mp3': '🎵',
    'wav': '🎵',
    'flac': '🎵',
    
    # Video
    'mp4': '🎬',
    'avi': '🎬',
    'mkv': '🎬',
    
    # Documents
    'pdf': '📕',
    'doc': '📄',
    'docx': '📄',
}

# Filename to icon mapping
FILENAME_ICONS = {
    'Dockerfile': '🐳',
    'Makefile': '🔧',
    'package.json': '📦',
    'requirements.txt': '📋',
    '.gitignore': '🚫',
    'LICENSE': '📜',
    'README.md': '📖',
    'README.txt': '📖',
}

# Directory icons
DIRECTORY_ICONS = {
    '.git': '📁',
    'node_modules': '📦',
    '__pycache__': '🐍',
    'venv': '🐍',
    'env': '🐍',
    'src': '📂',
    'test': '🧪',
    'tests': '🧪',
    'docs': '📚',
    'doc': '📚',
    'images': '🖼️',
    'img': '🖼️',
    'config': '⚙️',
    'scripts': '📜',
    'downloads': '⬇️',
    'tmp': '🗂️',
    'temp': '🗂️',
    'cache': '🗂️',
    'logs': '📋',
    'log': '📋',
}

def get_icon(filename, is_directory=False):
    """Get icon for a file or directory"""
    if is_directory:
        return DIRECTORY_ICONS.get(filename.lower(), '📁')
    
    # Check filename first
    if filename in FILENAME_ICONS:
        return FILENAME_ICONS[filename]
    
    # Check by extension
    if '.' in filename:
        ext = filename.split('.')[-1].lower()
        return EXTENSION_ICONS.get(ext, '📄')
    
    return '📄'

class DeviconsLinemode(LinemodeBase):
    name = "devicons"
    uses_metadata = False

    def filetitle(self, file, metadata):
        icon = get_icon(file.basename, file.is_directory)
        return f"{icon} {file.basename}"

# Register the linemode
ranger.api.register_linemode(DeviconsLinemode)