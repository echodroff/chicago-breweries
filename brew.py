#!/usr/bin/env python
# -*- coding: utf-8 -*-
import csv, string, re, random
from collections import defaultdict

website = {}
address = {}
extraFeats = {}
neighborhoods = {}
city = {}
state = {}
brewIDs = {}

def find_between(s, first, last):
	try:
		start = s.index(first) + len(first)
		end = s.index(last)
		return s[start:end]
	except ValueError:
		return ""

with open('/Users/Eleanor/Dropbox/2017-2018/ChicagoBreweryProject/cleanBreweries.txt', 'r') as f:
	for line in f:
		line = re.sub('<strong>', '', line)
		line = re.sub('</strong>', '', line)
		line = re.sub('&nbsp;', ' ', line)
		line = re.sub('&amp;', '&', line)
		line = re.sub('</p>', '', line)
		mySite = find_between(line, 'href="', '">')
		myBrewName = find_between(line, mySite+'">', '</a>')
		myAddress = find_between(line, myBrewName+'</a>', '<p>')
		myAddress = re.sub('<em>', ' ', myAddress)
		myAddress = re.sub('\em>', ' ', myAddress)
		myAddress = re.sub('</', '', myAddress)
		
		extraFeatures = find_between(myAddress, '[', ']')
		
		myAddress = re.sub('[[A-Za-z]+[, ]*[A-Za-z]+[, ]*[A-Za-z]*]', '', myAddress)
		myAddress = myAddress.lstrip()
		myAddress = myAddress.rstrip()
		myAddress = re.sub('\(  In [Pp]lanning\)', '', myAddress)
		myAddress = re.sub('\(  In [Pp]rogress\)', '', myAddress)
		myAddress = re.sub('\(In [Pp]rogress\)', '', myAddress)
		myAddress = re.sub('\(In [Pp]lanning\)', '', myAddress)
		myAddress = re.sub('\(Beer [Aa]vailable\)', '', myAddress)
		myAddress = re.sub('\(Taproom in progress\)', '', myAddress)
		myAddress = myAddress.lstrip()
		myAddress = re.sub(' – ', ', Chicago, IL, ', myAddress)
		if re.search('Chicago, IL', myAddress):
			neighborhoodSplit = myAddress.split('IL, ')
			neighborhood = neighborhoodSplit[1]
			neighborhood = neighborhood.lstrip()
			myAddress = myAddress.strip(neighborhood)
			myAddress = myAddress.rstrip()
			myAddress = myAddress.rstrip(',')
		else:
			neighborhood = ""
		
		addressParts = myAddress.split(',')
		if len(addressParts) == 3:
			myAddress = addressParts[0]
			myCity = addressParts[1]
			myState = addressParts[2]
		elif len(addressParts) == 2:
			myAddress = ""
			myCity = addressParts[0]
			myState = addressParts[1]
		else:
			myAddress = ""
			myCity = addressParts[0]
			myState = ""
		myCity = myCity.lstrip()
		myState = myState.lstrip()
		myBrewName = myBrewName.rstrip()
		
		website.update({myBrewName: mySite})
		address.update({myBrewName: myAddress})
		extraFeats.update({myBrewName: extraFeatures})
		neighborhoods.update({myBrewName: neighborhood})
		city.update({myBrewName: myCity})
		state.update({myBrewName: myState})
		brewID = myBrewName[0:1] + myBrewName[3] + myBrewName[len(myBrewName)-1:len(myBrewName)] + str(random.randint(1,10))
		
		print brewID
		brewIDs.update({myBrewName: brewID})

merged_dict = defaultdict(list)
dict_list = [brewIDs, address, city, state, neighborhoods, website, extraFeats]
	
for dict in dict_list:
    for k, v in dict.items():
        merged_dict[k].append(v)

with open('/Users/Eleanor/Desktop/breweries.txt', 'wb') as file:
	writer = csv.writer(file, delimiter='\t')
	for key, value in merged_dict.iteritems():
			value.insert(0, key)
			writer.writerow(value)
file.close()

merged_dict2 = defaultdict(list)
dict_list2 = [brewIDs, address, city, state]

for dict in dict_list2:
    for k, v in dict.items():
        merged_dict2[k].append(v)
        
with open('/Users/Eleanor/Desktop/brewAddress.csv', 'wb') as file:
	writer = csv.writer(file, delimiter=',')
	for key, value in merged_dict2.iteritems():
			value.insert(0, key)
			value.insert(5, ' ')
			writer.writerow(value)
file.close()
