#!/bin/bash
#bash script to get all files from incoming folders, move them, rename them basesed on their EXIF data IMG_YYYYMMDD_HHMMSS.jpg then move them to destenation
srcFolder1=/home/andras/terraswinyo/images/Camera
srcFolder2=/home/andras/terraswinyo/images/CameraBogi
#go to working folder and list of files from folder

    workDirContentlist () { #incoming parameter is the srcFolder currently used
        cd $1
        echo "--------------------------------------------"
        echo "checking folder: $1"
        orgDirfiles=$(ls -p | grep -v /)
        IFS=$'\n' orgDirfiles=($orgDirfiles)
        if [[ ${#orgDirfiles[@]} -eq 0 ]]; then
            echo "#no new files in folder $1"
            return 0 
        else
            echo "num of new files: ${#orgDirfiles[@]}"
                for file in "${!orgDirfiles[@]}";do
                    checkFileExt ${orgDirfiles[file]}
                    if [[ $? -eq 1 ]]; then
                    continue
                    else
                    getExif ${orgDirfiles[file]}
                    rename  ${orgDirfiles[file]}
                    fi
                done
        fi
    }
    checkFileExt(){ #check if fileextension is valid
        length=$(expr length "$1")
        if [[ $length -gt 0 ]]&&[[ "${1: -4}" == ".jpg" || "${1: -4}" == ".JPG" || "${1: -4}" == ".3gp" || "${1: -4}" == ".mp4" ]]; then
            echo "good fileExtension: $1"
            return 0
        else
            echo "bad file extension: $1, skipping"
            return 1
        fi
    }
    getExif () { #get exif data
        if [[ "${1: -4}" == ".jpg" || "${1: -4}" == ".JPG" ]]; then
           date=$(exiftool -p '$dateTimeOriginal' "$1" -F)
           if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
             date=$(exiftool -p '$DateAcquired' "$1" -F)
             if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
              date=$(exiftool -p '${FileModifyDate#;DateFmt("%Y:%m:%d %H:%M:%S")}' "$1")
             fi
           fi
           ext=".jpg"
           prefix="IMG"
         elif [[ "${1: -4}" == ".mp4" || "${1: -4}" == ".MP4" ]]; then
           date=$(exiftool -p '$mediacreatedate' "$1" -F)
           ext=".mp4"
           prefix="VID"
         elif  [[ "${1: -4}" == ".3gp" || "${1: -4}" == ".3GP" ]]; then
            date=$(exiftool -p '$mediacreatedate' "$1" -F)
            ext=".3gp"
            prefix="VID"
        fi
        #echo $date, "${#date}"
        #if there is no exif data, rename to NOEXIF_DATA + current name
        if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
            newFilename=$prefix"_NOEXIF_DATA_"$1$ext
            destSubDir="NoDate"
        else
            year=${date::4}
            month=${date:5:2}
            day=${date:8:2}
            hour=${date:11:2}
            minutes=${date:14:2}
            seconds=${date:17:2}  
            newFilename=$prefix"_"$year$month$day"_"$hour$minutes$seconds$ext
            destSubDir="${year}"/"${month}"
        fi
        #echo "$newFilename $destSubDir"
    }
  rename () {
        if [[ "$1" == "$newFilename" ]]; then
             echo "File $1 is \e[1;32malready\e[0m named $newFilename." 
           else 
             mv --backup=numbered $1 $newFilename
             echo "\e[1;32mFile: $1 is renamed to $newFilename.\e[0m"
        fi 
    }
workDirContentlist $srcFolder1
#workDirContentlist $srcFolder2        
exit 0

    #check if directory exists
        #but only if first run or previously created new folders
     getFolderStruct() {
       if [[ $folderCheck -eq 0 ]]; then
            folderStruct=$(ls -R "$orgDir" | grep  / | rev | cut -c 2- | rev)
            IFS=$'\n' folderStruct=($folderStruct)
            folderCheck=1
           # echo "Folder structure read from server."
        fi
        echo "--------------------------------------"
        if [[ " ${folderStruct[@]} " =~ "${orgDir}/${year}" ]]; then
            # echo "${orgDir}/${year} exists."
                if [[ " ${folderStruct[@]} " =~ "${orgDir}/${year}/${month}" ]];then
                   # echo "${orgDir}/${year}/${month} exists."
                else 
            #    echo "${orgDir}/${year}/${month} does not exist. Creating."
                mkdir ${orgDir}/${destSubDir}
            #    echo "${orgDir}/${destSubDir} created."
                folderCheck=0
                fi
        else
         #   echo "${orgDir}/${destSubDir} does not exist. Creating."
            mkdir ${orgDir}/${year}
            mkdir ${orgDir}/${destSubDir}
         #   echo "$destSubDir created."
            folderCheck=0
        fi
     }
     #check if file is already there
                #if file already exists, then just remove the original, if not, then move file to dest
                        #check file size and compare
