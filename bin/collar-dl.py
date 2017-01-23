# -*- coding: utf-8 -*-
"""
Created on Mon Nov 21 16:24:18 2016

@author: jweissman
"""

from __future__ import print_function

import time
import argparse
from gooey import Gooey, GooeyParser
from subprocess import Popen, PIPE

running = True

@Gooey(optional_cols=2, program_name="GPS Collar Data Download")

# Force stdout cache to 0, so that Gooey gets it immediately:
# nonbuffered_stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)
# sys.stdout = nonbuffered_stdout

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
#Usage: sirtrack.rb [options]
#    -u, --username user              Username
#    -p, --password password          Password
#    -d, --dir dir                    Directory
#    -h, --help                       Displays Help
#    -v, --[no-]verbose               Run verbosely
#    -x, --csv [CSV_FILENAME]         Translate to single CSV/TXT
#                                      (using filename if supplied)
#    -z, --debug                      Run in debug mode


  sirtrack_parser.add_argument('username', type=str,
                               help='User name for your account', 
                               default='david.german@wildlife.ca.gov')
  sirtrack_parser.add_argument('password', type=str,
                               help='Password for your account (not secure)')
  sirtrack_parser.add_argument('-d', '--dir', type=str,
                               help='Directory in which to download data files',
                               default='data')
#  sirtrack_parser.add_argument('-b', '--begin', type=str, widget='DateChooser',
#                                help='beginning date to retrieve data from')          
#  sirtrack_parser.add_argument('-e', '--end', type=str, widget='DateChooser',
#                                help='ending date to retrieve data from')                            
  # sirtrack_parser.add_argument('-h', '--help', dest='help', action="store_true",
  #                               help='Display help with command options')
  sirtrack_filename = 'sirtrack' + time.strftime("%Y%m%d") + '.txt' 
#  sirtrack_parser.add_argument('-x', '--csv', type=str, 
#                               help='Translate to a single CSV/TXT file',
#                               default=sirtrack_filename)
  sirtrack_parser.add_argument('-v', '--verbose', action='store_true',
                                help='output details of downloading process') 
                            
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
                            
  vectronic_parser.add_argument('username', type=str,
                               help='User name for your account', default='snbs')
  vectronic_parser.add_argument('password', type=str,
                               help='Password for your account (not secure)')
  vectronic_parser.add_argument('database', type=str,
                                help='database name',default='sierrabighorn')
  vectronic_parser.add_argument('-d', '--dir', type=str, widget="DirChooser",
                               help='Directory in which to download data files', default='data')
  vectronic_parser.add_argument('-b', '--begin', type=str, widget='DateChooser',
                                help='beginning date to retrieve data from')          
  vectronic_parser.add_argument('-e', '--end', type=str, widget='DateChooser',
                                help='ending date to retrieve data from')                                       
  vectronic_filename = 'vectronic_' + time.strftime("%Y%m%d") + '.txt'                            
  vectronic_parser.add_argument('-x', '--csv', type=str, 
                               help='Translate to a single CSV/TXT file. Enter name of file.',
                               default=vectronic_filename)                            
  vectronic_parser.add_argument('-v', '--verbose', action='store_true',
                                help='output details of downloading process')                             
                               
  
  #### Vectronic    #####
  
  #### Tellus       #####
#  Usage: tellus.rb [options]
#    -u, --username user              Username
#    -p, --password password          Password
#    -d, --dir dir                    Directory
#    -h, --help                       Displays Help
#    -b, --begin [date]               Beginning date to retrieve data
#    -e, --end [date]                 Ending date to retrieve data
#    -v, --[no-]verbose               Run verbosely
#    -x, --csv [CSV_FILENAME]         Translate to single CSV/TXT
#                                      (using filename if supplied)
#    -z, --debug                      Run in debug mode
  tellus_parser.add_argument('username', type=str,
                               help='User name for your account', default='david@desert')
  tellus_parser.add_argument('password', type=str,
                               help='Password for your account (not secure)')
  tellus_parser.add_argument('-d', '--dir', type=str, widget="DirChooser",
                               help='Directory in which to download data files', default='data')
  tellus_parser.add_argument('-b', '--begin', type=str, widget='DateChooser',
                                help='beginning date to retrieve data from')          
  tellus_parser.add_argument('-e', '--end', type=str, widget='DateChooser',
                                help='ending date to retrieve data from')                                       
  tellus_filename = 'tellus_' + time.strftime("%Y%m%d") + '.txt'                            
  tellus_parser.add_argument('-x', '--csv', type=str, 
                               help='Translate to a single CSV/TXT file. Enter name of file.',
                               default=tellus_filename)                            
  tellus_parser.add_argument('-v', '--verbose', action='store_true',
                                help='output details of downloading process')        


  #### Convert arguments to command line string: ####
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
      arg_list.append(option)
      arg = dargs[key]
      if type(arg) == str :
        arg_list.append(arg)
          
  collardl_command = [interpreter, program_file] + arg_list
  # program_file = args.command + '.rb'
  print( "running the following command:")
  print(args)
  print( ' '.join(collardl_command))
  dl_cmd = Popen(collardl_command)
  # for line in dl_cmd.stdout.readlines():
    # print(line)
  # dl_cmd.wait()
  print()
  #print(args)
  #print( os.system(cmd) )
  
if __name__ == '__main__':
  main()
