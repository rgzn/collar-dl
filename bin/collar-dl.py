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
#  parser.add_argument('--verbose', help='output detailed text describing operation while executing',
#                      action='store_true', default=False)
  subs = parser.add_subparsers(help='commands', dest='command')
  


  tellus_parser = subs.add_parser('tellus', help='http://tellus.televilt.se')
  vectronic_parser = subs.add_parser('vectronic',help='http://www.vectronic-wildlife.com')
  sirtrack_parser = subs.add_parser('sirtrack',help='https://data.sirtrack.com')
  
  #### Sirtrack     #####
  # Usage: vectronic.rb [options]
    # -u, --username user              Username
    # -D, --database [database]        db name
    # -p, --password password          Password
    # -d, --dir dir                    Directory
    # -h, --help                       Displays Help
    # -b, --begin [date]               Beginning date to retrieve data
    # -e, --end [date]                 Ending date to retrieve data
    # -v, --[no-]verbose               Run verbosely
    # -x, --csv [CSV_FILENAME]         Translate to CSV/TXT
                                      # (using filename if supplied)

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
                            
  #### Vectronic   #### 
  # Usage: vectronic.rb [options]
    # -u, --username user              Username
    # -D, --database [database]        db name
    # -p, --password password          Password
    # -d, --dir dir                    Directory
    # -h, --help                       Displays Help
    # -b, --begin [date]               Beginning date to retrieve data
    # -e, --end [date]                 Ending date to retrieve data
    # -v, --[no-]verbose               Run verbosely
    # -x, --csv [CSV_FILENAME]         Translate to CSV/TXT

    
  vectronic_parser.add_argument('-u', '--username', type=str,
                               help='User name for your account', default='snbs')
  vectronic_parser.add_argument('-p', '--password', type=str,
                               help='Password for your account (not secure)')
  vectronic_parser.add_argument('-D', '--database', type=str,
                                help='database name',default='sierrabighorn')
  vectronic_parser.add_argument('-d', '--dir', type=str, widget="DirChooser",
                               help='Directory in which to download data files', default='data')
  vectronic_parser.add_argument('-b', '--begin', type=str, widget='DateChooser',
                                help='beginning date to retrieve data from')          
  vectronic_parser.add_argument('-e', '--end', type=str, widget='DateChooser',
                                help='ending date to retrieve data from')                                       
#  vectronic_parser.add_argument('-h', '--help', dest='help', action="store_true",
#                               help='Display help with command options')
  #vectronic_parser.add_argument('-v', '--verbose', dest='verbose)        
  vectronic_parser.add_argument('-x', '--csv', type=str, 
                               help='Translate to a single CSV/TXT file')                            
                              
                               
  
  #### Vectronic    #####
  
  #### Tellus       #####
  interpreter = 'ruby'
  args = parser.parse_args()
  dargs = args.__dict__  
  command = dargs.pop('command')
  program_file = command + '.rb'
  arg_list = []  
  for key in dargs:
    if dargs[key] != None :
      if len(key) == 1 :
        prefix = "-"
      elif len(key) > 1 :
        prefix = "--"
      option = prefix + key
      arg = dargs[key]
      arg_list.append(option)
      arg_list.append(arg)
          
  collardl_command = [interpreter, program_file] + arg_list
  # program_file = args.command + '.rb'
  print( "running the following command:")
  print(args)
  print( ' '.join(collardl_command))
  p = Popen(collardl_command)
  print(p)
  print()
  #print(args)
  #print( os.system(cmd) )
  
if __name__ == '__main__':
  main()