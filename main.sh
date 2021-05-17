#!/bin/bash


#get AUTH tocken
url=http://192.168.1.132:9208/
token=$(curl --data-urlencode username=igazka100@gmail.com -d password=Szae12_seafile http://192.168.1.132:9208/api2/auth-token/)
token=${token:10:(-2)}
curl -H "Authorization: Token ${token}" ${url}/api2/auth/ping/ #see if auth is working

#curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api/v2.1/admin/libraries/?page=1&per_page=100 #this command gives back all the repos
repo="182038b5-958f-49ee-8d68-ba58fec3b346"
# get all files in directory
dir=Photos/Camera
files=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api2/repos/${repo}/dir/?p=/${dir} | jq --raw-output '.[] | {name} | .[]')

for file in "${files[@]}"
do 
echo $file
#download to temp
link=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}"api2/repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/portfolio/${file}&reuse=0" | jq --raw-output '.')
curl ${link} > /home/andras/seafile/tmp/${file}
#get exif data

#delete file 
#check if directory exists
#if not create
#move file on srv
done

