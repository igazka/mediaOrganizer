#!/usr/bin/env python
"""
List libraries including owned, shared and group libraries.
"""

import  requests

#'repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/portfolio.Igaz_portfolio.xml'
# replace with your token
token = 'Authorization: Token f63b5aaca9574f1054879efc2cf43fb9b9dc02d1'
url = 'http://192.168.1.132:9208/api2/repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/portfolio.Igaz_portfolio.xml'
format='Accept: application/json; charset=utf-8; indent=4'
payload={token,format}
response = requests.get(url,params=payload)

print(response.text)