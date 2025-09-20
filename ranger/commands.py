#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Custom commands for ranger

from ranger.api.commands import Command

class enable_devicons(Command):
    """Enable devicons linemode"""
    
    def execute(self):
        self.fm.execute_console("linemode devicons")
        self.fm.notify("Devicons enabled")

class disable_devicons(Command):
    """Disable devicons linemode"""
    
    def execute(self):
        self.fm.execute_console("linemode filename")
        self.fm.notify("Devicons disabled")