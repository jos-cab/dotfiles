#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Devicons plugin for ranger
# Adds file type icons to ranger file browser

import ranger.api
from ranger.core.linemode import LinemodeBase
from ranger.ext.widestring import WideString

# File extension to icon mapping
EXTENSION_ICONS = {
    # Programming languages
    'py': '',
    'js': '',
    'ts': '',
    'jsx': '',
    'tsx': '',
    'html': '',
    'css': '',
    'scss': '',
    'sass': '',
    'less': '',
    'php': '',
    'rb': '',
    'go': '',
    'rs': '',
    'c': '',
    'cpp': '',
    'cc': '',
    'cxx': '',
    'h': '',
    'hpp': '',
    'java': '',
    'kt': '',
    'swift': '',
    'cs': '',
    'vb': '',
    'fs': '',
    'clj': '',
    'cljs': '',
    'scala': '',
    'hs': '',
    'elm': '',
    'lua': '',
    'pl': '',
    'r': '',
    'jl': '',
    'dart': '',
    'vim': '',
    'sh': '',
    'bash': '',
    'zsh': '',
    'fish': '',
    'ps1': '',
    'bat': '',
    'cmd': '',
    
    # Markup and data
    'xml': '',
    'json': '',
    'yaml': '',
    'yml': '',
    'toml': '',
    'ini': '',
    'cfg': '',
    'conf': '',
    'md': '',
    'rst': '',
    'tex': '',
    'txt': '',
    
    # Archives
    'zip': '',
    'rar': '',
    '7z': '',
    'tar': '',
    'gz': '',
    'bz2': '',
    'xz': '',
    'deb': '',
    'rpm': '',
    'pkg': '',
    'dmg': '',
    'iso': '',
    
    # Images
    'png': '',
    'jpg': '',
    'jpeg': '',
    'gif': '',
    'bmp': '',
    'svg': '',
    'ico': '',
    'tiff': '',
    'webp': '',
    'raw': '',
    
    # Audio
    'mp3': '',
    'wav': '',
    'flac': '',
    'aac': '',
    'ogg': '',
    'wma': '',
    'm4a': '',
    
    # Video
    'mp4': '',
    'avi': '',
    'mkv': '',
    'mov': '',
    'wmv': '',
    'flv': '',
    'webm': '',
    'm4v': '',
    
    # Documents
    'pdf': '',
    'doc': '',
    'docx': '',
    'xls': '',
    'xlsx': '',
    'ppt': '',
    'pptx': '',
    'odt': '',
    'ods': '',
    'odp': '',
    
    # Fonts
    'ttf': '',
    'otf': '',
    'woff': '',
    'woff2': '',
    'eot': '',
    
    # System
    'log': '',
    'tmp': '',
    'cache': '',
    'lock': '',
    'pid': '',
    'sock': '',
    
    # Git
    'gitignore': '',
    'gitmodules': '',
    'gitattributes': '',
}

# Filename to icon mapping
FILENAME_ICONS = {
    # Config files
    'Dockerfile': '',
    'docker-compose.yml': '',
    'docker-compose.yaml': '',
    'Makefile': '',
    'CMakeLists.txt': '',
    'package.json': '',
    'package-lock.json': '',
    'yarn.lock': '',
    'Cargo.toml': '',
    'Cargo.lock': '',
    'go.mod': '',
    'go.sum': '',
    'requirements.txt': '',
    'Pipfile': '',
    'Pipfile.lock': '',
    'setup.py': '',
    'setup.cfg': '',
    'pyproject.toml': '',
    'tox.ini': '',
    'Gemfile': '',
    'Gemfile.lock': '',
    'composer.json': '',
    'composer.lock': '',
    'webpack.config.js': '',
    'rollup.config.js': '',
    'vite.config.js': '',
    'tsconfig.json': '',
    'jsconfig.json': '',
    '.eslintrc': '',
    '.eslintrc.js': '',
    '.eslintrc.json': '',
    '.prettierrc': '',
    '.babelrc': '',
    'babel.config.js': '',
    '.editorconfig': '',
    '.gitignore': '',
    '.gitmodules': '',
    '.gitattributes': '',
    'LICENSE': '',
    'README.md': '',
    'README.rst': '',
    'README.txt': '',
    'CHANGELOG.md': '',
    'CONTRIBUTING.md': '',
    '.env': '',
    '.env.example': '',
    '.env.local': '',
    
    # IDE files
    '.vscode': '',
    '.idea': '',
    '.vs': '',
    
    # OS files
    '.DS_Store': '',
    'Thumbs.db': '',
    'desktop.ini': '',
}

# Directory icons
DIRECTORY_ICONS = {
    '.git': '',
    '.github': '',
    '.vscode': '',
    '.idea': '',
    'node_modules': '',
    '__pycache__': '',
    '.pytest_cache': '',
    'venv': '',
    'env': '',
    '.env': '',
    'dist': '',
    'build': '',
    'target': '',
    'bin': '',
    'lib': '',
    'include': '',
    'src': '',
    'test': '',
    'tests': '',
    'docs': '',
    'doc': '',
    'assets': '',
    'static': '',
    'public': '',
    'images': '',
    'img': '',
    'icons': '',
    'fonts': '',
    'css': '',
    'js': '',
    'scss': '',
    'sass': '',
    'less': '',
    'config': '',
    'configs': '',
    'scripts': '',
    'tools': '',
    'utils': '',
    'helpers': '',
    'components': '',
    'pages': '',
    'views': '',
    'templates': '',
    'layouts': '',
    'partials': '',
    'includes': '',
    'modules': '',
    'plugins': '',
    'extensions': '',
    'addons': '',
    'themes': '',
    'styles': '',
    'stylesheets': '',
    'media': '',
    'uploads': '',
    'downloads': '',
    'tmp': '',
    'temp': '',
    'cache': '',
    'logs': '',
    'log': '',
    'backup': '',
    'backups': '',
    'archive': '',
    'archives': '',
}

def get_icon(filename, is_directory=False):
    """Get icon for a file or directory"""
    if is_directory:
        return DIRECTORY_ICONS.get(filename.lower(), '')
    
    # Check filename first
    if filename in FILENAME_ICONS:
        return FILENAME_ICONS[filename]
    
    # Check by extension
    if '.' in filename:
        ext = filename.split('.')[-1].lower()
        return EXTENSION_ICONS.get(ext, '')
    
    return ''

class DeviconsLinemode(LinemodeBase):
    name = "devicons"
    uses_metadata = False

    def filetitle(self, file, metadata):
        icon = get_icon(file.basename, file.is_directory)
        if icon:
            return WideString(f"{icon} {file.basename}")
        return file.basename

# Register the linemode
@ranger.api.register_linemode
class DeviconsLinemodeRegistered(DeviconsLinemode):
    pass