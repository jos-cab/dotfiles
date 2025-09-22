#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Custom ranger commands for enhanced functionality

from ranger.api.commands import Command
import os

class compress(Command):
    """
    :compress <archive_name>
    
    Compress selected files/directories into an archive.
    The archive format is determined by the extension.
    Supported formats: .zip, .tar.gz, .tar.bz2, .tar.xz, .7z
    """
    
    def execute(self):
        if not self.arg(1):
            self.fm.notify("Usage: compress <archive_name>", bad=True)
            return
            
        archive_name = self.arg(1)
        selected_files = [f.path for f in self.fm.thistab.get_selection()]
        
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return
            
        # Determine compression command based on extension
        if archive_name.endswith('.zip'):
            cmd = ['zip', '-r', archive_name] + selected_files
        elif archive_name.endswith('.tar.gz') or archive_name.endswith('.tgz'):
            cmd = ['tar', '-czf', archive_name] + selected_files
        elif archive_name.endswith('.tar.bz2') or archive_name.endswith('.tbz2'):
            cmd = ['tar', '-cjf', archive_name] + selected_files
        elif archive_name.endswith('.tar.xz') or archive_name.endswith('.txz'):
            cmd = ['tar', '-cJf', archive_name] + selected_files
        elif archive_name.endswith('.7z'):
            cmd = ['7z', 'a', archive_name] + selected_files
        else:
            # Default to tar.gz
            if not archive_name.endswith('.tar.gz'):
                archive_name += '.tar.gz'
            cmd = ['tar', '-czf', archive_name] + selected_files
            
        self.fm.execute_command(cmd, flags='t')
        self.fm.notify(f"Compressing to {archive_name}...")

class extract(Command):
    """
    :extract
    
    Extract the selected archive(s).
    """
    
    def execute(self):
        selected_files = [f for f in self.fm.thistab.get_selection() if f.is_file]
        
        if not selected_files:
            self.fm.notify("No files selected!", bad=True)
            return
            
        for f in selected_files:
            if f.path.endswith(('.zip', '.rar', '.7z', '.tar', '.tar.gz', '.tgz', 
                               '.tar.bz2', '.tbz2', '.tar.xz', '.txz', '.gz', '.bz2', '.xz')):
                
                # Create extraction directory
                extract_dir = f.path.rsplit('.', 1)[0] + '_extracted'
                if not os.path.exists(extract_dir):
                    os.makedirs(extract_dir)
                
                # Determine extraction command
                if f.path.endswith('.zip'):
                    cmd = ['unzip', f.path, '-d', extract_dir]
                elif f.path.endswith('.rar'):
                    cmd = ['unrar', 'x', f.path, extract_dir + '/']
                elif f.path.endswith('.7z'):
                    cmd = ['7z', 'x', f.path, f'-o{extract_dir}']
                elif f.path.endswith(('.tar', '.tar.gz', '.tgz', '.tar.bz2', '.tbz2', '.tar.xz', '.txz')):
                    cmd = ['tar', '-xf', f.path, '-C', extract_dir]
                elif f.path.endswith('.gz'):
                    cmd = ['gunzip', '-c', f.path]
                    # For .gz files, extract to the directory with original name
                    with open(os.path.join(extract_dir, os.path.basename(f.path[:-3])), 'w') as out:
                        self.fm.execute_command(cmd, stdout=out, flags='w')
                    continue
                elif f.path.endswith('.bz2'):
                    cmd = ['bunzip2', '-c', f.path]
                    with open(os.path.join(extract_dir, os.path.basename(f.path[:-4])), 'w') as out:
                        self.fm.execute_command(cmd, stdout=out, flags='w')
                    continue
                elif f.path.endswith('.xz'):
                    cmd = ['unxz', '-c', f.path]
                    with open(os.path.join(extract_dir, os.path.basename(f.path[:-3])), 'w') as out:
                        self.fm.execute_command(cmd, stdout=out, flags='w')
                    continue
                else:
                    continue
                    
                self.fm.execute_command(cmd, flags='t')
                self.fm.notify(f"Extracting {f.basename} to {extract_dir}")
            else:
                self.fm.notify(f"{f.basename} is not a supported archive format", bad=True)

class markdown_preview(Command):
    """
    :markdown_preview
    
    Preview markdown file with syntax highlighting using glow or bat.
    """
    
    def execute(self):
        if not self.fm.thisfile or not self.fm.thisfile.path.endswith(('.md', '.markdown')):
            self.fm.notify("Not a markdown file!", bad=True)
            return
            
        # Try glow first, then bat, then pandoc
        commands = [
            ['glow', '-p', self.fm.thisfile.path],
            ['bat', '--color=always', '--style=header,grid', '--language=markdown', self.fm.thisfile.path],
            ['pandoc', '-f', 'markdown', '-t', 'plain', self.fm.thisfile.path]
        ]
        
        for cmd in commands:
            try:
                self.fm.execute_command(cmd, flags='p')
                return
            except:
                continue
                
        self.fm.notify("No markdown preview tool available (install glow, bat, or pandoc)", bad=True)

class markdown_html(Command):
    """
    :markdown_html
    
    Convert markdown to HTML and open in browser.
    """
    
    def execute(self):
        if not self.fm.thisfile or not self.fm.thisfile.path.endswith(('.md', '.markdown')):
            self.fm.notify("Not a markdown file!", bad=True)
            return
            
        input_file = self.fm.thisfile.path
        output_file = f"/tmp/{os.path.basename(input_file)}.html"
        
        # Convert to HTML
        cmd = ['pandoc', '-f', 'markdown', '-t', 'html', '--standalone', 
               '--css', 'https://cdn.jsdelivr.net/npm/github-markdown-css@5/github-markdown-light.css',
               input_file, '-o', output_file]
        
        try:
            self.fm.execute_command(cmd, flags='w')
            # Open in browser
            browsers = ['firefox', 'chromium', 'google-chrome', 'xdg-open']
            for browser in browsers:
                try:
                    self.fm.execute_command([browser, output_file], flags='f')
                    self.fm.notify(f"Opening {output_file} in {browser}")
                    return
                except:
                    continue
            self.fm.notify("No browser found to open HTML file", bad=True)
        except:
            self.fm.notify("Failed to convert markdown to HTML (install pandoc)", bad=True)