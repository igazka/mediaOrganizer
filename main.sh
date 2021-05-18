  GNU nano 4.8                                                                                                     orgTest.sh                                                                                                      Modified
#!/bin/bash

#get AUTH token
    url=http://192.168.1.132:9208/
    token=$(curl --data-urlencode username=igazka100@gmail.com -d password=Szae12_seafile http://192.168.1.132:9208/api2/auth-token/)
    token=${token:10: -2}
#see if auth is working
    curl -H "Authorization: Token ${token}" ${url}/api2/auth/ping/ 

#curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api/v2.1/admin/libraries/?page=1&per_page=100 #this command gives back all the repos
repo="182038b5-958f-49ee-8d68-ba58fec3b346"
# get all files in directory
    orgDir=Photos/Camera
    destDir=Photos/Organized
    orgDirfiles=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api2/repos/${repo}/dir/?p=/${orgDir} | jq --raw-output '.[] | {name} | .[]')
    orgDirfiles=($orgDirfiles)
    echo "--------------------------------------------"
    echo "num of files: ${#orgDirfiles[@]}"
#for file in "${orgDirfiles[@]}"
    #do
    #echo $file
    #download to temp
    file=${orgDirfiles[1]}
    echo "First to process: ${file}"
    if test -f "$file"; then
        echo "$file exists."
    else
        link=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}"api2/repos/182038b5-958f-49ee-8d68-ba58fec3b346/file/?p=/${orgDir}/${file}&reuse=0" | jq --raw-output '.')
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
    destSubDir="${year}"_"${month}"
#delete file
    #rm "$file"
#check if directory exists
    destDirContent=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir} | jq --raw-output '.[] | {name} | .[]')
    destDirContent=($destDirContent)
    if [[ " ${destDirContent[@]} " =~ " ${destSubDir} " ]]; then
        # whatever you want to do when array contains value
        echo "$destSubDir exists."
    fi
    if [[ ! " ${destDirContent[@]} " =~ " ${destSubDir} " ]]; then
        # whatever you want to do when array doesn't contain value
        #create Dir
        curl -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
    fi
#move file on srv

#done
