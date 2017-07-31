import math
import sys
import itertools as it


def isInt(s):
    try:
        int(s)
        return True
    except ValueError:
        return False


def frange(a, b, inc):
    if isInt(a) and isInt(b) and isInt(inc):
        a = int(a)
        b = int(b)
        inc = int(inc)
    else:
        a = float(a)
        b = float(b)
        inc = float(inc)
    x = [a]
    for i in range(1, int(math.ceil(((b + inc) - a) / inc))):
        x.append(a + i * inc)
    return (str(e) for e in x)


def expandVars(v):
    min = v.split(":")[0]
    max = v.split(":")[1]
    step = v.split(":")[2]
    v = ','.join(frange(min, max, step))
    return v

def readCases(params, namesdelimiter=";", valsdelimiter=" "):
    with open(params) as f:
        content = f.read().splitlines()

    pvals = {}
    for x in content:
        if "null" not in x and x != "":
            pname = x.split(namesdelimiter)[0]
            pval = x.split(namesdelimiter)[1]
            if valsdelimiter in pval:
                pval = pval.split(valsdelimiter)
            elif ":" in pval:
                pval = expandVars(pval).split(",")
            else:
                pval = [pval]
            pvals[pname] = pval

    varNames = sorted(pvals)
    cases = [[{varName: val} for varName, val in zip(varNames, prod)] for prod in
             it.product(*(pvals[varName] for varName in varNames))]
    return cases


def generate_caselist(cases):

    caselist = []
    for c in cases:
        case = ""
        for p in c:
            pname = p.keys()[0]
            pval = p[pname]
            case += pname + "=" + pval + ","
        caselist.append(case[:-1])
    return caselist


def getParamTypeFromfileAddress(dataFileAddress):
    if dataFileAddress.endswith('.run'):
        paramsType = 'paramFile'
    elif dataFileAddress.endswith('.list'):
        paramsType = 'listFile'
    else:
        print('Error: parameter/case type cannot be set. Please provide .list or .run file. ')
        sys.exit(1)

    return paramsType


def readcasesfromcsv(casesFile):
    f = open(casesFile, "r")
    cases = []
    for i, line in enumerate(f):
        data = [l.replace("\n", "") for l in line.split(",")]
        case = []
        for ii, v in enumerate(data):
            param = {v.split('=')[0]: v.split('=')[1]}
            case.append(param)
        cases.append(case)
    f.close()
    return cases


def readParamsFile(paramsFile):
    paramsFileType = getParamTypeFromfileAddress(paramsFile)
    if paramsFileType == 'paramFile':
        cases = readCases(paramsFile)
    else:
        cases = readcasesfromcsv(paramsFile)
    return cases

