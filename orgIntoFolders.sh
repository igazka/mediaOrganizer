#!/bin/bash
#Organizing Media into folders with a bash script
#seting folderstructure checker to 0 
    folderCheck=0
#go to working folder    
    orgDir=/home/andras/terraswinyo/images
    cd $orgDir
# list of files from folder
    orgDirfiles=$(ls -p | grep -v /)
    IFS=$'\n' orgDirfiles=($orgDirfiles)
    echo "--------------------------------------------"
    echo "num of files: ${#orgDirfiles[@]}"
for file in "${!orgDirfiles[@]}";do
    echo -e "Processing: \e[1;31m$file\e[0m  of ${#orgDirfiles[@]}" 
    echo "${orgDirfiles[file]}"
     #check if filename is valid
        length=$(expr length "${orgDirfiles[file]}")
            if [ $length -gt 0 ]&&[[ "${orgDirfiles[file]}" == *".jpg"* || *".3gp"* || *".mp4"* || *".JPG"* ]]; then
                echo "good filename: ${orgDirfiles[file]}"
            else
                echo "bad file extension: ${orgDirfiles[file]}, skipping"
                continue
            fi
     #get exif data
        if [[ "${orgDirfiles[file]}" == *".jpg"* || "${orgDirfiles[file]}" == *".JPG"* ]]; then
           dateTimeOriginal=$(exiftool -p '$dateTimeOriginal' "${orgDirfiles[file]}" -F)
           if [[ "${#dateTimeOriginal}" -eq 0 || "$dateTimeOriginal" == "0000:00:00 00:00:00" ]]; then
             date=$(exiftool -p '$DateAcquired' "${orgDirfiles[file]}" -F)
            else 
             date=$dateTimeOriginal
           fi
           ext=".jpg"
           prefix="IMG"
         elif [[ "${orgDirfiles[file]}" == *".mp4"* || "${orgDirfiles[file]}" == *".MP4"* ]]; then
           date=$(exiftool -p '$mediacreatedate' "${orgDirfiles[file]}" -F)
           ext=".mp4"
           prefix="VID"
         elif  [[ "${orgDirfiles[file]}" == *".3gp"* || "${orgDirfiles[file]}" == *".3GP"* ]]; then
            date=$(exiftool -p '$mediacreatedate' "${orgDirfiles[file]}" -F)
            ext=".3gp"
            prefix="VID"
        fi
        echo $date, "${#date}"
        #if there is no exif data, rename to NOEXIF_DATA + current name
        if [[ "${#date}" -gt 0 || "$date" != "0000:00:00 00:00:00" ]]; then
            year=${date::4}
            month=${date:5:2}
            destSubDir="${year}"/"${month}"
        else
            destSubDir="NoDate"
        fi
     #check if file is already there
                destDirContent=$(ls -p | grep -v /)
                IFS=$'\n' destDirContent=($destDirContent)
                #if file already exists, then just remove the original, if not, then move file to dest

#check file size and compare

                    if [[ " ${destDirContent[@]} " =~ "${orgDirfiles[file]}" ]];then
                        rm "${orgDirfiles[file]}"
                        echo -e "\e[1;32mFile already exists at: /${destDir}/${destSubDir}\e[0m"
                    else
                        curl -s -d "operation=move&dst_repo=${repo}&dst_dir=/${destDir}/${destSubDir}" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/file/?p=/${orgDir}/${orgDirfiles[file]}
                        echo -e "\e[1;32mFile moved to: /${destDir}/${destSubDir}\e[0m"
                    fi
                    rm "${downloadedfilename}"
                    continue
        fi
        echo $destSubDir       

    #check if directory exists
        #but only if first run or previously created new folders
        if [[ $folderCheck -eq 0 ]]; then
            folderStruct=$(curl -H "Authorization: Token ${token}" -H 'Accept: application/json; indent=4' "${url}api2/repos/${repo}/dir/?recursive=1&t=d&p=/${destDir}/" | jq --raw-output '.[] | {parent_dir, name} | if .parent_dir !="/My Photos/Organized/" then "\(.parent_dir )/\(.name)" else "\(.parent_dir )\(.name)" end')
            IFS=$'\n' folderStruct=($folderStruct)
            folderCheck=1
            echo "Folder structure read from server."
        fi
        echo "--------------------------------------"
        if [[ " ${folderStruct[@]} " =~ "${destDir//+/ }/${year}" ]]; then
            echo "${destDir//+/ }/${year} exists."
                if [[ " ${folderStruct[@]} " =~ "${destDir//+/ }/${year}/${month}" ]];then
                    echo "${destDir//+/ }/${year}/${month} exists."
                else 
                echo "${destDir//+/ }/${year}/${month} does not exist. Creating."
                curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
                echo "${destDir//+/ }/${destSubDir//+/ } created."
                folderCheck=0
                fi
        else
            echo "${destDir//+/ }/${destSubDir} does not exist. Creating."
            curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${year}
            curl -s -d "operation=mkdir" -H "Authorization: Token ${token}" -H 'Accept: application/json; charset=utf-8; indent=4' ${url}api2/repos/${repo}/dir/?p=/${destDir}/${destSubDir}
            echo "$destSubDir created."
            folderCheck=0
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
