import sys
import readParamsUtils

paramsFile = sys.argv[1]
caseslistFile = sys.argv[2]

cases = readParamsUtils.readCases(paramsFile)

print("Generated " + str(len(cases)) + " Cases")

caselist = readParamsUtils.generate_caselist(cases)

casel = "\n".join(caselist)

f = open(caseslistFile, "w")
f.write(casel)
f.close()
