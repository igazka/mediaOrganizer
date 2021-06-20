#!/bin/bash
#bash script to rename photos basesed on their EXIF data IMG_YYYYMMDD_HHMMSS.jpg
# list of files from folder
    orgDirfiles=$(ls -p /home/andras/terraswinyo/images | grep -v /)
    IFS=$'\n' orgDirfiles=($orgDirfiles)
    echo "--------------------------------------------"
    echo "num of files: ${#orgDirfiles[@]}"
    exit 0
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
           date=$(exiftool -p '$dateTimeOriginal' "${orgDirfiles[file]}")
           ext=".jpg"
        elif [[ "${orgDirfiles[file]}" == *".mp4"* || "${orgDirfiles[file]}" == *".MP4"* ]]; then
           date=$(exiftool -p '$mediacreatedate' "${orgDirfiles[file]}")
           ext=".mp4"
        elif  [[ "${orgDirfiles[file]}" == *".3gp"* || "${orgDirfiles[file]}" == *".3GP"* ]]; then
            date=$(exiftool -p '$mediacreatedate' "${orgDirfiles[file]}")
            ext=".3gp"
        fi
        year=${date::4}
        month=${date:5:2}
        day=${date:8:2}
        hour=${date:11:2}
        minutes=${date:14:2}
        seconds=${date:17:2}  
        newFilename="IMG_"$year$month$day"_"$hour$minutes$seconds$ext
        echo "New filename: $newFilename"
    #renaming
        #mv ${orgDirfiles[file]} $newFilename
        echo "File: ${orgDirfiles[file]} is renamed to $newFilename."
done