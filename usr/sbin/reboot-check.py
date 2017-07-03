#!/usr/bin/env python
# -*- coding: utf-8 -*-
from argparse import ArgumentParser
import fileinput
import re


parser = ArgumentParser(prog="reboot-check")
group=parser.add_mutually_exclusive_group()
group.add_argument('-l', '--list', action="store_true", help="list supported scripts, they disabled by prefix '#'")
group.add_argument('-e', '--enable', help= "enable one script")
group.add_argument('-d', '--disable', action="store_true", help="disable all scripts")
parser.add_argument('-f', '--conf_file', default="/usr/share/reboot-check/reboot-check.conf")

args = parser.parse_args()

if args.list == True:
    with open(args.conf_file) as fp:
        print("now list avaliable scripts in "+ args.conf_file);
        for line in iter(fp.readline,''):
            print(line)
        print("you could enable them by -e ${name}.sh")
        print("ex. -e check-s3-mobile-wwan-connection-nmcli.sh")
        print("or edit config file directly.")

if args.enable != None:
    print("opening " + args.conf_file)
    with fileinput.FileInput(args.conf_file, inplace=True) as file:
        for line in file:
            if args.enable in line:
                print(re.sub(r'^#+(.+\.sh$)',r'\1',line.rstrip()))
            else:
                print(line.rstrip())

elif args.disable == True:
    with fileinput.FileInput(args.conf_file, inplace=True) as file:
        for line in file:
           print( re.sub(r'(^[^#])',r'# \1',line.rstrip()))
