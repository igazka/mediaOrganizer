#!/bin/bash
#echo "main process"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) #gets the dir of the script
cd $SCRIPT_DIR
export $(grep -v '^#' .env | xargs) # Export env vars, this will read from the .env file all the variables and they can be used by subshell aswell

(
#this is a subshell
#get all files from incoming folders, move them, rename them basesed on their EXIF data IMG_YYYYMMDD_HHMMSS.jpg then move them to destenation
folderChecked=0 #value to enable reading destanation folder structure 

#go to working folder and list of files from folder

    workDirContentlist () { #incoming parameter is the srcFolder currently used
        cd $1
        echo "------------------START-Script-----------------"
        echo "checking folder: $1"
        orgDirfiles=$(ls -p | grep -v /)
        IFS=$'\n' orgDirfiles=($orgDirfiles)
        if [[ ${#orgDirfiles[@]} -eq 0 ]]; then
            echo "#no new files in folder $1"
            return 0 
        else
            echo "num of new files: ${#orgDirfiles[@]}"
                for file in "${!orgDirfiles[@]}";do
                    echo -e "Processing: $file  of ${#orgDirfiles[@]}" 
                    checkFileExt ${orgDirfiles[file]}
                    if [[ $? -eq 1 ]]; then
                    continue
                    else
                    getExif ${orgDirfiles[file]}
                    rename  ${orgDirfiles[file]}
                    getFolderStruct $1
                    moveFile $1 $newFilename
                    fi
                echo "----------------File-Done----------------"
                done
        fi
    }
    checkFileExt(){ #check if fileextension is valid
        length=$(expr length "$1")
        fileExtension="${1##*.}"
        allowedExtensions=("jpg" "3gp" "mp4" "mov" "heic")
        if [[ $length -gt 0  &&  ${allowedExtensions[*]} =~ "${fileExtension,,}" ]]; then
            echo "good fileExtension: $1"
            return 0
        else
            echo "bad file extension: $1, skipping"
            return 1
        fi
    }
    getExif () { #get exif data
        fileExtension="${1##*.}"
        if [[ "${fileExtension,,}" == "jpg" || "${fileExtension,,}" == "heic" ]]; then
           date=$(exiftool -p '$dateTimeOriginal' "$1" -F)
           if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
             date=$(exiftool -p '$DateAcquired' "$1" -F)
             if [[ "${#date}" -eq 0 || "$date" == "0000:00:00 00:00:00" ]]; then
              date=$(exiftool -p '${FileModifyDate#;DateFmt("%Y:%m:%d %H:%M:%S")}' "$1")
             fi
           fi
           ext="${fileExtension,,}"
           prefix="IMG"
         elif [[ "${fileExtension,,}" == "mp4" || "${fileExtension,,}" == "3gp" || "${fileExtension,,}" == "mov" ]]  ; then
           date=$(exiftool -p '$mediacreatedate' "$1" -F)
           ext="${fileExtension,,}"
           prefix="VID"
        fi
        echo $date, "${#date}"
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
            newFilename=$prefix"_"$year$month$day"_"$hour$minutes$seconds"."$ext
            destSubDir="${year}"/"${month}"
        fi
        #echo "$newFilename $destSubDir"
    }
    rename () {
        if [[ "$1" == "$newFilename" ]]; then
             echo "File $1 is already named $newFilename." 
           else 
             mv --backup=numbered $1 $newFilename
             echo "File: $1 is renamed to $newFilename."
        fi 
    }
    getFolderStruct() {
        #check if directory exists
        #but only if first run or previously created new folders
       if [[ $folderChecked -eq 0 ]]; then
            folderStruct=$(ls -R "$destDir" | grep  / | rev | cut -c 2- | rev)
            IFS=$'\n' folderStruct=($folderStruct)
            folderChecked=1
            echo "Folder structure read from server."
        fi
        if [[ " ${folderStruct[@]} " =~ "${destDir}/${year}" ]]; then
             echo "${destDir}/${year} exists."
                if [[ " ${folderStruct[@]} " =~ "${destDir}/${year}/${month}" ]];then
                    echo "${destDir}/${year}/${month} exists."
                else 
                echo "${destDir}/${year}/${month} does not exist. Creating."
                mkdir ${destDir}/${destSubDir}
                echo "${destDir}/${destSubDir} created."
                folderChecked=0
                fi
        else
            echo "${destDir}/${destSubDir} does not exist. Creating."
            mkdir ${destDir}/${year}
            mkdir ${destDir}/${destSubDir}
            echo "$destSubDir created."
            folderChecked=0
        fi
    }
    moveFile(){ #1=orgDir 2=$newFilename
                #check if file is already there
                destDirContent=$(ls -p ${destDir}/${destSubDir} | grep -v /)
                IFS=$'\n' destDirContent=($destDirContent)
                #if file already exists, then just remove the original, if not, then move file to dest
                    if [[ " ${destDirContent[@]} " =~ "${2}" ]];then
                        #check file size and compare
                        if [[ $(stat -c "%s"  ${destDir}/${destSubDir}/"${2}") -eq $(stat -c "%s"  ${1}/"${2}") ]]; then 
                                echo "they are the same size, delete it"
                                rm ${1}/"${2}"
                                echo -e "File already exists at: ${destDir}/${destSubDir}"
                                return 1
                            else 
                                echo "they DIFFERENT, moving with care"
                                #appending prefix, to be able to see differences
                                prefix="mod_"
                        fi
                    else
                        echo "file is not there yet"
                        prefix=""
                    fi
                mv --backup=numbered ${1}/${2} ${destDir}/${destSubDir}/$prefix${2}
                echo -e "File moved to: ${destDir}/${destSubDir}"
    }
workDirContentlist $srcFolder1
workDirContentlist $srcFolder2  
echo "----------------Script-Done----------------"      
) 2>&1 | tee $logfilepath"/$(date +"%Y%m%d_%H%M%S").log"
find $logfilepath/ -type f -name "*.log" -ctime +31 -exec rm {} \;