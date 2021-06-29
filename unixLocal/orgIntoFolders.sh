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
        if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
            destSubDir="NoDate"
         else
            year=${date::4}
            month=${date:5:2}
            destSubDir="${year}"/"${month}"
        fi
    #check if directory exists
        #but only if first run or previously created new folders
        if [[ $folderCheck -eq 0 ]]; then
            folderStruct=$(ls -R "$orgDir" | grep  / | rev | cut -c 2- | rev)
            IFS=$'\n' folderStruct=($folderStruct)
            folderCheck=1
            echo "Folder structure read from server."
        fi
        echo "--------------------------------------"
        if [[ " ${folderStruct[@]} " =~ "${orgDir}/${year}" ]]; then
            echo "${orgDir}/${year} exists."
                if [[ " ${folderStruct[@]} " =~ "${orgDir}/${year}/${month}" ]];then
                    echo "${orgDir}/${year}/${month} exists."
                else 
                echo "${orgDir}/${year}/${month} does not exist. Creating."
                mkdir ${orgDir}/${destSubDir}
                echo "${orgDir}/${destSubDir} created."
                folderCheck=0
                fi
        else
            echo "${orgDir}/${destSubDir} does not exist. Creating."
            mkdir ${orgDir}/${year}
            mkdir ${orgDir}/${destSubDir}
            echo "$destSubDir created."
            folderCheck=0
        fi
     #check if file is already there
                destDirContent=$(ls -p ${orgDir}/${destSubDir} | grep -v /)
                IFS=$'\n' destDirContent=($destDirContent)
                #if file already exists, then just remove the original, if not, then move file to dest
                    if [[ " ${destDirContent[@]} " =~ "${orgDirfiles[file]}" ]];then
                        #check file size and compare
                        if [[ $(stat -c "%s"  ${orgDir}/${destSubDir}/"${orgDirfiles[file]}") -eq $(stat -c "%s"  ${orgDir}/"${orgDirfiles[file]}") ]]; then 
                                echo "they are the same size, delete it"
                                rm ${orgDir}/"${orgDirfiles[file]}"
                                echo -e "\e[1;32mFile already exists at: ${orgDir}/${destSubDir}\e[0m"
                                continue
                            else 
                                echo "they DIFFERENT, moving with care"
                                #appending postfix, to be able to see differences
                                prefix="mod_"
                        fi
                    else
                        echo "file is not there yet"
                        prefix=""
                    fi
                mv --backup=numbered ${orgDir}/${orgDirfiles[file]} ${orgDir}/${destSubDir}/$prefix${orgDirfiles[file]}
                echo -e "\e[1;32mFile moved to: ${orgDir}/${destSubDir}\e[0m"
done
