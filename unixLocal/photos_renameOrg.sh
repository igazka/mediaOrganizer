#!/bin/bash
#bash script to get all files from incoming folders, move them, rename them basesed on their EXIF data IMG_YYYYMMDD_HHMMSS.jpg then move them to destenation
srcFolder1=/home/andras/terraswinyo/images/Camera
srcFolder2=/home/andras/terraswinyo/images/CameraBogi
#go to working folder and list of files from folder
    workdircontentlist () { #incoming parameter is the srcFolder currently used
        cd $1
        orgDirfiles=$(ls -p | grep -v /)
        IFS=$'\n' orgDirfiles=($orgDirfiles)
        #echo "--------------------------------------------"
        #echo "num of files: ${#orgDirfiles[@]}"
        if [[ ${#orgDirfiles[@]} -eq 0 ]]; then
            return 0 #no new files
        else
            return 1
        fi
    
    }

workdircontentlist $srcFolder1
        if [[ $? -eq 0 ]]; then
            echo "no new files exit program"
        else
            echo "new files in folder"
        fi


exit 0
    #check if filename is valid

    #get exif data
    getExif () {
        if [[ "${orgDirfiles[file]}" == *".jpg"* || "${orgDirfiles[file]}" == *".JPG"* ]]; then
           date=$(exiftool -p '$dateTimeOriginal' "${orgDirfiles[file]}" -F)
           if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
             date=$(exiftool -p '$DateAcquired' "${orgDirfiles[file]}" -F)
             if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
              date=$(exiftool -p '${FileModifyDate#;DateFmt("%Y:%m:%d %H:%M:%S")}' "${orgDirfiles[file]}")
             fi
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
            newFilename=$prefix"_NOEXIF_DATA_"${orgDirfiles[file]}$ext
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
    }

    #rename
    rename () {
             if [[ "${orgDirfiles[file]}" == "$newFilename" ]]; then
            # echo "File ${orgDirfiles[file]} is \e[1;32malready\e[0m named $newFilename." 
           else 
             mv --backup=numbered ${orgDirfiles[file]} $newFilename
            # echo "\e[1;32mFile: ${orgDirfiles[file]} is renamed to $newFilename.\e[0m"
        fi 
    }
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
