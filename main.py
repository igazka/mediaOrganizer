#!/usr/bin/env python
"""
List libraries including owned, shared and group libraries.
"""
import  requests
from requests.auth import HTTPBasicAuth

url = 'http://192.168.1.132:9208/api2/'

#response = requests.get(url+"auth-token/",auth="username=igazka100@gmail.com&password=Szae12_seafile")
response = requests.get(url+"ping/")
print(response.text)

response = requests.post(url+"auth-token/",auth=HTTPBasicAuth("Szae12_seafile","igazka100@gmail.com"))
token=(response.text)
print(token)
#'repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/portfolio.Igaz_portfolio.xml'
# replace with your token

#format='Accept: application/json; charset=utf-8; indent=4'
#payload={token:format}
#response = requests.get(url+'repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/portfolio.Igaz_portfolio.xml',params=token)

#print(response.text)

