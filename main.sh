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
    orgDir=My+Photos/Camera
    destDir=My+Photos/Organized
# list of files from folder
    orgDirfiles=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' ${url}api2/repos/${repo}/dir/?p=/${orgDir} | jq --raw-output '.[] | {name,type} | select(.type !="dir" ) | {name} | .[]')
    IFS=$'\n' orgDirfiles=($orgDirfiles)
    echo "--------------------------------------------"
    echo "num of files: ${#orgDirfiles[@]}"
for file in "${!orgDirfiles[@]}";do
    echo -e "Processing: \e[1;31m$file\e[0m  of ${#orgDirfiles[@]}"  \e[1;31m\e[0m
    echo "${orgDirfiles[file]}"
    #check if filename is valid
        length=$(expr length "${orgDirfiles[file]}")
            if [ $length -gt 0 ]&&[[ "${orgDirfiles[file]}" == *".jpg"* || *".3gp"* || *".mp4"* || *".JPG"* ]]; then
                if [[ "${orgDirfiles[file]}" == *" "* ]]; then
                    echo "filename contains space: ${orgDirfiles[file]}. Renaming."
                    curl -s -d "operation=rename&newname=${orgDirfiles[file]// /_}" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' "${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]// /+}"
                    orgDirfiles[file]=${orgDirfiles[file]// /_}
                    echo "${orgDirfiles[file]} is the new name."
                fi
                echo "good filename: ${orgDirfiles[file]}"
            else
                echo "bad file extension: ${orgDirfiles[file]}"
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
        if [[ "${downloadedfilename}" == *".jpg"* || "${downloadedfilename}" == *".JPG"* ]]; then
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
                destDirContent=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' "${url}api2/repos/${repo}/dir/?t=f&p=/${destDir}/${destSubDir}" | jq --raw-output '.[] | .name')
                IFS=$'\n' destDirContent=($destDirContent)
                #if file already exists, then just remove the original, if not, then move file to dest
                    if [[ " ${destDirContent[@]} " =~ "${orgDirfiles[file]}" ]];then
                        curl -X DELETE -v  -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' "${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}"                       
                        echo -e "\e[1;32mFile already exists at: /${destDir}/${destSubDir}\e[0m"
                    else
                        curl -s -d "operation=move&dst_repo=${repo}&dst_dir=/${destDir}/${destSubDir}" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}
                        echo -e "\e[1;32mFile moved to: /${destDir}/${destSubDir}\e[0m"
                    fi
                    rm "${downloadedfilename}"
                    continue
        fi
        echo $destSubDir       
    #delete file
        rm "${downloadedfilename}"
    #check if directory exists
        destDirContent=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' "${url}api2/repos/${repo}/dir/?recursive=1&t=d&p=/${destDir}/" | jq --raw-output '.[] | {parent_dir, name} | if .parent_dir !="/My Photos/Organized/" then "\(.parent_dir )/\(.name)" else "\(.parent_dir )\(.name)" end')
        IFS=$'\n' destDirContent=($destDirContent)
        echo "--------------------------------------"
        if [[ " ${destDirContent[@]} " =~ "${destDir//+/ }/${year}" ]]; then
            echo "${destDir//+/ }/${year} exists."
                if [[ " ${destDirContent[@]} " =~ "${destDir//+/ }/${year}/${month}" ]];then
                    echo "${destDir//+/ }/${year}/${month} exists."
                else 
                curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
                echo "${destSubDir//+/ } created."
                fi
        else
            echo "${destDir//+/ } does not exist. Creating."
            curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${year}
            curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
            echo "$destSubDir created."
        fi

    #check if file is already there
        destDirContent=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' "${url}api2/repos/${repo}/dir/?t=f&p=/${destDir}/${destSubDir}" | jq --raw-output '.[] | .name')
        IFS=$'\n' destDirContent=($destDirContent)
                #if file already exists, then just remove the original, if not, then move file to dest
                    if [[ " ${destDirContent[@]} " =~ "${orgDirfiles[file]}" ]];then
                        curl -X DELETE -v  -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' "${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}"                       
                        echo -e "\e[1;32mFile already exists at: /${destDir}/${destSubDir}\e[0m"
                    else
                        curl -s -d "operation=move&dst_repo=${repo}&dst_dir=/${destDir}/${destSubDir}" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}
                        echo -e "\e[1;32mFile moved to: /${destDir}/${destSubDir}\e[0m"
                    fi
done
