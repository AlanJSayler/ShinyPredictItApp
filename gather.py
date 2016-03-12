from urllib.request import  Request, urlopen
import csv
from bs4 import BeautifulSoup
from datetime import datetime, timedelta

baseurl = 'https://www.predictit.org/api/marketdata/ticker/'

def makeRequest (url):
    request = Request(url)
    request.add_header('Accept', 'application/xml')
    response = urlopen(request)
    lines = bytes.decode(response.read())
    return lines


def updateFile (whichElection):
    filename = whichElection + '.csv'
    newLines = readXML(whichElection)
    print(newLines)
    writecsv(newLines, filename)
    return
    
def readXML (whichElection):
    url = baseurl + whichElection
    xml = makeRequest(url)
    return parseForCandidatePrices(xml)

def parseForCandidatePrices(xml):
    y = BeautifulSoup(xml, 'lxml')
    print(y)
    xran = len(y.findAll('marketcontract'))
    print(xran)
    yran = 3
    d = [['' for x in range(yran)] for x in range(xran)]
    now = datetime.now()
    for i in range(0,xran):
        d[i][0] = y.findAll('name')[i+1].string
        d[i][1] = y.findAll('lastcloseprice')[i].string
        d[i][2] = now.strftime("%Y-%m-%d.%H:%M:%S")
    return d
    


def readcsv(filename):
    file = open(filename, 'r')
    datareader = csv.reader(file,delimiter=',')
    d = []
    for row in datareader:
        d.append(row)
    return d

def writecsv(array, filename):
    with open(filename, 'a') as csvfile:
        writer = csv.writer(csvfile,delimiter = ',')
        writer.writerows(array)


updateFile('DNOM16')
updateFile('RNOM16')
updateFile('USPREZ16')
