import sys
import re

def xstr(s):
    return '' if s is None else str(s)


def textStartsWithExactMath(text, flag_str, delimiter):
    if delimiter is None:
        delimiter = '\\b'
    if re.match(flag_str+delimiter, text):
        return True
    else:
        return False


def str2bool(v):
    return v.lower() in ("yes", "true", "t", "1")


def read_ints_from_file_pointer(file_pointer, flag_str, num_data,
                                delimiter=None, startIndex=0):
    data = []
    num_words_in_flag = len(flag_str.split())
    file_pointer.seek(0)
    for line in file_pointer:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            for i_data in range(num_data):
                data.append(int(line.split(delimiter)[i_data+startIndex]))
    if len(data) < num_data:
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return data


def read_floats_from_file_pointer(file_pointer, flag_str, num_data,
                                  delimiter=None, startIndex=0):
    data = []
    num_words_in_flag = len(flag_str.split())
    file_pointer.seek(0)
    for line in file_pointer:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            for i_data in range(num_data):
                data.append(float(line.split(delimiter)[i_data + startIndex]))
    if len(data) < num_data:
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return data


def read_float_from_file_pointer(file_pointer, flag_str, delimiter=None,
                                 startIndex=0,line2StartSearch=0):
    data = []
    num_words_in_flag = len(flag_str.split())
    file_pointer.seek(line2StartSearch)
    for line in file_pointer:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            data = float(line.split(delimiter)[startIndex])
    if not isinstance(data, float):
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return data


def read_float_from_strList(text, flag_str, delimiter=None,
                            startIndex=0,line2StartSearch=0):
    data = []
    text = text[line2StartSearch:]
    for line in text:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            data = float(line.split(delimiter)[startIndex])
            break
    if not isinstance(data, float):
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return data


def read_int_from_strList(text, flag_str, delimiter=None,
                          startIndex=0,line2StartSearch=0):
    data = []
    text = text[line2StartSearch:]
    for line in text:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            data = int(line.split(delimiter)[startIndex])
            break
    if not isinstance(data, int):
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return data


def read_str_from_strList(text, flag_str, delimiter=None, startIndex=0,
                          line2StartSearch=0):
    str2read = []
    text = text[line2StartSearch:]
    for line in text:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            str2read = line.split(delimiter)[startIndex]
            break
    if not isinstance(str2read, str):
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return str2read



def read_int_from_file_pointer(file_pointer, flag_str, delimiter=None,
                                 startIndex=0):
    data = []
    num_words_in_flag = len(flag_str.split())
    file_pointer.seek(0)
    for line in file_pointer:
        if textStartsWithExactMath(line, flag_str, delimiter):
            line = line[len(flag_str + xstr(delimiter)):]  # Remove flag from the beginning of line
            data = int(line.split(delimiter)[startIndex])
    if not isinstance(data, int):
        print("Error: cannot read ", flag_str, " from input file")
        sys.exit(1)
    return data


def open_file(file_name, open_mode="r"):
    try:
        file_pointer = open(file_name, open_mode)
        return file_pointer
    except IOError:
        print("Error: cannot open input file", file_name)
        sys.exit(1)


def removeLeadSpacesFromFile(strList):
    noLeadSpaceText = []
    for line in strList:
        noLeadSpaceText.append(line.lstrip())
    return noLeadSpaceText


def removeTrailingCharFromLines(strList, character2remove):
    strippedText = []
    for line in strList:
        strippedText.append(line.rstrip().rstrip(character2remove))
    return strippedText
