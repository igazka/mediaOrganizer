  GNU nano 4.8                                                                                                     orgTest.sh                                                                                                      Modified
#!/bin/bash
    #Organizing Media on my seafile instance with a bash script
#going to working folder 
    tempFolder=/home/andras/seafile/tmp/
    cd $tempFolder
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
# list of files from folder
    orgDirfiles=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api2/repos/${repo}/dir/?p=/${orgDir} | jq --raw-output '.[] | {name,type} | select(.type !="dir" ) | {name} | .[]')
    IFS=$'\n' orgDirfiles=($orgDirfiles)
    echo "--------------------------------------------"
    echo "num of files: ${#orgDirfiles[@]}"
for file in "${!orgDirfiles[@]}";do
    echo "Processing: $file of ${#orgDirfiles[@]}"
    echo "${orgDirfiles[file]}"
    #check if filename is valid
        length=$(expr length "${orgDirfiles[file]}")
            if [ $length -gt 0 ]&&[[ "${orgDirfiles[file]}" == *".jpg"* ]] || [[ "${orgDirfiles[file]}" == *".3gp"* ]] || [[ "${orgDirfiles[file]}" == *".mp4"* ]] && [[ "${orgDirfiles[file]}" != *" "* ]]; then
                echo "good filename: ${orgDirfiles[file]}"
            else
                echo "bad file extension, of filename contains space: ${orgDirfiles[file]}"
                continue
            fi
    #download to temp
        if test -f "${orgDirfiles[file]}"; then
            echo "${orgDirfiles[file]} already downloaded."
        else
            link=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' "${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}&reuse=0" | jq --raw-output '.')
            echo "$link"
            downloadedfilename="${link##*/}"
            echo $downloadedfilename
            curl -O "${link}"
        fi
    #get exif data
        if [[ "${downloadedfilename}" == *".jpg"* ]]; then
           date=$(exiftool -p '$dateTimeOriginal' "${downloadedfilename}")
        elif [[ "${downloadedfilename}" == *".mp4"*  ||  "${downloadedfilename}" == *".3gp"* ]]; then
           date=$(exiftool -p '$mediacreatedate' "${downloadedfilename}")
        fi
        year=${date::4}
        month=${date:5:2}  
        echo "year: $year"
        echo "month: $month"
        destSubDir="${year}"/"${month}"
        if [ "${destSubDir}" == "/" ];then
            destSubDir="NoDate"
            #check if file is already there
            #destDirContent=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' "${url}api2/repos/${repo}/dir/?t=f&p=/${destDir}/${destSubDir}" | jq --raw-output '.[] | {parent_dir, name} | if .parent_dir !="/Photos/Organized/" then "\(.parent_dir )/\(.name)" else "\(.parent_dir )\(.name)" end')
            
            #move file on srv
            curl -s -d "operation=move&dst_repo=${repo}&dst_dir=/${destDir}/${destSubDir}" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}
            echo "File moved to: /${destDir}/${destSubDir}"
            rm "${downloadedfilename}"
            continue
        fi
        echo $destSubDir       
    #delete file
        rm "${downloadedfilename}"
    #check if directory exists
        destDirContent=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' "${url}api2/repos/${repo}/dir/?recursive=1&t=d&p=/${destDir}/" | jq --raw-output '.[] | {parent_dir, name} | if .parent_dir !="/Photos/Organized/" then "\(.parent_dir )/\(.name)" else "\(.parent_dir )\(.name)" end')
        IFS=$'\n' destDirContent=($destDirContent)

        if [[ " ${destDirContent[@]} " =~ "${destDir}/${year}" ]]; then
            # whatever you want to do when array contains value
            echo "${destDir}/${year} exists."
                if [[ " ${destDirContent[@]} " =~ "${destDir}/${year}/${month}" ]];then
                    echo "${destDir}/${year}/${month} exists."
                else 
                curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
                echo "$destSubDir created."
                fi
        else
            curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${year}
            curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
            echo "$destSubDir created."
        fi
    #check if file is already there
        #
    #move file on srv
        curl -s -d "operation=move&dst_repo=${repo}&dst_dir=/${destDir}/${destSubDir}" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}
        echo "File moved to: /${destDir}/${destSubDir}"
done
