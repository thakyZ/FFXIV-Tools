#!/usr/bin/env python3
# In order to accommodate FFLogs, preventing the upload of logs older than two weeks is necessary
#
# This will automatically delete any old logs in the ACT FFXIVLogs folder that are older than two
#   weeks unless specified
#
# This python script will not work out of the box, you will need to alter lines 25 to 27 according
#   to where you have your FFXIVLogs folder for ACT
#
# Written by Neko Boi Nick
# Version 1.0.0
#
# ===========
#  Changelog
# ===========
# v1.0.0
#   - Initial Release
#

import os
import sys
import re
import time
import datetime

location = os.path.dirname(os.path.realpath(__file__))
act_dir = os.path.join(location, "ACT")
log_dir = os.path.join(act_dir, "FFXIVLogs")
arg_match = "^(\d{1,3})([mhdwMy])$"
filename_match = "^Network_\d{1,5}_(\d{8})\.log$"
date_match = "^(\d{4})(\d{2})(\d{2})$"
time_before = 0.0


def calc_time_back(minutes_before):
    presentDate = datetime.datetime.now()
    unix_timestamp = datetime.datetime.timestamp(presentDate) / 60
    time = unix_timestamp - minutes_before
    return time * 60


if len(sys.argv) > 1:
    args = sys.argv[1]
    arg_matched = re.search(arg_match, args)
    if arg_matched:
        number = int(arg_matched.group(1))
        timespan = arg_matched.group(2)
        match timespan:
            case "d":
                time_before = calc_time_back(1 * 60 * 24 * number)
            case "w":
                time_before = calc_time_back(1 * 60 * 24 * 7 * number)
            case "M":
                time_before = calc_time_back(1 * 60 * 24 * 30 * number)
            case "y":
                time_before = calc_time_back(1 * 60 * 24 * 365 * number)
            case _:
                print("[ERR] Unknown timespan format.")
    elif re.search("^(--help|-h)$"):
        print("Generic Help Message")
else:
    time_before = calc_time_back(1 * 60 * 24 * 7 * 2)

for filename in os.listdir(log_dir):
    filename_matched = re.search(filename_match, filename)
    if filename_matched:
        date = filename_matched.group(1)
        date_matched = re.search(date_match, date)
        filedate = datetime.datetime(int(date_matched.group(1)), int(
            date_matched.group(2)), int(date_matched.group(3)))
        unix_timestamp = filedate.timestamp()
        if unix_timestamp < time_before:
            print(f"Removing old log file: {filename}")
            os.remove(os.path.join(log_dir, filename))
