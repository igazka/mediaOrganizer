#!/bin/bash


#get AUTH tocken
url=http://192.168.1.132:9208/
token=$(curl --data-urlencode username=igazka100@gmail.com -d password=Szae12_seafile http://192.168.1.132:9208/api2/auth-token/)
token=${token:10: -2}
curl -H "Authorization: Token ${token}" ${url}/api2/auth/ping/ #see if auth is working

#curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api/v2.1/admin/libraries/?page=1&per_page=100 #this command gives back all the repos
repo="182038b5-958f-49ee-8d68-ba58fec3b346"
# get all files in directory
dir=Photos/Camera
files=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api2/repos/${repo}/dir/?p=/${dir} | jq --raw-output '.[] | {name} | .[]')
files=($files)
echo "--------------------------------------------"
echo "num of files: ${#files[@]}"
#for file in "${files[@]}"
#do
#echo $file
#download to temp
file=${files[1]}
echo "First to process: ${file}"

if test -f "$file"; then
    echo "$FILE exists."
else
link=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}"api2/repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/${dir}/${file}&reuse=0" | jq --raw-output '.')
echo "$link"
cd /home/andras/seafile/tmp/
curl -O "${link}"
fi

#get exif data
date=$(exiftool -p '$dateTimeOriginal' "$file")
echo "$date"
year=${date::4}
echo "year: $year"
month=${date:5:2}
echo "month: $month"
#delete file
#rm "$file"
#check if directory exists
#if not create
#move file on srv
#done
