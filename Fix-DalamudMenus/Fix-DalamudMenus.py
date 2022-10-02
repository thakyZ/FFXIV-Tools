import os
import re

ffxiv_folder = os.getenv("AppData")
xivlauncher = os.path.join(ffxiv_folder, "XIVLauncher")
dalamudUI = os.path.join(xivlauncher, "dalamudUI.ini")
dalamudUI_bak = os.path.join(xivlauncher, "dalamudUI.bak.ini")

data = {
    "###Accountant.Timers": {
        "pos": [1162, 1],
        "size": [344, 640],
        "collapsed": True
    },
    "Sonar": {
        "pos": [374, 1],
        "size": [786, 272],
        "collapsed": True
    }
}


def lines_that_contain(string, fp):
    return [line for line in fp if string in line]


def translate_boolean(number):
    if number == 1:
        return True
    elif number == True:
        return 1
    elif number == False:
        return 0
    else:
        return False


f = open(dalamudUI, "r+")
file_data = f.read()
f.close()
for element in data:
    regex = r"\[Window\]\[(" + re.escape(element) + \
        r")\]\nPos=(\d{1,4}),(\d{1,4})\nSize=(\d{1,4}),(\d{1,4})\nCollapsed=([0-1])"
    search = re.search(regex, file_data)
    if search:
        pos1 = data[element]['pos'][0]
        pos2 = data[element]["pos"][1]
        size1 = data[element]["size"][0]
        size2 = data[element]["size"][1]
        if search.group(2) != pos1 or search.group(3) != pos2 or search.group(4) != size1 or search.group(5) != size2 or translate_boolean(search.group(6)) != data[element]["collapsed"]:
            translated = translate_boolean(data[element]["collapsed"])
            file_data = re.sub(
                regex, "[Window][{}]\nPos={},{}\nSize={},{}\nCollapsed={}".format(element, pos1, pos2, size1, size2, translated), file_data)
f = open(dalamudUI, "w+")
f.write(file_data)
f.close()
