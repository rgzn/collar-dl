# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 16:24:18 2016

@author: jweissman
"""

from __future__ import print_function

import argparse
from gooey import Gooey, GooeyParser

running = True

@Gooey(optional_cols=2, program_name="GPS Collar Data Download")

def main():
  description_msg = 'Initiate batch downloads GPS collar data' \
                    ' for commonly used collar websites'
  
  parser = GooeyParser(description=description_msg)
  parser.add_argument('--verbose', help='output detailed text describing operation while executing',
                      action='store_true', default=False)
  subs = parser.add_subparsers(help='commands', dest='command')
  tellus_parser = subs.add_parser('Tellus', help='http://tellus.televilt.se')
  vectronic_parser = subs.add_parser('Vectronic',help='http://www.vectronic-wildlife.com')
  sirtrack_parser = subs.add_parser('Sirtrack',htlp='https://data.sirtrack.com")
  
  #### Sirtrack ####
  
  ####
  
  ####
  ####
  
if __name__ == '__main__':
  main()