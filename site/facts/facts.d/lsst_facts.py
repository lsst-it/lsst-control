#!/bin/env python
import os

def process_full_name(hostname_list, data):
	if len(hostname_list) >= 5:
		data["node_name"] = hostname_list[4]

	if len(hostname_list) >= 4:
		data["service_cluster"] = hostname_list[3]

	# We are translating backbone to enclave
	if len(hostname_list) >= 3:
		data["enclave"] = hostname_list[2]
	return data

def no_loc_name(hostname_list, data):
	if len(hostname_list) >= 3:
		data["node_name"] = hostname_list[2]

	if len(hostname_list) >= 2:
		data["service_cluster"] = hostname_list[1]

	# We are translating backbone to enclave
	if len(hostname_list) >= 1:
		data["enclave"] = hostname_list[0]
	return data

def processDomain(fqdn, data):
	# We are not expecting to have more than 1 datacenter per site, hence, the datanceter
	# can be named as the site
	if len(fqdn) == 5:
		data["datacenter"] = fqdn[1]

	if len(fqdn) == 5:
		data["site"] = fqdn[1]

	if len(fqdn) == 5:
		data["country"] = fqdn[2]
		
	if len(fqdn) == 4:
		data["country"] = fqdn[1]
		
	return data

def facts_generator(fqdn, data):
	#Breakdown
	# 0: Room
	# 1: Rack
	# 2: backbone
	# 3: Service / Cluster / Device
	# 4: Number / Node name / Node name number
	hostname = fqdn[0]
	hostname_list = hostname.split("-")
	#Reference: https://confluence.lsstcorp.org/display/SYSENG/LSST+ITC+DNS+Infrastructure
	#Full name with location

	if len(hostname_list) == 5:
		data = process_full_name(hostname_list, data)
	elif len(hostname_list) >= 3:
		data = no_loc_name(hostname_list, data)

	data = processDomain(fqdn, data)

	#print data in fact format
	for k in data:
		print(k + "=" + data[k])

data = dict()
data["service"] = "default"
data["cluster"] = "default"
data["device"] = "default"
data["service_number"] = "default"
data["device_number"] = "default"
data["node_name"] = "default"
data["datacenter"] = "default"
data["enclave"] = "default"
data["country"] = "default"

# Breakdown:
# 0: Hostname
# 1: Site
# 2: Country
# 3: LSST
# 4: ORG

# I'm using localhost as default value because in case the environment variable doesn't exist
# still being a case for the second if without further conditions
hostname_value = ["localhost"]
if "HOSTNAME" in os.environ:
	hostname_value = os.environ['HOSTNAME'].split(".")

if hostname_value[0] == "localhost":
	hostname_file = open("/etc/hostname")
	hostname_value = hostname_file.read().replace("\n","").split(".")
#hostname_value = "cr-a1-gs-puppet-01.ls.cl.lsst.org".split(".")
fqdn = None
#Full name received or Full nume without a site (ie: A country server)
if len(hostname_value) >= 4:
	fqdn = hostname_value
#Only hostname received
elif len(hostname_value) >= 1:
	fqdn = [hostname_value[0], "default" , "default", "default", "default"]

# Any other undetermined case will print default data dictionary
facts_generator(fqdn, data)
