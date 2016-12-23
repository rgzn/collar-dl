# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 16:24:18 2016

@author: jweissman
"""

from __future__ import print_function

import argparse
from gooey import Gooey, GooeyParser
from subprocess import Popen, PIPE

running = True

@Gooey(optional_cols=2, program_name="GPS Collar Data Download")

def main():
  description_msg = 'Initiate batch downloads GPS collar data' \
                    ' for commonly used collar websites'
  
  parser = GooeyParser(description=description_msg)
  parser.add_argument('--verbose', help='output detailed text describing operation while executing',
                      action='store_true', default=False)
  subs = parser.add_subparsers(help='commands', dest='command')
  
  tellus_parser = subs.add_parser('tellus', help='http://tellus.televilt.se')
  vectronic_parser = subs.add_parser('vectronic',help='http://www.vectronic-wildlife.com')
  sirtrack_parser = subs.add_parser('sirtrack',help='https://data.sirtrack.com')
  
  #### Sirtrack     #####
  sirtrack_parser.add_argument('-u', '--username', type=str,
                               help='User name for your account')
  sirtrack_parser.add_argument('-p', '--password', type=str,
                               help='Password for your account (not secure)')
  sirtrack_parser.add_argument('-d', '--dir', type=str,
                               help='Directory in which to download data files')
#  sirtrack_parser.add_argument('-h', '--help', dest='help', action="store_true",
#                               help='Display help with command options')
  #sirtrack_parser.add_argument('-v', '--verbose', dest='verbose)        
  sirtrack_parser.add_argument('-x', '--csv', type=str, 
                               help='Translate to a single CSV/TXT file')                            
                              
                               
  
  #### Vectronic    #####
  
  #### Tellus       #####
  
  args = parser.parse_args()
  program_file = args.command + '.rb'
  interpreter = 'ruby'
  p = Popen([interpreter, program_file, ])
  print(os.system(cmd)  )
  
if __name__ == '__main__':
  main()