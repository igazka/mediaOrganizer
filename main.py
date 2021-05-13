#!/usr/bin/env python
"""
List libraries including owned, shared and group libraries.
"""

import  requests

# replace with your token
token = 'Authorization: Token f63b5aaca9574f1054879efc2cf43fb9b9dc02d1'
url = 'http://192.168.1.132:9208/api2/ping'
format='Accept: application/json; indent=4' 
payload=token
response = requests.get(url,params=payload)

print(response.text)